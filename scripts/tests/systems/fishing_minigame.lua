-- A cast on the rod and bait given, with no gear, as the entry would build it from the catalog, the bite long past.
local function castOn(data, rodId, baitId)
    assert(data.rods[rodId] ~= nil, 'Expected the catalog to carry rod ' .. tostring(rodId))
    assert(data.baits[baitId] ~= nil, 'Expected the catalog to carry bait ' .. tostring(baitId))

    return
    {
        zone     = data.zones[xi.zone.WEST_RONFAURE],
        rodId    = rodId,
        rod      = data.rods[rodId],
        baitId   = baitId,
        bait     = data.baits[baitId],
        hookedAt = 0,
    }
end

-- A hooked catch of the item id given: a fish, or an item when the catalog flags it so.
local function hookedCatch(data, itemId)
    local record = data.fish[itemId]

    assert(record ~= nil, 'Expected the catalog to carry catch ' .. tostring(itemId))

    return
    {
        type   = record.item and xi.fishing.catchType.ITEM or xi.fishing.catchType.FISH,
        itemId = itemId,
        record = record,
        count  = 1,
    }
end

-- Every fishing line sent to the player since its packets were last cleared, as offsets from the zone's base, in order: the
-- plain lines as 0x036, the lines with a parameter as 0x02A. The id carries 0x8000 when the speaker is the player.
local function fishingMessages(player)
    local base     = zones[xi.zone.WEST_RONFAURE].text.FISHING_MESSAGE_OFFSET
    local messages = {}

    for _, packet in ipairs(player.packets:getIncoming()) do
        if packet.type == 0x036 then
            table.insert(messages, bit.band(packet.data[10] + packet.data[11] * 256, 0x7FFF) - base)
        elseif packet.type == 0x02A then
            table.insert(messages, bit.band(packet.data[26] + packet.data[27] * 256, 0x7FFF) - base)
        end
    end

    return messages
end

-- The ids of a catalog table in ascending order, so the sweeps and their seeds run the same way every time.
local function sortedIds(catalog)
    local ids = {}
    for id in pairs(catalog) do
        table.insert(ids, id)
    end

    table.sort(ids)

    return ids
end

-- Keeps the meters off the char vars: a fresh angler's meters read empty, so every bite is allowed, and nothing is written back.
local function stubMeters()
    stub('xi.fishing.updateMeters', true)
end

