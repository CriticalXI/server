-- Check the large bit and the regen gauge against the plateau, the drain and the rise from 28 levels under
local function checkGauge(context)
    local fight = context.fight
    local label = context.label

    assert((bit.band(fight.angler_sense, 1) == 1) == context.large, label .. 'angler sense ' .. tostring(fight.angler_sense) .. ' has the large bit wrong')

    if context.tier then
        assert(fight.regen > 128, label .. 'regen ' .. tostring(fight.regen) .. ' on a legendary catch is not over the bias')
    elseif context.gap >= (context.rod.drainStart or 12) then
        -- The drain alone carries the stamina roll, so it is read back at a roll of 100
        local gauge = fight.regen + context.roll - 100

        assert(gauge <= 128 and gauge >= (context.isFish and 42 or 30), label .. 'gauge ' .. tostring(gauge) .. ' at a roll of 100, ' .. tostring(context.gap) .. ' levels over the catch')
    elseif
        context.isFish and
        context.gap <= -28
    then
        assert(fight.regen > 128, label .. 'regen ' .. tostring(fight.regen) .. ' at ' .. tostring(-context.gap) .. ' levels under the catch does not rise')
    else
        assert(fight.regen == 128, label .. 'regen ' .. tostring(fight.regen) .. ' off the plateau at gap ' .. tostring(context.gap))
    end
end

-- Intuition is 10 plus 2 per ten points of skill and 50 more on a keen sense, with the hour off 5 and 17 and no gear worn
local function checkIntuition(context)
    local fight         = context.fight
    local intuitionBase = 10 + 2 * math.floor(context.skill / 10) + (context.keen and 50 or 0)
    local moon          = getVanadielMoonCycle()
    local moonExtras    = { 0 }

    -- A new or full moon adds 10 or 20, and a quarter moon adds 5 or 10
    if
        moon == xi.moonCycle.NEW_MOON or
        moon == xi.moonCycle.FULL_MOON
    then
        moonExtras = { 10, 20 }
    elseif
        moon == xi.moonCycle.FIRST_QUARTER or
        moon == xi.moonCycle.THIRD_QUARTER
    then
        moonExtras = { 5, 10 }
    end

    local explained = false
    for _, moonExtra in ipairs(moonExtras) do
        if fight.intuition == intuitionBase + moonExtra then
            explained = true
        end
    end

    assert(explained, context.label .. 'intuition ' .. tostring(fight.intuition) .. ' outside its terms from ' .. tostring(intuitionBase))
end

-- Check the lack-of-skill, snap, break and size chances stay in range and come only from the rules that give them
local function checkChances(context)
    local chances = context.fight.chances
    local cast    = context.cast
    local label   = context.label
    local stats   = xi.fishing.catchStats[context.itemId]
    local breaks  = (cast.rodId == xi.item.LU_SHANGS_FISHING_ROD or cast.rodId == xi.item.LU_SHANGS_FISHING_ROD_P1) and xi.fishing.luShangBreaks or nil

    for _, name in ipairs({ 'lowSkill', 'lineSnap', 'rodBreak', 'sizeLoss' }) do
        assert(chances[name] >= 0 and chances[name] <= 100, label .. name .. ' ' .. tostring(chances[name]))
    end

    assert((chances.sizeLoss > 0) == (chances.lostAs ~= nil), label .. 'size loss ' .. tostring(chances.sizeLoss) .. ' lost as ' .. tostring(chances.lostAs))
    assert(cast.rod.breaksTo ~= nil or chances.rodBreak == 0, label .. 'a rod with no broken form carries a break chance')

    -- Nothing is lost to lack of skill under 20 over, and nothing but a fish is
    if
        not context.isFish or
        context.level - context.skill < 20
    then
        assert(chances.lowSkill == 0, label .. 'a lack-of-skill chance of ' .. tostring(chances.lowSkill) .. ' at ' .. tostring(context.level - context.skill) .. ' over')
    end

    -- A catch over the rod's hold (strength plus half the skill) fails at 3 percent a level over: a starter rod, a large catch or
    -- junk breaks the rod, a small fish snaps the line; a catch's own snap rate and Lu Shang's list sit on top, and the doubt
    -- lines scale the result
    local rod     = context.rod
    local weight  = stats.weight or context.level
    local over    = 0
    local feeling = context.fight.feeling

    if
        rod.strength and
        weight > rod.strength + math.floor(context.skill / 2)
    then
        over = math.min(100, (weight - rod.strength - math.floor(context.skill / 2)) * 3)
    end

    local breaksRod     = rod.strength ~= nil and (rod.strength < 35 or context.large or not context.isFish)
    local expectedBreak = (breaks and breaks[context.itemId]) or (breaksRod and over or 0)
    local expectedSnap  = math.max(breaksRod and 0 or over, stats.lineSnap or 0)

    if feeling == xi.fishing.feeling.NO_SKILL_SURE then
        expectedSnap = math.min(100, expectedSnap * 3)
    elseif feeling == xi.fishing.feeling.NO_SKILL then
        expectedSnap = math.floor(expectedSnap / 10)
    end

    assert(chances.rodBreak == expectedBreak, label .. 'a break chance of ' .. tostring(chances.rodBreak) .. ', expected ' .. tostring(expectedBreak))
    assert(chances.lineSnap == expectedSnap, label .. 'a snap chance of ' .. tostring(chances.lineSnap) .. ', expected ' .. tostring(expectedSnap))