-- Every bound the fight holds to for the angler and the catch given, each failure naming the rod, the catch and the skill.
local function checkFight(player, data, cast, catch, skill, fight)
    local record  = catch.record
    local level   = record.skill
    local gap     = skill - level
    local rod     = xi.fishing.rodStats[cast.rodId]
    local tier    = record.legendary
    local large   = record.size == xi.fishingSize.LARGE
    local isFish  = catch.type == xi.fishing.catchType.FISH
    local keen    = bit.band(fight.angler_sense, 2) == 2
    local feeling = fight.feeling
    local chances = fight.chances
    local label   = tostring(data.rods[cast.rodId].name) .. ' on ' .. tostring(record.name) .. ' at skill ' .. tostring(skill) .. ': '

    -- Stamina: floor((level + 36) / 2) times a roll of 95 to 105, the roll read back for the gauge
    local base = math.floor((level + 36) / 2)
    local roll = fight.stamina / base

    assert(fight.stamina % base == 0 and roll >= 95 and roll <= 105, label .. 'stamina ' .. tostring(fight.stamina) .. ' is not ' .. tostring(base) .. ' times 95 to 105')

    -- Delay, move and time hold their bounds, with the seconds and the arrow rate the corpus measured pinned per rod and species
    -- in the retail signatures
    assert(fight.arrow_delay >= 1 and fight.arrow_delay <= 15, label .. 'delay ' .. tostring(fight.arrow_delay) .. ' outside 1 to 15')
    assert(fight.move_frequency >= 1 and fight.move_frequency <= 15, label .. 'move ' .. tostring(fight.move_frequency) .. ' outside 1 to 15')
    assert(fight.time >= 0, label .. 'time ' .. tostring(fight.time))

    -- The heal is the damage the catch takes back at the rod's recovery, so it never outpaces the damage
    assert(fight.arrow_regen > 0 and fight.arrow_regen < fight.arrow_damage, label .. 'heal ' .. tostring(fight.arrow_regen) .. ' against damage ' .. tostring(fight.arrow_damage))

    -- The large bit, then the gauge: the 128 plateau the captures fixed from 27 under to the level over the catch the rod holds
    -- to, the drain past it down to the floor, and the rise from 28 under on a fish
    assert((bit.band(fight.angler_sense, 1) == 1) == large, label .. 'angler sense ' .. tostring(fight.angler_sense) .. ' has the large bit wrong')

    if tier then
        assert(fight.regen > 128, label .. 'regen ' .. tostring(fight.regen) .. ' on a legendary catch is not over the bias')
    elseif gap >= (rod.drainStart or 12) then
        -- The drain alone carries the stamina roll, so it is read back at a roll of 100
        local gauge = fight.regen + roll - 100

        assert(gauge <= 128 and gauge >= (isFish and 42 or 30), label .. 'gauge ' .. tostring(gauge) .. ' at a roll of 100, ' .. tostring(gap) .. ' levels over the catch')
    elseif
        isFish and
        gap <= -28
    then
        assert(fight.regen > 128, label .. 'regen ' .. tostring(fight.regen) .. ' at ' .. tostring(-gap) .. ' levels under the catch does not rise')
    else
        assert(fight.regen == 128, label .. 'regen ' .. tostring(fight.regen) .. ' off the plateau at gap ' .. tostring(gap))
    end

    -- Intuition: 10 and 2 per ten points of skill on every rod, 10 or 20 at a new or full moon, 5 or 10 on some hooks at a
    -- quarter, and 50 on a keen sense. The hour sits off 5 and 17 and no gear is worn.
    local intuitionBase = 10 + 2 * math.floor(skill / 10) + (keen and 50 or 0)
    local moon          = getVanadielMoonCycle()
    local moonExtras    = { 0 }

    if
        moon == xi.moonCycle.NEW_MOON or
        moon == xi.moonCycle.FULL_MOON
    then
        moonExtras = { 10, 20 }
    elseif
        moon == xi.moonCycle.FIRST_QUARTER or
        moon == xi.moonCycle.THIRD_QUARTER
    then
        moonExtras = { 0, 5, 10 }
    end

    local explained = false
    for _, moonExtra in ipairs(moonExtras) do
        if fight.intuition == intuitionBase + moonExtra then
            explained = true
        end
    end

    assert(explained, label .. 'intuition ' .. tostring(fight.intuition) .. ' outside its terms from ' .. tostring(intuitionBase))

    -- The failure chances: lose to 50, snap and break to 55, a break only on a rod with a broken form, a reason with every
    -- lose, and none on a legendary rod within 7 levels
    assert(chances.lose >= 0 and chances.lose <= 100, label .. 'lose chance ' .. tostring(chances.lose))
    assert(chances.lineSnap >= 0 and chances.lineSnap <= 55 and chances.rodBreak >= 0 and chances.rodBreak <= 55, label .. 'snap ' .. tostring(chances.lineSnap) .. ' break ' .. tostring(chances.rodBreak))
    assert((chances.lose > 0) == (chances.loseReason ~= nil), label .. 'lose ' .. tostring(chances.lose) .. ' with reason ' .. tostring(chances.loseReason))
    assert(cast.rod.breaksTo ~= nil or chances.rodBreak == 0, label .. 'a rod with no broken form carries a break chance')

    if
        cast.rod.legendary and
        level <= skill + 7
    then
        assert(chances.lose == 0, label .. 'a legendary rod loses within 7 levels')
    end

    -- The feeling: epic on an epic measure, one of the three lack-of-skill lines from 12 levels over and on some hooks from 8,
    -- terrible over a 45 percent snap or break, bad only 1 to 11 over, else good or keen
    local levelGap = level - skill
    local noSkill  = feeling == xi.fishing.feeling.NO_SKILL or feeling == xi.fishing.feeling.NO_SKILL_SURE or feeling == xi.fishing.feeling.NO_SKILL_POSITIVE

    if
        fight.bigFish and
        fight.bigFish.epic
    then
        assert(feeling == xi.fishing.feeling.EPIC and tier ~= nil, label .. 'an epic measure on feeling ' .. tostring(feeling))
    elseif levelGap >= 12 then
        assert(noSkill, label .. 'feeling ' .. tostring(feeling) .. ' at ' .. tostring(levelGap) .. ' levels over')
    elseif noSkill then
        assert(levelGap >= 8, label .. 'a lack-of-skill line at ' .. tostring(levelGap) .. ' levels over')
    elseif
        chances.lineSnap >= 45 or
        chances.rodBreak >= 45
    then
        assert(feeling == xi.fishing.feeling.TERRIBLE, label .. 'feeling ' .. tostring(feeling) .. ' over a 45 percent snap or break')
    elseif feeling == xi.fishing.feeling.BAD then
        assert(levelGap >= 1 and levelGap <= 11, label .. 'a bad feeling at ' .. tostring(levelGap) .. ' levels over')
    else
        assert(feeling == xi.fishing.feeling.GOOD or feeling == xi.fishing.feeling.KEEN, label .. 'feeling ' .. tostring(feeling) .. ' with nothing to fear')
    end

    -- A keen sense only on a fish, on a good feeling, within 4 levels counting the rod's keen bonus, and it marks the sense bit
    assert(keen == (feeling == xi.fishing.feeling.KEEN), label .. 'the keen bit and the keen feeling disagree')

    if keen then
        assert(isFish and level - 4 <= skill + (rod.keenBonus or 0), label .. 'a keen sense out of reach')
    end

    -- A measure on a fish with a length range only, inside the range, with the weight from it
    local length = record.length
    if
        isFish and
        length and
        length[2] > 1
    then
        assert(fight.bigFish and fight.bigFish.length >= length[1] and fight.bigFish.length <= length[2], label .. 'the measure is outside the fish\'s range')
        assert(fight.bigFish.weight >= math.floor(fight.bigFish.length * 4.65) and fight.bigFish.weight <= math.floor(fight.bigFish.length * 5.15), label .. 'weight ' .. tostring(fight.bigFish.weight) .. ' off the length')
    else
        assert(fight.bigFish == nil, label .. 'a measure on a catch without a length range')
    end

    -- The hook line for the class, then the feeling line, or the keen sense naming the catch
    local messages = fishingMessages(player)
    local hookLine = xi.fishingMessage.HOOKED_ITEM
    if isFish then
        hookLine = large and xi.fishingMessage.HOOKED_LARGE_FISH or xi.fishingMessage.HOOKED_SMALL_FISH
    end

    local senseLine = keen and xi.fishingMessage.KEEN_ANGLERS_SENSE or xi.fishing.feelingMessages[feeling]

    assert(#messages == 2 and messages[1] == hookLine and messages[2] == senseLine, label .. 'lines ' .. tostring(messages[1]) .. ', ' .. tostring(messages[2]) .. ', expected ' .. tostring(hookLine) .. ', ' .. tostring(senseLine))
end

describe('Fishing minigame retail signatures', function()
    ---@type CClientEntityPair
    local player
    local data

    -- Section 7 of the capture corpus: delay, move, damage, heal and time per rod and species, the modal signature of each pair.
    local signatures =
    {
        { xi.item.BAMBOO_FISHING_ROD,      xi.item.MOAT_CARP_1,     12, 10,  440, 130, 30 },
        { xi.item.BAMBOO_FISHING_ROD,      xi.item.CRAYFISH_1,      15,  7,  660, 190, 30 },
        { xi.item.CARBON_FISHING_ROD,      xi.item.MOAT_CARP_1,     12, 10,  320, 120, 43 },
        { xi.item.CARBON_FISHING_ROD,      xi.item.DARK_BASS_1,      9,  9,  460, 170, 43 },
        { xi.item.CARBON_FISHING_ROD,      xi.item.COPPER_RING,     15,  3,  800, 300, 43 },
        { xi.item.EBISU_FISHING_ROD,       xi.item.MOAT_CARP_1,     12, 10,  320,  80, 30 },
        { xi.item.EBISU_FISHING_ROD,       xi.item.ISTAVRIT_1,       8, 12,  260,  60, 30 },
        { xi.item.EBISU_FISHING_ROD,       xi.item.CHEVAL_SALMON,    9,  8,  420, 100, 30 },
        { xi.item.EBISU_FISHING_ROD,       xi.item.SHINING_TROUT_1,  7, 12,  320,  80, 30 },
        { xi.item.EBISU_FISHING_ROD,       xi.item.GUGRUSAURUS,      7,  5, 1160, 430, 20 },
        { xi.item.FASTWATER_FISHING_ROD,   xi.item.MOAT_CARP_1,     12, 10,  420, 130, 30 },
        { xi.item.FASTWATER_FISHING_ROD,   xi.item.ISTAVRIT_1,       8, 12,  340, 110, 30 },
        { xi.item.HALCYON_FISHING_ROD,     xi.item.MOAT_CARP_1,     12, 10,  320, 110, 41 },
        { xi.item.HALCYON_FISHING_ROD,     xi.item.CRAYFISH_1,      15,  7,  480, 160, 41 },
        { xi.item.HALCYON_FISHING_ROD,     xi.item.CHEVAL_SALMON,    9,  8,  420, 140, 41 },
        { xi.item.HALCYON_FISHING_ROD,     xi.item.SHINING_TROUT_1,  7, 12,  320, 110, 41 },
        { xi.item.HUME_FISHING_ROD,        xi.item.MOAT_CARP_1,     12, 10,  400, 150, 30 },
        { xi.item.HUME_FISHING_ROD,        xi.item.CRAYFISH_1,      15,  7,  600, 220, 30 },
        { xi.item.HUME_FISHING_ROD,        xi.item.ISTAVRIT_1,       7, 14,  320, 120, 20 },
        { xi.item.LU_SHANGS_FISHING_ROD,   xi.item.CRAYFISH_1,      15,  7,  520, 260, 40 },
        { xi.item.LU_SHANGS_FISHING_ROD,   xi.item.ISTAVRIT_1,       8, 12,  280, 140, 40 },
        { xi.item.LU_SHANGS_FISHING_ROD,   xi.item.CHEVAL_SALMON,    9,  8,  460, 230, 40 },
        { xi.item.LU_SHANGS_FISHING_ROD,   xi.item.SHINING_TROUT_1,  7, 12,  340, 170, 40 },
        { xi.item.LU_SHANGS_FISHING_ROD,   xi.item.NEBIMONITE,      11,  6,  660, 330, 40 },
        { xi.item.LU_SHANGS_FISHING_ROD,   xi.item.TRICOLORED_CARP, 14, 13,  400, 200, 40 },
        { xi.item.LU_SHANGS_FISHING_ROD,   xi.item.GOLD_CARP,       12, 15,  380, 190, 40 },
        { xi.item.MITHRAN_FISHING_ROD,     xi.item.MOAT_CARP_1,     10,  9,  400, 130, 20 },
        { xi.item.MITHRAN_FISHING_ROD,     xi.item.CRAYFISH_1,      13,  6,  620, 200, 20 },
        { xi.item.MITHRAN_FISHING_ROD,     xi.item.ISTAVRIT_1,       8, 12,  320, 100, 30 },
        { xi.item.SINGLE_HOOK_FISHING_ROD, xi.item.ISTAVRIT_1,       8, 12,  260, 100, 45 },
        { xi.item.TARUTARU_FISHING_ROD,    xi.item.MOAT_CARP_1,     12, 10,  400, 140, 30 },
        { xi.item.TARUTARU_FISHING_ROD,    xi.item.CRAYFISH_1,      15,  7,  620, 210, 30 },
        { xi.item.WILLOW_FISHING_ROD,      xi.item.MOAT_CARP_1,     12, 10,  480, 120, 30 },
        { xi.item.WILLOW_FISHING_ROD,      xi.item.CRAYFISH_1,      15,  7,  720, 180, 30 },
        { xi.item.YEW_FISHING_ROD,         xi.item.MOAT_CARP_1,     12, 10,  460, 120, 30 },
    }

    -- Section 12: the gauge at skill 98 on Ebisu at a stamina roll of 100, one less per point of roll, 61 to 87 over the fish.
    -- The rows scatter about 5 either side of the fitted slope: at 77 and 78 over retail itself sent 80 and 85.
    local drains =
    {
        { xi.item.SHINING_TROUT_1, 65 },
        { xi.item.CHEVAL_SALMON,   48 },
        { xi.item.ISTAVRIT_1,      43 },
        { xi.item.MOAT_CARP_1,     42 },
    }

    before_each(function()
        data   = xi.fishing.getData()
        player = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE })

        xi.test.world:setVanaTime(12, 0)
        xi.test.world:setSeed(1)
        player:setSkillLevel(xi.skill.FISHING, 10)
    end)

    it('sends the delay, move, damage, heal and time the corpus saw on every rod and species pair', function()
        for _, row in ipairs(signatures) do
            local rodId, itemId, delay, move, damage, heal, time = unpack(row)
            local fight = xi.fishing.hookCatch(player, castOn(data, rodId, xi.item.LITTLE_WORM), hookedCatch(data, itemId))
            if not fight then
                error('No fight row for rod ' .. tostring(rodId) .. ' and catch ' .. tostring(itemId))
            end

            local keen  = bit.band(fight.angler_sense, 2) == 2
            local label = tostring(data.rods[rodId].name) .. ' on ' .. tostring(data.fish[itemId].name) .. ': '

            assert(fight.arrow_delay == delay and fight.move_frequency == move, label .. 'd' .. tostring(fight.arrow_delay) .. ' m' .. tostring(fight.move_frequency) .. ', retail d' .. tostring(delay) .. ' m' .. tostring(move))
            assert(fight.arrow_damage == damage, label .. 'damage ' .. tostring(fight.arrow_damage) .. ', retail ' .. tostring(damage))
            assert(fight.arrow_regen == (keen and math.floor(heal * 7 / 10) or heal), label .. 'heal ' .. tostring(fight.arrow_regen) .. ', retail ' .. tostring(heal))
            assert(fight.time == time, label .. 'time ' .. tostring(fight.time) .. ', retail ' .. tostring(time))

            player.packets:clear()
        end
    end)

    it('drains the gauge at skill 98 on Ebisu within 5 of the corpus, read at a roll of 100', function()
        player:setSkillLevel(xi.skill.FISHING, 980)

        for _, row in ipairs(drains) do
            local itemId, retail = unpack(row)
            local fight          = xi.fishing.hookCatch(player, castOn(data, xi.item.EBISU_FISHING_ROD, xi.item.LITTLE_WORM), hookedCatch(data, itemId))
            if not fight then
                error('No fight row for rod ' .. tostring(xi.item.EBISU_FISHING_ROD) .. ' and catch ' .. tostring(itemId))
            end

            local roll           = fight.stamina / math.floor((data.fish[itemId].skill + 36) / 2)
            local atHundred      = fight.regen + roll - 100

            assert(math.abs(atHundred - retail) <= 5, tostring(data.fish[itemId].name) .. ': regen ' .. tostring(atHundred) .. ' at a roll of 100, retail ' .. tostring(retail))

            player.packets:clear()
        end
    end)
end)

describe('Fishing minigame across the catalog', function()
    ---@type CClientEntityPair
    local player
    local data

    before_each(function()
        data   = xi.fishing.getData()
        player = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE })

        xi.test.world:setVanaTime(12, 0)
    end)

    it('has a fight row for every rod and catch, and a catalog row for every fight row', function()
        local names = {}
        for name, itemId in pairs(xi.item) do
            names[itemId] = name
        end

        local missing = {}
        for _, rodId in ipairs(sortedIds(data.rods)) do
            if not xi.fishing.rodStats[rodId] then
                table.insert(missing, 'no fight row for ' .. tostring(names[rodId]))
            end
        end

        for _, itemId in ipairs(sortedIds(data.fish)) do
            if not xi.fishing.catchStats[itemId] then
                table.insert(missing, 'no fight row for ' .. tostring(names[itemId]))
            end
        end

        for _, rodId in ipairs(sortedIds(xi.fishing.rodStats)) do
            if not data.rods[rodId] then
                table.insert(missing, 'no catalog rod for ' .. tostring(names[rodId]))
            end
        end

        for _, itemId in ipairs(sortedIds(xi.fishing.catchStats)) do
            if not data.fish[itemId] then
                table.insert(missing, 'no catalog catch for ' .. tostring(names[itemId]))
            end
        end

        assert(#missing == 0, table.concat(missing, '; '))
    end)

    it('holds every fight to its bounds on every rod and catch at skills 1 to 100', function()
        local fishIds = sortedIds(data.fish)
        local seed    = 0

        for _, rodId in ipairs(sortedIds(data.rods)) do
            local cast = castOn(data, rodId, xi.item.LITTLE_WORM)

            for skill = 1, 100, 9 do
                player:setSkillLevel(xi.skill.FISHING, skill * 10)

                for _, itemId in ipairs(fishIds) do
                    seed = seed + 1
                    xi.test.world:setSeed(seed)

                    local catch = hookedCatch(data, itemId)
                    local fight = xi.fishing.hookCatch(player, cast, catch)

                    checkFight(player, data, cast, catch, skill, fight)
                    player.packets:clear()
                end
            end
        end
    end)
end)