end

-- Check the feeling against the measure, the level gap and the snap and break chances, and the keen sense against its reach
local function checkFeeling(context)
    local fight    = context.fight
    local feeling  = fight.feeling
    local label    = context.label
    local levelGap = context.level - context.skill
    local noSkill  = feeling == xi.fishing.feeling.NO_SKILL or feeling == xi.fishing.feeling.NO_SKILL_SURE or feeling == xi.fishing.feeling.NO_SKILL_POSITIVE
    local chances  = fight.chances

    -- Epic on an epic measure, lack of skill from 12 levels over and on some hooks from 8, terrible over a 45 percent snap or break
    if
        fight.bigFish and
        fight.bigFish.epic
    then
        assert(feeling == xi.fishing.feeling.EPIC and context.tier ~= nil, label .. 'an epic measure on feeling ' .. tostring(feeling))
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

    -- A keen sense is only on a fish within 4 levels counting the rod's keen bonus, and it sets the sense bit
    assert(context.keen == (feeling == xi.fishing.feeling.KEEN), label .. 'the keen bit and the keen feeling disagree')

    if context.keen then
        assert(context.isFish and context.level - 4 <= context.skill + (context.rod.keenBonus or 0), label .. 'a keen sense out of reach')
    end
end

-- A fish with a length range carries a measure inside it with the weight from the length, and nothing else carries one
local function checkMeasure(context)
    local fight  = context.fight
    local label  = context.label
    local length = context.record.length

    if
        context.isFish and
        length and
        length[2] > 1
    then
        assert(fight.bigFish and fight.bigFish.length >= length[1] and fight.bigFish.length <= length[2], label .. 'the measure is outside the fish\'s range')
        assert(fight.bigFish.weight >= math.floor(fight.bigFish.length * 4.65) and fight.bigFish.weight <= math.floor(fight.bigFish.length * 5.15), label .. 'weight ' .. tostring(fight.bigFish.weight) .. ' off the length')
    else
        assert(fight.bigFish == nil, label .. 'a measure on a catch without a length range')
    end
end

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

    local context =
    {
        fight  = fight,
        cast   = cast,
        record = record,
        itemId = catch.itemId,
        skill  = skill,
        level  = level,
        gap    = gap,
        rod    = rod,
        tier   = tier,
        large  = large,
        isFish = isFish,
        keen   = keen,
        roll   = roll,
        label  = label,
    }

    checkGauge(context)
    checkIntuition(context)
    checkChances(context)
    checkFeeling(context)
    checkMeasure(context)

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

            xi.fishing.catchStats[60000 + level] = { arrowDamage = 400, arrowDelay = 13, moveFrequency = 2 }
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

    it('drives the gauge, the loss to lack of skill and the keen sense by the gap, at every skill and level 1 to 100', function()
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

                    -- The loss to lack of skill on every rod, from the ledger's Table 4: none under 20 over, a large fish 80 at 20 rising
                    -- to 100 by 45, a small fish 5 from 25, 70 from 45 and 100 from 50
                    local lowSkill = 0
                    if
                        gap >= 20 and
                        catch.record.size == xi.fishingSize.LARGE
                    then
                        lowSkill = math.min(100, 80 + math.floor((gap - 20) * 0.8))
                    elseif gap >= 50 then
                        lowSkill = 100
                    elseif gap >= 45 then
                        lowSkill = 70
                    elseif gap >= 25 then
                        lowSkill = 5
                    end

                    assert(fight.chances.lowSkill == lowSkill, 'Rod ' .. tostring(rodId) .. ' at skill ' .. tostring(skill) .. ' on level ' .. tostring(level) .. ': lack of skill ' .. tostring(fight.chances.lowSkill) .. ', expected ' .. tostring(lowSkill))

                    player.packets:clear()
                end
            end
        end
    end)
end)