describe('Fishing minigame fish ladder', function()
    ---@type CClientEntityPair
    local player
    local data

    -- A fish at every level 1 to 100 on the catalog's rods and baits: small on the odd levels, large on the even, no measure,
    -- and one middling fight row for all, set on the fight table for the test. The ids sit above every item.
    local function ladderCatalog()
        local ladder = { fish = {}, rods = data.rods, baits = data.baits, zones = data.zones }

        for level = 1, 100 do
            assert(xi.fishing.catchStats[60000 + level] == nil, 'Expected no fight row at id ' .. tostring(60000 + level))

            xi.fishing.catchStats[60000 + level] = { arrowDamage = 400, arrowDelay = 13, moveFrequency = 2, rank = 10 }
            ladder.fish[60000 + level]           =
            {
                name  = 'ladder fish ' .. tostring(level),
                size  = level % 2 == 0 and xi.fishingSize.LARGE or xi.fishingSize.SMALL,
                skill = level,
            }
        end

        return ladder
    end

    before_each(function()
        data   = xi.fishing.getData()
        player = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE })

        xi.test.world:setVanaTime(12, 0)
    end)

    after_each(function()
        for level = 1, 100 do
            xi.fishing.catchStats[60000 + level] = nil
        end
    end)

    it('drives the gauge, the lose from skill and the keen sense by the gap, at every skill and level 1 to 100', function()
        local ladder = ladderCatalog()
        local seed   = 100000

        for _, rodId in ipairs({ xi.item.WILLOW_FISHING_ROD, xi.item.MITHRAN_FISHING_ROD, xi.item.EBISU_FISHING_ROD }) do
            local cast = castOn(ladder, rodId, xi.item.LITTLE_WORM)

            for skill = 1, 100 do
                player:setSkillLevel(xi.skill.FISHING, skill * 10)

                for level = 1, 100 do
                    seed = seed + 1
                    xi.test.world:setSeed(seed)

                    local catch = hookedCatch(ladder, 60000 + level)
                    local fight = xi.fishing.hookCatch(player, cast, catch)
                    if not fight then
                        error('No fight row for rod ' .. tostring(rodId) .. ' and catch ' .. tostring(60000 + level))
                    end

                    local gap   = level - skill

                    checkFight(player, ladder, cast, catch, skill, fight)

                    -- The lose from a lack of skill, the only lose a legendary rod carries: past 7 over, 0.8 a level, cap 25
                    if rodId == xi.item.EBISU_FISHING_ROD then
                        local lowSkill = 0
                        if gap > 7 then
                            lowSkill = math.min(25, math.floor((gap - 7) * 0.8))
                        end

                        assert(fight.chances.lose == lowSkill, 'Ebisu at skill ' .. tostring(skill) .. ' on level ' .. tostring(level) .. ': lose ' .. tostring(fight.chances.lose) .. ', expected ' .. tostring(lowSkill))
                        assert(lowSkill == 0 or fight.chances.loseReason == xi.fishing.failure.LOW_SKILL, 'Ebisu at skill ' .. tostring(skill) .. ' on level ' .. tostring(level) .. ': the lose is not from skill')
                    end

                    player.packets:clear()
                end
            end
        end
    end)
end)

describe('Fishing claim on every rod', function()
    ---@type CClientEntityPair
    local player
    local data

    -- The five species the corpus measured across rods
    local species =
    {
        xi.item.MOAT_CARP_1,
        xi.item.CRAYFISH_1,
        xi.item.ISTAVRIT_1,
        xi.item.CHEVAL_SALMON,
        xi.item.SHINING_TROUT_1,
    }

    -- The chances a fight carries on the rod and catch, with the lines it sent dropped
    local function chancesOn(rodId, itemId)
        local fight = xi.fishing.hookCatch(player, castOn(data, rodId, xi.item.LITTLE_WORM), hookedCatch(data, itemId))

        if not fight then
            error('No fight row for rod ' .. tostring(rodId) .. ' and catch ' .. tostring(itemId))
        end

        player.packets:clear()

        return fight.chances
    end

    before_each(function()
        data   = xi.fishing.getData()
        player = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE })

        xi.test.world:setVanaTime(12, 0)
        stubMeters()
    end)

    it('breaks the Lu Shang\'s only on the legendaries the JP wiki lists, and snaps its line on the coral fragment', function()
        player:setSkillLevel(xi.skill.FISHING, 1000)

        -- The wiki's fourteen, less the three Abyssea dragons the catalog does not carry
        local breakers =
        {
            [xi.item.ABAIA          ] = true,
            [xi.item.CAVE_CHERAX    ] = true,
            [xi.item.GERROTHORAX    ] = true,
            [xi.item.GUGRUSAURUS    ] = true,
            [xi.item.HAKURYU        ] = true,
            [xi.item.LIK            ] = true,
            [xi.item.MATSYA         ] = true,
            [xi.item.MOLA_MOLA      ] = true,
            [xi.item.PIRARUCU       ] = true,
            [xi.item.RYUGU_TITAN    ] = true,
            [xi.item.TITANIC_SAWFISH] = true,
        }

        for itemId in pairs(breakers) do
            assert(chancesOn(xi.item.LU_SHANGS_FISHING_ROD, itemId).rodBreak > 0, 'Expected ' .. data.fish[itemId].name .. ' to break the rod')
        end

        -- Nothing a zone pools breaks it otherwise, the Tricorn and Giant Chirai the wiki names among them
        local pooled = {}
        for _, zone in pairs(data.zones) do
            for _, area in pairs(zone.areas) do
                for _, itemId in ipairs(area.pool) do
                    pooled[itemId] = true
                end
            end
        end

        assert(pooled[xi.item.TRICORN] and pooled[xi.item.GIANT_CHIRAI], 'Expected the two named non-breakers in a pool')

        for itemId in pairs(pooled) do
            if not breakers[itemId] then
                assert(chancesOn(xi.item.LU_SHANGS_FISHING_ROD, itemId).rodBreak == 0, 'Expected ' .. data.fish[itemId].name .. ' to leave the rod whole')
            end
        end

        local coral = chancesOn(xi.item.LU_SHANGS_FISHING_ROD, xi.item.CORAL_FRAGMENT)

        assert(coral.lineSnap > 0 and coral.rodBreak == 0, 'Expected the coral fragment to cut the line and spare the rod')
    end)

    it('resolves a claim into the first failure its chances carry, and lands the catch when they carry none', function()
        local original = math.randomInt
        local forced   = nil

        -- The fight rolls as it likes; the claim rolls what the test sets
        stub('math.randomInt', function(low, high)
            if forced then
                return forced
            end

            return original(low, high)
        end)

        local seed = 200000
        for _, rodId in ipairs(sortedIds(data.rods)) do
            for _, skill in ipairs({ 1, 20, 50, 100 }) do
                player:setSkillLevel(xi.skill.FISHING, skill * 10)

                for _, itemId in ipairs(species) do
                    seed = seed + 1
                    xi.test.world:setSeed(seed)

                    local cast = castOn(data, rodId, xi.item.LITTLE_WORM)
                    cast.catch = hookedCatch(data, itemId)
                    cast.fight = xi.fishing.hookCatch(player, cast, cast.catch)
                    cast.stage = xi.fishing.stage.FIGHTING
                    player.packets:clear()

                    local chances  = cast.fight.chances
                    local expected = xi.fishing.result.CAUGHT
                    if chances.lose > 0 then
                        expected = chances.loseReason == xi.fishing.failure.LOW_SKILL and xi.fishing.result.LOW_SKILL or xi.fishing.result.LOST
                    elseif chances.lineSnap > 0 then
                        expected = xi.fishing.result.LINE_BREAK
                    elseif chances.rodBreak > 0 then
                        expected = xi.fishing.result.ROD_BREAK
                    end

                    -- Every roll lands on 1, so the first chance above zero is met
                    forced = 1
                    local result = xi.fishing.resolveCatch(player, cast, 0, cast.fight.intuition)
                    forced = nil

                    local label    = tostring(data.rods[rodId].name) .. ' on ' .. tostring(data.fish[itemId].name) .. ' at skill ' .. tostring(skill) .. ': '
                    local messages = fishingMessages(player)

                    assert(result == expected, label .. 'resolved to ' .. tostring(result) .. ', expected ' .. tostring(expected))

                    if result == xi.fishing.result.LOST then
                        assert(cast.lossReason == chances.loseReason, label .. 'the loss carries the wrong reason')
                        assert(messages[#messages] == xi.fishing.lostMessages[chances.loseReason], label .. 'the lost line does not name the reason')
                        assert(player:getAnimation() == xi.animation.NEW_FISHING_STOP, label .. 'wrong animation on a loss')
                    elseif result == xi.fishing.result.LOW_SKILL then
                        assert(messages[#messages] == xi.fishingMessage.LOST_LOW_SKILL, label .. 'no lack of skill line')
                        assert(player:getAnimation() == xi.animation.NEW_FISHING_STOP, label .. 'wrong animation on a rolled lack of skill')
                    elseif result == xi.fishing.result.LINE_BREAK then
                        assert(messages[#messages] == xi.fishingMessage.LINE_BREAK, label .. 'no line break line')
                        assert(player:getAnimation() == xi.animation.NEW_FISHING_LINE_BREAK, label .. 'wrong animation on a line break')
                    elseif result == xi.fishing.result.ROD_BREAK then
                        assert(messages[#messages] == xi.fishingMessage.ROD_BREAK, label .. 'no rod break line')
                        assert(player:getAnimation() == xi.animation.NEW_FISHING_ROD_BREAK, label .. 'wrong animation on a rod break')
                    else
                        assert(player:hasItem(itemId), label .. 'the catch is not in the inventory')
                        assert(player:getAnimation() == xi.animation.NEW_FISHING_CAUGHT, label .. 'wrong animation on a catch')
                        player:delItem(itemId, 1)
                    end

                    player.packets:clear()
                end
            end
        end
    end)

    it('loses to the wrong size where retail did and nowhere else, at the corpus anglers\' skill', function()
        player:setSkillLevel(xi.skill.FISHING, 80)

        assert(chancesOn(xi.item.HUME_FISHING_ROD, xi.item.ISTAVRIT_1).loseReason == xi.fishing.failure.LOST_BIG, 'Expected the Hume rod to lose the istavrit to its size, as retail did 43 times in 110')
        -- The corpus counts the Mithran rod's 81 size losses over the moat carp and the crayfish together, so only the carp is asserted
        assert(chancesOn(xi.item.MITHRAN_FISHING_ROD, xi.item.MOAT_CARP_1).loseReason == xi.fishing.failure.LOST_SMALL, 'Expected the Mithran rod to lose the moat carp to its size, as retail did 81 times in 482 with the crayfish')

        local singleHook = chancesOn(xi.item.SINGLE_HOOK_FISHING_ROD, xi.item.ISTAVRIT_1)
        assert(singleHook.loseReason ~= xi.fishing.failure.LOST_BIG and singleHook.loseReason ~= xi.fishing.failure.LOST_SMALL, 'Expected the Single Hook rod to hold the istavrit, as retail did 147 times in 149')

        -- The Fastwater rod is flagged against neither size, so it loses nothing to one
        local fastwater = chancesOn(xi.item.FASTWATER_FISHING_ROD, xi.item.ISTAVRIT_1)
        assert(fastwater.loseReason ~= xi.fishing.failure.LOST_BIG and fastwater.loseReason ~= xi.fishing.failure.LOST_SMALL, 'Expected the Fastwater rod to hold the istavrit, as retail did 155 times in 155')

        for _, rodId in ipairs({ xi.item.LU_SHANGS_FISHING_ROD, xi.item.EBISU_FISHING_ROD }) do
            for _, itemId in ipairs(species) do
                local chances = chancesOn(rodId, itemId)

                assert(chances.loseReason ~= xi.fishing.failure.LOST_BIG and chances.loseReason ~= xi.fishing.failure.LOST_SMALL, 'Expected ' .. tostring(data.rods[rodId].name) .. ' to hold ' .. tostring(data.fish[itemId].name) .. ', as retail held 612 in 612')
            end
        end
    end)

    -- The captures reel ordinary catches at most 6 ranks over the rod and never break a line there, while a legendary catch broke
    -- one at 1 and 2 over. Both ends are pinned here: the held window, the legendary rates, and a rod far enough past its rank
    -- that the mechanic still bites, which no capture reaches.
    it('holds the line as far over the rod as the captures reeled, and snaps past it', function()
        player:setSkillLevel(xi.skill.FISHING, 80)

        assert(chancesOn(xi.item.HUME_FISHING_ROD, xi.item.ISTAVRIT_1).lineSnap == 0, 'Expected the Hume rod to hold the istavrit 6 ranks over, as retail did 110 times in 110')
        assert(chancesOn(xi.item.YEW_FISHING_ROD, xi.item.MOAT_CARP_1).lineSnap == 0, 'Expected the Yew rod to hold the moat carp a rank over, as retail did 200 times in 200')

        player:setSkillLevel(xi.skill.FISHING, 300)

        assert(chancesOn(xi.item.MITHRAN_FISHING_ROD, xi.item.JUNGLE_CATFISH).lineSnap == 0, 'Expected the Mithran rod to hold the jungle catfish 5 ranks over, as retail did 28 times in 28')

        -- A rank 23 fish on a rank 5 rod is 12 past the grace: nothing in the captures goes there, and the line has to go
        assert(chancesOn(xi.item.WILLOW_FISHING_ROD, xi.item.ZEBRA_EEL).lineSnap == 55, 'Expected the Willow rod to snap on a zebra eel 18 ranks over')

        player:setSkillLevel(xi.skill.FISHING, 1000)

        assert(chancesOn(xi.item.EBISU_FISHING_ROD, xi.item.CAVE_CHERAX).lineSnap == 17, 'Expected 17 percent a rank over on Ebisu, as retail broke 41 of 256')
        assert(chancesOn(xi.item.EBISU_FISHING_ROD, xi.item.LIK).lineSnap == 34, 'Expected 34 percent two ranks over on Ebisu, as retail broke 24 of 68')
    end)
end)

describe('Fishing bait sweep', function()
    ---@type CClientEntityPair
    local player
    local data

    -- A whole-zone pool of every ungated fish and item in the catalog, so the bait's affinity alone decides what bites
    local function openPool()
        local pool = {}
        for _, itemId in ipairs(sortedIds(data.fish)) do
            local record = data.fish[itemId]
            if
                not record.keyItem and
                not record.quest
            then
                table.insert(pool, itemId)
            end
        end

        return { areas = { whole_zone = { pool = pool } }, monsters = {} }
    end

    before_each(function()
        data   = xi.fishing.getData()
        player = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE })

        xi.test.world:setVanaTime(12, 0)
        stubMeters()
    end)

    it('offers every bait the fish of its affinity in the pool and nothing outside it, and hooks within its count', function()
        local zone = openPool()
        local seed = 300000

        for _, baitId in ipairs(sortedIds(data.baits)) do
            local bait = data.baits[baitId]
            local cast = castOn(data, xi.item.WILLOW_FISHING_ROD, baitId)

            cast.zone     = zone
            cast.area     = zone.areas.whole_zone
            cast.areaName = 'whole_zone'

            local buckets = xi.fishing.biteBuckets(player, cast, data)
            local offered = {}

            for _, entry in ipairs(buckets.entries[xi.fishing.catchType.FISH]) do
                assert(bait.affinity[entry[1]], tostring(bait.name) .. ' offers ' .. tostring(data.fish[entry[1]].name) .. ' outside its affinity')
                offered[entry[1]] = true
            end

            for _, itemId in ipairs(zone.areas.whole_zone.pool) do
                local record = data.fish[itemId]
                if
                    not record.item and
                    bait.affinity[itemId]
                then
                    assert(offered[itemId], tostring(bait.name) .. ' does not offer ' .. tostring(record.name))
                end
            end

            assert(buckets.fishId == nil or bait.affinity[buckets.fishId], tostring(bait.name) .. ' drew a fish outside its affinity')

            for _ = 1, 5 do
                seed = seed + 1
                xi.test.world:setSeed(seed)

                local catch = xi.fishing.rollBite(player, cast, data)
                if
                    catch and
                    catch.type == xi.fishing.catchType.FISH
                then
                    local rig = (bait.maxHook or 1) > 1 and (catch.record.maxHook or 1) > 1

                    assert(bait.affinity[catch.itemId], tostring(bait.name) .. ' hooked ' .. tostring(catch.record.name) .. ' outside its affinity')
                    assert(catch.count >= 1 and catch.count <= (rig and bait.maxHook or 1), tostring(bait.name) .. ' hooked ' .. tostring(catch.count) .. ' of ' .. tostring(catch.record.name))
                end
            end
        end
    end)

    it('loses every bait to a give-up and every lure only to a broken line', function()
        for _, baitId in ipairs(sortedIds(data.baits)) do
            local bait = data.baits[baitId]

            player:addItem(baitId)
            player:equipItem(baitId, nil, xi.slot.AMMO)

            assert(player:getEquipID(xi.slot.AMMO) == baitId, 'Expected ' .. tostring(bait.name) .. ' on the ammo slot')

            local cast = castOn(data, xi.item.WILLOW_FISHING_ROD, baitId)
            cast.catch = hookedCatch(data, xi.item.MOAT_CARP_1)
            cast.fight = xi.fishing.hookCatch(player, cast, cast.catch)
            cast.stage = xi.fishing.stage.FIGHTING

            xi.fishing.resolveCatch(player, cast, 200, 0)

            local kept = player:getEquipID(xi.slot.AMMO) == baitId

            assert(kept == (bait.type == xi.fishingBaitType.LURE), tostring(bait.name) .. (kept and ' stayed on the hook through a give-up' or ' was lost to a give-up'))

            if kept then
                xi.fishing.resolveCatch(player, cast, 100, 0)

                assert(player:getEquipID(xi.slot.AMMO) ~= baitId, tostring(bait.name) .. ' survived a broken line')
            end

            player.packets:clear()
        end
    end)
end)

describe('Fishing skill-up table', function()
    ---@type CClientEntityPair
    local player

    -- The corpus rate by how far the fish sits over the angler, damped by the angler's own skill: 3 percent one over, 16 at
    -- two, peaking at 34 from 8 to 11 over, 14 past 30, nothing at or under the angler or past 50 over
    local function chanceAt(gap, level)
        if gap < 1 then
            return 0
        end

        local base = 14
        if gap == 1 then
            base = 3
        elseif gap == 2 then
            base = 16
        elseif gap <= 4 then
            base = 21
        elseif gap <= 7 then
            base = 27
        elseif gap <= 11 then
            base = 34
        elseif gap <= 19 then
            base = 29
        elseif gap <= 29 then
            base = 16
        elseif gap > 50 then
            base = 0
        end

        return math.floor(base * (108 - math.floor(level * 4 / 5)) / 100)
    end

    -- A landed moat carp claimed at the level given, as the release reads it
    local function landedAt(level)
        return
        {
            catch   = { type = xi.fishing.catchType.FISH, itemId = xi.item.MOAT_CARP_1, record = { skill = level } },
            result  = xi.fishing.result.CAUGHT,
            claimed = true,
        }
    end

    -- The same carp 10 over, claimed and then ended as the result and the loss reason given
    local function raisesOn(result, reason)
        local cast = landedAt(60)

        cast.result     = result
        cast.lossReason = reason

        player:setSkillLevel(xi.skill.FISHING, 500)
        xi.fishing.rollSkillUp(player, cast)

        return player:getCharSkillLevel(xi.skill.FISHING) > 500
    end

    before_each(function()
        player = xi.test.world:spawnPlayer()

        xi.test.world:setSetting('map.FISHING_SKILL_MULTIPLIER', 1)
        xi.test.world:setSetting('map.FISHING_SKILLUP_ON_FAILURE', true)

        -- Rank 10 lifts the guild cap past the ladder
        player:setSkillRank(xi.skill.FISHING, 10)
    end)

    it('raises the skill at the captured rate for every gap from 4 under to 60 over, and only on a roll within it', function()
        local forced = 1
        stub('math.randomInt', function()
            return forced
        end)

        for gap = -4, 60 do
            local cast   = landedAt(50 + gap)
            local chance = chanceAt(gap, 50)

            if chance > 0 then
                player:setSkillLevel(xi.skill.FISHING, 500)
                forced = chance
                xi.fishing.rollSkillUp(player, cast)

                assert(player:getCharSkillLevel(xi.skill.FISHING) == 501, 'Expected a tenth at gap ' .. tostring(gap) .. ' on a roll of ' .. tostring(chance) .. ', got ' .. tostring(player:getCharSkillLevel(xi.skill.FISHING)))
            end

            player:setSkillLevel(xi.skill.FISHING, 500)
            forced = chance + 1
            xi.fishing.rollSkillUp(player, cast)

            assert(player:getCharSkillLevel(xi.skill.FISHING) == 500, 'Expected no skill-up at gap ' .. tostring(gap) .. ' on a roll of ' .. tostring(chance + 1))
        end
    end)

    it('raises the rate by the Fisherman\'s Feast percent, rounded to the nearest point', function()
        local forced = 20
        stub('math.randomInt', function()
            return forced
        end)

        -- Doubled, the 10 at 2 over is met by a roll of 20
        player:setSkillLevel(xi.skill.FISHING, 500)
        player:setMod(xi.mod.FISHING_SKILL_GAIN, 100)
        xi.fishing.rollSkillUp(player, landedAt(52))

        assert(player:getCharSkillLevel(xi.skill.FISHING) == 501, 'Expected the doubled rate to take a roll of 20')

        player:setSkillLevel(xi.skill.FISHING, 500)
        player:setMod(xi.mod.FISHING_SKILL_GAIN, 0)
        xi.fishing.rollSkillUp(player, landedAt(52))

        assert(player:getCharSkillLevel(xi.skill.FISHING) == 500, 'Expected the plain rate to miss a roll of 20')

        -- The feast's own 5 percent lifts the 23 at 10 over to 24
        forced = 24
        player:setSkillLevel(xi.skill.FISHING, 500)
        player:setMod(xi.mod.FISHING_SKILL_GAIN, 5)
        xi.fishing.rollSkillUp(player, landedAt(60))

        assert(player:getCharSkillLevel(xi.skill.FISHING) == 501, 'Expected the feast to take a roll of 24')

        player:setSkillLevel(xi.skill.FISHING, 500)
        player:setMod(xi.mod.FISHING_SKILL_GAIN, 0)
        xi.fishing.rollSkillUp(player, landedAt(60))

        assert(player:getCharSkillLevel(xi.skill.FISHING) == 500, 'Expected the plain rate to miss a roll of 24')
    end)

    it('gives two tenths on half the rolls from 28 over, and one under it', function()
        stub('math.randomInt', 1)

        player:setSkillLevel(xi.skill.FISHING, 500)
        xi.fishing.rollSkillUp(player, landedAt(78))

        assert(player:getCharSkillLevel(xi.skill.FISHING) == 502, 'Expected two tenths at 28 over, the first gap the captures show one at')

        player:setSkillLevel(xi.skill.FISHING, 500)
        xi.fishing.rollSkillUp(player, landedAt(77))

        assert(player:getCharSkillLevel(xi.skill.FISHING) == 501, 'Expected one tenth at 27 over, under the two tenths band')
    end)

    it('earns skill on a catch lost to its size and on nothing else', function()
        stub('math.randomInt', 1)

        assert(raisesOn(xi.fishing.result.LOST, xi.fishing.failure.LOST_SMALL), 'Expected a catch too small for the rod to raise the skill, as retail did 235 times in 1037')
        assert(raisesOn(xi.fishing.result.LOST, xi.fishing.failure.LOST_BIG), 'Expected a catch too big for the rod to raise the skill beside it')
        assert(not raisesOn(xi.fishing.result.LOST, nil), 'Expected a claim lost to nothing named to raise nothing')
        assert(not raisesOn(xi.fishing.result.LINE_BREAK, nil), 'Expected a broken line to raise nothing, as retail did once in 89')
        assert(not raisesOn(xi.fishing.result.ROD_BREAK, nil), 'Expected a broken rod to raise nothing')
        assert(not raisesOn(xi.fishing.result.GAVE_UP, nil), 'Expected a give-up to raise nothing, as retail did in 7727')
        assert(not raisesOn(xi.fishing.result.LOW_SKILL, nil), 'Expected a lack-of-skill loss to raise nothing, as retail did twice in 471')
    end)
end)
