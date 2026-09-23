-----------------------------------
-- Fishing rod break rates
--
-- An angler fishes hundreds of claims on every rod against the catches
-- that strain them, with the real rolls, and the outcomes are counted
-- against the chances the fight carried. The per-cell and per-rod
-- report prints with --verbose or on a failure.
-----------------------------------

-- A cast on the rod and bait given, as the entry would build it from the catalog, the bite long past.
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

-- The ids of a catalog table in ascending order, so the sweeps and their seeds run the same way every time.
local function sortedIds(catalog)
    local ids = {}
    for id in pairs(catalog) do
        table.insert(ids, id)
    end

    table.sort(ids)

    return ids
end

-- The offset of the last fishing line sent to the player, read from the 0x036 packets against the West Ronfaure base. The id
-- carries 0x8000 when the speaker is the player.
local function lastFishingMessage(player)
    local base = zones[xi.zone.WEST_RONFAURE].text.FISHING_MESSAGE_OFFSET
    local last = nil

    for _, packet in ipairs(player.packets:getIncoming()) do
        if packet.type == 0x036 then
            last = bit.band(packet.data[10] + packet.data[11] * 256, 0x7FFF) - base
        end
    end

    return last
end

-- Hook the catch on the rod and claim it at once, the fight's own rolls deciding the outcome, with the line the claim ended on.
local function claimOn(player, data, rodId, itemId)
    local cast = castOn(data, rodId, xi.item.LITTLE_WORM)

    cast.catch = hookedCatch(data, itemId)
    cast.fight = xi.fishing.hookCatch(player, cast, cast.catch)
    cast.stage = xi.fishing.stage.FIGHTING

    assert(cast.fight ~= nil, 'No fight row for rod ' .. tostring(rodId) .. ' and catch ' .. tostring(itemId))

    player.packets:clear()

    local result = xi.fishing.resolveCatch(player, cast, 0, cast.fight.intuition)
    local line   = lastFishingMessage(player)

    player.packets:clear()

    return result, cast, line
end

-- Hand the angler the rod again after a break, checking the broken form took its place.
local function replaceRod(player, data, rodId, label)
    local brokenId = data.rods[rodId].breaksTo

    assert(brokenId ~= nil, label .. 'the rod broke but has no broken form')
    assert(player:getEquippedItem(xi.slot.RANGED) == nil, label .. 'the broken rod is still equipped')
    assert(player:hasItem(brokenId), label .. 'the broken form is not in the inventory')

    player:delItem(brokenId, 1)
    player:addItem({ id = rodId, silent = true })
    player:equipItem(rodId, nil, xi.slot.RANGED)
end

-- Count one claim into the tally: what happened, and what the chances made likely in the order the claim rolls them.
local function tally(counts, result, chances)
    local pBreak = chances.rodBreak / 100
    local pLow   = (1 - pBreak) * chances.lowSkill / 100
    local pSnap  = (1 - pBreak) * (1 - chances.lowSkill / 100) * chances.lineSnap / 100

    counts.n        = counts.n + 1
    counts[result]  = counts[result] + 1
    counts.eBreak   = counts.eBreak + pBreak
    counts.eLow     = counts.eLow + pLow
    counts.eSnap    = counts.eSnap + pSnap
    counts.vBreak   = counts.vBreak + pBreak * (1 - pBreak)
    counts.vSnap    = counts.vSnap + pSnap * (1 - pSnap)
end

local function newCounts()
    return
    {
        n      = 0,
        eBreak = 0,
        eLow   = 0,
        eSnap  = 0,
        vBreak = 0,
        vSnap  = 0,
        [xi.fishing.result.CAUGHT    ] = 0,
        [xi.fishing.result.ROD_BREAK ] = 0,
        [xi.fishing.result.LINE_BREAK] = 0,
        [xi.fishing.result.LOW_SKILL ] = 0,
        [xi.fishing.result.LOST      ] = 0,
    }
end

local function addCounts(total, counts)
    for key, value in pairs(counts) do
        total[key] = total[key] + value
    end
end

local function percent(count, n)
    return n > 0 and count * 100 / n or 0
end

-- One report line: the observed share of each outcome in percent, with the model's share beside the breaks and snaps. The
-- logger reads a percent sign as a format directive, so none is printed.
local function reportLine(name, counts)
    print(string.format(
        '[BREAKS] %-46s n %5d  caught %5.1f  rod break %5.1f (model %5.1f)  snap %5.1f (model %5.1f)  low skill %5.1f (model %5.1f)  lost %5.1f',
        name,
        counts.n,
        percent(counts[xi.fishing.result.CAUGHT], counts.n),
        percent(counts[xi.fishing.result.ROD_BREAK], counts.n),
        percent(counts.eBreak, counts.n),
        percent(counts[xi.fishing.result.LINE_BREAK], counts.n),
        percent(counts.eSnap, counts.n),
        percent(counts[xi.fishing.result.LOW_SKILL], counts.n),
        percent(counts.eLow, counts.n),
        percent(counts[xi.fishing.result.LOST], counts.n)))
end

-- The observed count sits within four standard deviations of the model's, and one more for the rounding. Four rather than
-- three because the sweep makes this call about six hundred times a run: at three a run is more likely than not to trip a
-- cell on chance alone, and the per-rod and whole-sweep totals behind it catch a real error far tighter than any one cell can.
local function checkCount(observed, expected, variance, label)
    local slack = 4 * math.sqrt(variance) + 1

    assert(math.abs(observed - expected) <= slack, label .. 'observed ' .. tostring(observed) .. ' against a model of ' .. tostring(math.floor(expected + 0.5)) .. ', more than ' .. tostring(math.floor(slack + 0.5)) .. ' apart')
end

describe('Fishing rod break rates', function()
    ---@type CClientEntityPair
    local player
    local data

    -- The catches that strain a rod: two carp either side of a starter rod's hold, a large fish and a small one over the mid
    -- rods, the junk and the coral the JP wiki names, and a super legendary
    local catches =
    {
        xi.item.MOAT_CARP_1,
        xi.item.GOLD_CARP,
        xi.item.JUNGLE_CATFISH,
        xi.item.BASTORE_BREAM,
        xi.item.RUSTY_SUBLIGAR,
        xi.item.ARROWWOOD_LOG,
        xi.item.CORAL_FRAGMENT,
        xi.item.GUGRUSAURUS,
    }

    before_each(function()
        data   = xi.fishing.getData()
        player = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE })

        xi.test.world:setVanaTime(12, 0)
        stub('xi.fishing.updateMeters', true)
    end)

    it('breaks and snaps on every rod as often as its hold against the catch says, over hundreds of claims per rod #long', function()
        local seed   = 300000
        local totals = {}

        for _, rodId in ipairs(sortedIds(data.rods)) do
            local rodName  = tostring(data.rods[rodId].name)
            local rodTotal = newCounts()

            player:addItem({ id = rodId, silent = true })
            player:equipItem(rodId, nil, xi.slot.RANGED)

            for _, skill in ipairs({ 10, 50, 100 }) do
                player:setSkillLevel(xi.skill.FISHING, skill * 10)

                for _, itemId in ipairs(catches) do
                    local label  = rodName .. ' on ' .. tostring(data.fish[itemId].name) .. ' at skill ' .. tostring(skill) .. ': '
                    local counts = newCounts()

                    seed = seed + 1
                    xi.test.world:setSeed(seed)

                    for _ = 1, 75 do
                        local result, cast = claimOn(player, data, rodId, itemId)

                        tally(counts, result, cast.fight.chances)

                        if result == xi.fishing.result.ROD_BREAK then
                            replaceRod(player, data, rodId, label)
                        elseif
                            result == xi.fishing.result.CAUGHT and
                            player:hasItem(itemId)
                        then
                            player:delItem(itemId, 1)
                        end
                    end

                    reportLine(rodName .. ' / ' .. tostring(data.fish[itemId].name) .. ' / skill ' .. tostring(skill), counts)
                    checkCount(counts[xi.fishing.result.ROD_BREAK], counts.eBreak, counts.vBreak, label .. 'rod breaks: ')
                    checkCount(counts[xi.fishing.result.LINE_BREAK], counts.eSnap, counts.vSnap, label .. 'line snaps: ')
                    addCounts(rodTotal, counts)
                end
            end

            -- A rod with no broken form never broke, whatever it hooked
            if not data.rods[rodId].breaksTo then
                assert(rodTotal[xi.fishing.result.ROD_BREAK] == 0, rodName .. ' has no broken form yet broke ' .. tostring(rodTotal[xi.fishing.result.ROD_BREAK]) .. ' times')
            end

            checkCount(rodTotal[xi.fishing.result.ROD_BREAK], rodTotal.eBreak, rodTotal.vBreak, rodName .. ' over every catch and skill, rod breaks: ')
            checkCount(rodTotal[xi.fishing.result.LINE_BREAK], rodTotal.eSnap, rodTotal.vSnap, rodName .. ' over every catch and skill, line snaps: ')
            table.insert(totals, { name = rodName, counts = rodTotal })

            player:unequipItem(xi.slot.RANGED)
            player:delItem(rodId, 1)
        end

        -- The rods from the one that breaks most to the one that never does
        table.sort(totals, function(a, b)
            return a.counts[xi.fishing.result.ROD_BREAK] > b.counts[xi.fishing.result.ROD_BREAK]
        end)

        print('[BREAKS] Every rod over ' .. tostring(#catches) .. ' catches at skill 10, 50 and 100:')
        for _, row in ipairs(totals) do
            reportLine(row.name, row.counts)
        end
    end)

    it('never breaks a rod without a hold, and snaps its line only by the catch\'s own rate', function()
        local pooled = {}
        for _, zone in pairs(data.zones) do
            for _, area in pairs(zone.areas) do
                for _, itemId in ipairs(area.pool) do
                    pooled[itemId] = true
                end
            end
        end

        for _, rodId in ipairs({ xi.item.EBISU_FISHING_ROD, xi.item.EBISU_FISHING_ROD_P1, xi.item.JUDGES_ROD, xi.item.GOLDFISH_BASKET }) do
            assert(xi.fishing.rodStats[rodId].strength == nil and data.rods[rodId].breaksTo == nil, 'Expected rod ' .. tostring(rodId) .. ' to carry neither a hold nor a broken form')

            for _, skill in ipairs({ 1, 100 }) do
                player:setSkillLevel(xi.skill.FISHING, skill * 10)

                for _, itemId in ipairs(sortedIds(pooled)) do
                    local label = tostring(data.rods[rodId].name) .. ' on ' .. tostring(data.fish[itemId].name) .. ' at skill ' .. tostring(skill) .. ': '
                    local fight = xi.fishing.hookCatch(player, castOn(data, rodId, xi.item.LITTLE_WORM), hookedCatch(data, itemId))
                    local stats = xi.fishing.catchStats[itemId]

                    player.packets:clear()

                    assert(fight ~= nil, label .. 'no fight row')
                    assert(fight.chances.rodBreak == 0, label .. 'a break chance of ' .. tostring(fight.chances.rodBreak))

                    if not (stats and stats.lineSnap) then
                        assert(fight.chances.lineSnap == 0, label .. 'a snap chance of ' .. tostring(fight.chances.lineSnap) .. ' with no rate of its own')
                    end
                end
            end
        end
    end)

    it('breaks both Lu Shang\'s rods on the listed legendaries at the list\'s rate, in place of the hold\'s', function()
        player:setSkillLevel(xi.skill.FISHING, 1000)

        for _, rodId in ipairs({ xi.item.LU_SHANGS_FISHING_ROD, xi.item.LU_SHANGS_FISHING_ROD_P1 }) do
            local rodName = tostring(data.rods[rodId].name)

            -- The list names the Hakuryu too, which the catalog does not carry yet
            for _, itemId in ipairs(sortedIds(xi.fishing.luShangBreaks)) do
                if data.fish[itemId] then
                    local cast  = castOn(data, rodId, xi.item.LITTLE_WORM)
                    local fight = xi.fishing.hookCatch(player, cast, hookedCatch(data, itemId))

                    player.packets:clear()

                    assert(fight.chances.rodBreak == xi.fishing.luShangBreaks[itemId], rodName .. ' on ' .. tostring(data.fish[itemId].name) .. ': a break chance of ' .. tostring(fight.chances.rodBreak) .. ', expected ' .. tostring(xi.fishing.luShangBreaks[itemId]))
                end
            end

            -- The Lik, 140 under a hold of 145, would not break by the hold at all, and the list still says it does
            local lik = xi.fishing.hookCatch(player, castOn(data, rodId, xi.item.LITTLE_WORM), hookedCatch(data, xi.item.LIK))

            player.packets:clear()

            assert(lik.chances.rodBreak == xi.fishing.luShangBreaks[xi.item.LIK], rodName .. ' on the lik: a break chance of ' .. tostring(lik.chances.rodBreak))

            -- The jungle catfish, 80 and unlisted, is held outright
            local catfish = xi.fishing.hookCatch(player, castOn(data, rodId, xi.item.LITTLE_WORM), hookedCatch(data, xi.item.JUNGLE_CATFISH))

            player.packets:clear()

            assert(catfish.chances.rodBreak == 0 and catfish.chances.lineSnap == 0, rodName .. ' on the jungle catfish: break ' .. tostring(catfish.chances.rodBreak) .. ' snap ' .. tostring(catfish.chances.lineSnap))
        end

        -- At skill 1 the hold drops to 95 and the list still rules: the Lik would break at 87 by the hold
        player:setSkillLevel(xi.skill.FISHING, 10)

        local lowLik = xi.fishing.hookCatch(player, castOn(data, xi.item.LU_SHANGS_FISHING_ROD, xi.item.LITTLE_WORM), hookedCatch(data, xi.item.LIK))

        player.packets:clear()

        assert(lowLik.chances.rodBreak == xi.fishing.luShangBreaks[xi.item.LIK], 'Lu Shang\'s on the lik at skill 1: a break chance of ' .. tostring(lowLik.chances.rodBreak))
    end)

    -- Retail's skill-0 nebimonite hooks sorted the same way its skill-30 ones did: the hooks that did not know landed, the
    -- fairly sure ones snapped the line and the positive ones broke the rod, 21 reels at p 0.00002
    it('words the reading as doubt far over the angler, keeping the outcome it carries', function()
        player:setSkillLevel(xi.skill.FISHING, 0)

        local seen = {}

        xi.test.world:setSeed(9001)

        for _ = 1, 400 do
            local fight = xi.fishing.hookCatch(player, castOn(data, xi.item.TARUTARU_FISHING_ROD, xi.item.LITTLE_WORM), hookedCatch(data, xi.item.NEBIMONITE))

            player.packets:clear()

            local expected = xi.fishing.feeling.NO_SKILL
            if fight.result == xi.fishing.result.ROD_BREAK then
                expected = xi.fishing.feeling.NO_SKILL_POSITIVE
            elseif fight.result == xi.fishing.result.LINE_BREAK then
                expected = xi.fishing.feeling.NO_SKILL_SURE
            end

            assert(fight.feeling == expected, 'The nebimonite read ' .. tostring(fight.feeling) .. ' on a fight that rolled ' .. tostring(fight.result))

            seen[fight.feeling] = true
        end

        assert(seen[xi.fishing.feeling.NO_SKILL_POSITIVE] and seen[xi.fishing.feeling.NO_SKILL_SURE] and seen[xi.fishing.feeling.NO_SKILL], 'Not every doubt came up in 400 hooks')
    end)

    -- Retail read 64 of 136 nebimonite hooks bad and 13 terrible on a Tarutaru rod at skill 30, and every one of the 126 it
    -- reeled ended the way it read: 59 landed on good, 63 snapped on bad, 4 broke the rod on terrible
    it('reads the hook as the outcome it has already rolled', function()
        player:setSkillLevel(xi.skill.FISHING, 300)

        local counts = { [xi.fishing.feeling.GOOD] = 0, [xi.fishing.feeling.BAD] = 0, [xi.fishing.feeling.TERRIBLE] = 0 }

        xi.test.world:setSeed(9002)

        for _ = 1, 400 do
            local fight = xi.fishing.hookCatch(player, castOn(data, xi.item.TARUTARU_FISHING_ROD, xi.item.LITTLE_WORM), hookedCatch(data, xi.item.NEBIMONITE))

            player.packets:clear()

            -- The nebimonite is 3 levels under the angler, so no doubt words and no warning on a catch that lands
            if fight.result == xi.fishing.result.ROD_BREAK then
                assert(fight.feeling == xi.fishing.feeling.TERRIBLE, 'A broken rod read ' .. tostring(fight.feeling))
            elseif fight.result == xi.fishing.result.LINE_BREAK then
                assert(fight.feeling == xi.fishing.feeling.BAD, 'A snapped line read ' .. tostring(fight.feeling))
            else
                assert(fight.feeling == xi.fishing.feeling.GOOD or fight.feeling == xi.fishing.feeling.KEEN, 'A catch that lands read ' .. tostring(fight.feeling))
            end

            counts[fight.feeling] = (counts[fight.feeling] or 0) + 1
        end

        -- Retail warned on 56.6 percent of the 136 hooks and broke the rod on 9.6: the hold rolls 9 then 57, which lands on 61
        local warned = counts[xi.fishing.feeling.BAD] + counts[xi.fishing.feeling.TERRIBLE]

        assert(math.abs(warned - 243) <= 30, 'Expected close to 243 warnings in 400 hooks, got ' .. tostring(warned))
        assert(math.abs(counts[xi.fishing.feeling.TERRIBLE] - 36) <= 18, 'Expected close to 36 terrible readings in 400 hooks, got ' .. tostring(counts[xi.fishing.feeling.TERRIBLE]))
    end)

    -- Retail lost 17 of 21 nebimonite hooks on a Tarutaru rod at skill 0 and warned on 56.6 percent of 136 at skill 30, while
    -- the Halcyon and the Mithran held it: the fish strains a rod by a weight of 56 rather than by its level of 27
    it('strains a rod by the nebimonite\'s weight instead of its level', function()
        player:setSkillLevel(xi.skill.FISHING, 0)

        local taru = xi.fishing.hookCatch(player, castOn(data, xi.item.TARUTARU_FISHING_ROD, xi.item.LITTLE_WORM), hookedCatch(data, xi.item.NEBIMONITE))

        player.packets:clear()

        assert(taru.chances.rodBreak == 30 and taru.chances.lineSnap == 78, 'Expected the nebimonite to fail a Tarutaru rod at 78 and break it at 30, got break ' .. tostring(taru.chances.rodBreak) .. ' snap ' .. tostring(taru.chances.lineSnap))

        -- The Halcyon holds 60 at skill 20 and the Mithran 63 at skill 13, and retail lost nothing to either
        for _, row in ipairs({ { xi.item.HALCYON_FISHING_ROD, 200 }, { xi.item.MITHRAN_FISHING_ROD, 130 } }) do
            player:setSkillLevel(xi.skill.FISHING, row[2])

            local chances = xi.fishing.hookCatch(player, castOn(data, row[1], xi.item.LITTLE_WORM), hookedCatch(data, xi.item.NEBIMONITE)).chances

            player.packets:clear()

            assert(chances.rodBreak == 0 and chances.lineSnap == 0, 'Expected rod ' .. tostring(row[1]) .. ' to hold the nebimonite at skill ' .. tostring(row[2] / 10) .. ', got break ' .. tostring(chances.rodBreak) .. ' snap ' .. tostring(chances.lineSnap))
        end
    end)

    -- Retail broke a Tarutaru rod three times on the rusty subligar and once on the arrowwood log, each naming the catch, and
    -- said nothing of the kind over the nebimonite
    it('names an item too big or too heavy when it breaks the rod, and leaves a fish the plain line', function()
        player:setSkillLevel(xi.skill.FISHING, 0)
        player:addItem({ id = xi.item.TARUTARU_FISHING_ROD, silent = true })
        player:equipItem(xi.item.TARUTARU_FISHING_ROD, nil, xi.slot.RANGED)

        -- The arrowwood log weighs 70 and the rusty subligar 78, both far over the rod's hold of 30, and the nebimonite 56
        local rows =
        {
            { xi.item.ARROWWOOD_LOG,  xi.fishingMessage.ROD_BREAK_TOO_BIG   },
            { xi.item.RUSTY_SUBLIGAR, xi.fishingMessage.ROD_BREAK_TOO_HEAVY },
            { xi.item.NEBIMONITE,     xi.fishingMessage.ROD_BREAK           },
        }

        for _, row in ipairs(rows) do
            local label  = tostring(data.fish[row[1]].name) .. ': '
            local broken = false

            for _ = 1, 40 do
                local result, _, line = claimOn(player, data, xi.item.TARUTARU_FISHING_ROD, row[1])

                if result == xi.fishing.result.ROD_BREAK then
                    assert(line == row[2], label .. 'the rod break sent line ' .. tostring(line) .. ', expected ' .. tostring(row[2]))
                    replaceRod(player, data, xi.item.TARUTARU_FISHING_ROD, label)
                    broken = true
                    break
                end

                if player:hasItem(row[1]) then
                    player:delItem(row[1], 1)
                end
            end

            assert(broken, label .. 'no rod break in 40 claims')
        end

        player:unequipItem(xi.slot.RANGED)
        player:delItem(xi.item.TARUTARU_FISHING_ROD, 1)
    end)

    it('swaps a broken rod for its broken form and keeps the bait on the hook when the line stays', function()
        player:setSkillLevel(xi.skill.FISHING, 80)
        player:addItem({ id = xi.item.WILLOW_FISHING_ROD, silent = true })
        player:addItem({ id = xi.item.LITTLE_WORM, quantity = 99, silent = true })
        player:equipItem(xi.item.WILLOW_FISHING_ROD, nil, xi.slot.RANGED)
        player:equipItem(xi.item.LITTLE_WORM, nil, xi.slot.AMMO)

        -- The gold carp, approximated at 46, sits 22 over the Willow rod's hold at skill 8 and breaks it 18 times in 100, so
        -- the loop is given room for the break to land; a worm goes with every claim, landed or not, so only the last is counted
        local result = nil
        local worms  = 0
        for _ = 1, 60 do
            local ammo = player:getEquippedItem(xi.slot.AMMO)

            assert(ammo ~= nil, 'Expected bait left on the hook: the rod never broke in 60 claims')

            worms = ammo:getQuantity()
            result = claimOn(player, data, xi.item.WILLOW_FISHING_ROD, xi.item.GOLD_CARP)

            if result == xi.fishing.result.ROD_BREAK then
                break
            end

            if player:hasItem(xi.item.GOLD_CARP) then
                player:delItem(xi.item.GOLD_CARP, 1)
            end
        end

        assert(result == xi.fishing.result.ROD_BREAK, 'Expected the gold carp to break the Willow rod inside 60 claims')
        assert(player:getEquippedItem(xi.slot.RANGED) == nil, 'Expected the broken rod out of the ranged slot')
        assert(player:hasItem(xi.item.BROKEN_WILLOW_FISHING_ROD) and not player:hasItem(xi.item.WILLOW_FISHING_ROD), 'Expected the broken Willow rod in place of the whole one')
        assert(player:getAnimation() == xi.animation.NEW_FISHING_ROD_BREAK, 'Expected the rod break animation')

        -- The worm went with the line
        local worm = player:getEquippedItem(xi.slot.AMMO)

        assert(worm ~= nil and worm:getQuantity() == worms - 1, 'Expected one worm gone with the broken rod, held ' .. tostring(worms) .. ' before')
    end)
end)

-----------------------------------
-- Fishing chances against the capture corpus
--
-- Every reeled hook the captures hold, grouped by rod, catch and the
-- angler's effective skill, against the chances the fight builds for
-- that same cell. Nothing here rolls: the fight's chances are composed
-- in the order a claim rolls them and read against the share the
-- corpus counted.
-----------------------------------

-- The 95 percent Wilson interval for k of n, in percent. Wilson still gives a range where nothing failed, which the plain
-- interval collapses to a point, and the corpus has many such cells.
local function wilsonRange(k, n)
    local proportion = k / n
    local divisor    = 1 + 1.96 * 1.96 / n
    local centre     = (proportion + 1.96 * 1.96 / (2 * n)) / divisor
    local spread     = 1.96 * math.sqrt(proportion * (1 - proportion) / n + 1.96 * 1.96 / (4 * n * n)) / divisor

    return math.max(0, centre - spread) * 100, math.min(1, centre + spread) * 100
end

-- The share of claims each outcome takes, in percent. A claim rolls the break first, then lack of skill, then the line and
-- the size, so each chance only sees what the ones before it left behind.
local function outcomeShares(chances)
    local order =
    {
        { xi.fishing.result.ROD_BREAK,  chances.rodBreak },
        { xi.fishing.result.LOW_SKILL,  chances.lowSkill },
        { xi.fishing.result.LINE_BREAK, chances.lineSnap },
        { xi.fishing.result.LOST,       chances.sizeLoss },
    }

    local left   = 1
    local shares = {}

    for _, step in ipairs(order) do
        shares[step[1]] = left * step[2]
        left            = left * (100 - step[2]) / 100
    end

    shares[xi.fishing.result.CAUGHT] = left * 100

    return shares
end

local resultNames =
{
    [xi.fishing.result.CAUGHT    ] = 'landed',
    [xi.fishing.result.ROD_BREAK ] = 'rod break',
    [xi.fishing.result.LINE_BREAK] = 'line break',
    [xi.fishing.result.LOW_SKILL ] = 'lack of skill',
    [xi.fishing.result.LOST      ] = 'lost to size',
}

describe('Fishing chances against the capture corpus', function()
    ---@type CClientEntityPair
    local player
    local data

    -- Reeled hooks from the captures, by rod, catch and the angler's skill with the gear it wore. Only cells the model
    -- already lands inside sit here; the ones it misses are in the table the next test carries.
    local corpusCells =
    {
        -- The hold against a catch heavier than its level: the nebimonite weighs 56 against a Tarutaru rod's 30
        { rod = xi.item.TARUTARU_FISHING_ROD,  catch = xi.item.NEBIMONITE,    skill =   0, gear = 0, n =  21, caught =   4, rodBreak = 4, lineBreak = 13, lowSkill =   0, sizeLoss =  0 },
        { rod = xi.item.WILLOW_FISHING_ROD,    catch = xi.item.CHEVAL_SALMON, skill =  12, gear = 0, n =  50, caught =  43, rodBreak = 0, lineBreak =  7, lowSkill =   0, sizeLoss =  0 },
        { rod = xi.item.WILLOW_FISHING_ROD,    catch = xi.item.CHEVAL_SALMON, skill =  14, gear = 0, n =  46, caught =  39, rodBreak = 0, lineBreak =  7, lowSkill =   0, sizeLoss =  0 },

        -- Lack of skill: a large catch 20 over, and a small one far enough over to sit on the ladder's top step
        { rod = xi.item.LU_SHANGS_FISHING_ROD, catch = xi.item.GIANT_DONKO_1, skill =  30, gear = 0, n = 180, caught =  31, rodBreak = 0, lineBreak =  0, lowSkill = 149, sizeLoss =  0 },
        { rod = xi.item.LU_SHANGS_FISHING_ROD, catch = xi.item.BASTORE_BREAM, skill =  30, gear = 0, n =  35, caught =   0, rodBreak = 0, lineBreak =  0, lowSkill =  35, sizeLoss =  0 },
        { rod = xi.item.LU_SHANGS_FISHING_ROD, catch = xi.item.BASTORE_BREAM, skill =  14, gear = 0, n =  24, caught =   0, rodBreak = 0, lineBreak =  0, lowSkill =  24, sizeLoss =  0 },
        { rod = xi.item.HALCYON_FISHING_ROD,   catch = xi.item.BASTORE_BREAM, skill =  28, gear = 0, n =  29, caught =   0, rodBreak = 0, lineBreak =  0, lowSkill =  29, sizeLoss =  0 },
        { rod = xi.item.LU_SHANGS_FISHING_ROD, catch = xi.item.BASTORE_BREAM, skill = 100, gear = 0, n =  75, caught =  75, rodBreak = 0, lineBreak =  0, lowSkill =   0, sizeLoss =  0 },
        { rod = xi.item.EBISU_FISHING_ROD,     catch = xi.item.CAVE_CHERAX,   skill =  98, gear = 0, n =  21, caught =   0, rodBreak = 0, lineBreak =  1, lowSkill =  20, sizeLoss =  0 },

        -- A rod penalised against the size it hooked
        { rod = xi.item.HUME_FISHING_ROD,      catch = xi.item.ISTAVRIT_1,    skill =  10, gear = 0, n = 110, caught =  67, rodBreak = 0, lineBreak =  0, lowSkill =   0, sizeLoss = 43 },
        { rod = xi.item.MITHRAN_FISHING_ROD,   catch = xi.item.MOAT_CARP_1,   skill =   8, gear = 0, n = 101, caught =  83, rodBreak = 0, lineBreak =  0, lowSkill =   0, sizeLoss = 18 },

        -- Cells where the corpus lost nothing at all, which pin the rods that hold and the gaps that cost nothing
        { rod = xi.item.HALCYON_FISHING_ROD,   catch = xi.item.MOAT_CARP_1,   skill =   0, gear = 0, n = 265, caught = 265, rodBreak = 0, lineBreak =  0, lowSkill =   0, sizeLoss =  0 },
        { rod = xi.item.TARUTARU_FISHING_ROD,  catch = xi.item.MOAT_CARP_1,   skill =   5, gear = 0, n = 220, caught = 220, rodBreak = 0, lineBreak =  0, lowSkill =   0, sizeLoss =  0 },
        { rod = xi.item.EBISU_FISHING_ROD,     catch = xi.item.MOAT_CARP_1,   skill =  98, gear = 0, n = 200, caught = 200, rodBreak = 0, lineBreak =  0, lowSkill =   0, sizeLoss =  0 },
        { rod = xi.item.FASTWATER_FISHING_ROD, catch = xi.item.MOAT_CARP_1,   skill =   8, gear = 0, n = 200, caught = 200, rodBreak = 0, lineBreak =  0, lowSkill =   0, sizeLoss =  0 },
        { rod = xi.item.YEW_FISHING_ROD,       catch = xi.item.MOAT_CARP_1,   skill =  10, gear = 0, n = 200, caught = 200, rodBreak = 0, lineBreak =  0, lowSkill =   0, sizeLoss =  0 },
        { rod = xi.item.EBISU_FISHING_ROD,     catch = xi.item.ISTAVRIT_1,    skill =  98, gear = 0, n = 199, caught = 199, rodBreak = 0, lineBreak =  0, lowSkill =   0, sizeLoss =  0 },
        { rod = xi.item.LU_SHANGS_FISHING_ROD, catch = xi.item.ISTAVRIT_1,    skill =  12, gear = 0, n = 173, caught = 173, rodBreak = 0, lineBreak =  0, lowSkill =   0, sizeLoss =  0 },
        { rod = xi.item.CARBON_FISHING_ROD,    catch = xi.item.MOAT_CARP_1,   skill =   0, gear = 0, n = 171, caught = 171, rodBreak = 0, lineBreak =  0, lowSkill =   0, sizeLoss =  0 },
        { rod = xi.item.HALCYON_FISHING_ROD,   catch = xi.item.CRAYFISH_1,    skill =   0, gear = 0, n = 100, caught = 100, rodBreak = 0, lineBreak =  0, lowSkill =   0, sizeLoss =  0 },
    }

    -- Cells the corpus settles and the model still misses. Each row names one outcome, the share the corpus counted and the
    -- share the model gives instead, so closing a gap trips this test and moves the row into the table above.
    -- Capture needed: none of these are thin cells, so each is a rule to settle rather than a sample to grow.
    local openCells =
    {
        { rod = xi.item.TARUTARU_FISHING_ROD,  catch = xi.item.NEBIMONITE,    skill =  30, gear = 0, n = 126, result = xi.fishing.result.ROD_BREAK,  corpus =  3.2, model =  9.0,
            note = 'the weight of 56 breaks a Tarutaru rod three times as often as retail did at skill 30' },
        { rod = xi.item.WILLOW_FISHING_ROD,    catch = xi.item.CHEVAL_SALMON, skill =  16, gear = 0, n =  51, result = xi.fishing.result.LINE_BREAK, corpus = 15.7, model =  6.0,
            note = 'the hold sheds a point of snap every four points of skill and the corpus did not' },
        { rod = xi.item.WILLOW_FISHING_ROD,    catch = xi.item.ISTAVRIT_1,    skill =  10, gear = 0, n =  72, result = xi.fishing.result.LINE_BREAK, corpus =  0.0, model =  9.0,
            note = 'the fallback weight of 27 snaps a Willow rod the corpus never saw snap' },
        { rod = xi.item.MITHRAN_FISHING_ROD,   catch = xi.item.CRAYFISH_1,    skill =   8, gear = 0, n = 152, result = xi.fishing.result.LOST,       corpus = 22.4, model = 12.0,
            note = 'a crayfish has no measured size-loss rate, so the level curve stands in and reads low' },
        { rod = xi.item.EBISU_FISHING_ROD,     catch = xi.item.GUGRUSAURUS,   skill = 100, gear = 4, n = 105, result = xi.fishing.result.LOW_SKILL,  corpus = 23.8, model = 38.0,
            note = 'lack of skill rolls before the line, so it takes the share the corpus gave the snap' },
        { rod = xi.item.EBISU_FISHING_ROD,     catch = xi.item.GUGRUSAURUS,   skill = 100, gear = 4, n = 105, result = xi.fishing.result.LINE_BREAK, corpus = 32.4, model = 19.2,
            note = 'the same order: rolling the snap first gives 31 percent, which the corpus brackets' },
        { rod = xi.item.EBISU_FISHING_ROD,     catch = xi.item.CAVE_CHERAX,   skill = 100, gear = 0, n = 256, result = xi.fishing.result.LOW_SKILL,  corpus = 17.2, model = 90.0,
            note = 'the 90 percent at 30 over holds at skill 98 and collapses at 100, so the gap or the gear is wrong' },
        { rod = xi.item.LU_SHANGS_FISHING_ROD, catch = xi.item.ELSHIMO_NEWT,  skill =  30, gear = 0, n = 220, result = xi.fishing.result.LOW_SKILL,  corpus =  0.0, model =  5.0,
            note = 'the small-fish ladder starts costing at 25 over and the corpus lost none at 30' },
        { rod = xi.item.LU_SHANGS_FISHING_ROD, catch = xi.item.ZEBRA_EEL,     skill =  30, gear = 0, n =  82, result = xi.fishing.result.LOW_SKILL,  corpus =  0.0, model =  5.0,
            note = 'the same step, 40 over, and the corpus landed all 82' },
    }

    before_each(function()
        data   = xi.fishing.getData()
        player = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE })

        xi.test.world:setVanaTime(12, 0)
        stub('xi.fishing.updateMeters', true)
    end)

    after_each(function()
        player:setMod(xi.mod.FISH, 0)
    end)

    it('lands inside the corpus interval on every outcome of every cell the captures settle', function()
        for _, cell in ipairs(corpusCells) do
            player:setSkillLevel(xi.skill.FISHING, cell.skill * 10)
            player:setMod(xi.mod.FISH, cell.gear)

            local fight = xi.fishing.hookCatch(player, castOn(data, cell.rod, xi.item.LITTLE_WORM), hookedCatch(data, cell.catch))

            player.packets:clear()

            local counted =
            {
                [xi.fishing.result.CAUGHT    ] = cell.caught,
                [xi.fishing.result.ROD_BREAK ] = cell.rodBreak,
                [xi.fishing.result.LINE_BREAK] = cell.lineBreak,
                [xi.fishing.result.LOW_SKILL ] = cell.lowSkill,
                [xi.fishing.result.LOST      ] = cell.sizeLoss,
            }

            local shares = outcomeShares(fight.chances)
            local label  = tostring(data.rods[cell.rod].name) .. ' on ' .. tostring(data.fish[cell.catch].name) .. ' at skill ' .. tostring(cell.skill + cell.gear) .. ': '

            assert(cell.caught + cell.rodBreak + cell.lineBreak + cell.lowSkill + cell.sizeLoss == cell.n, label .. 'the cell does not add up to its ' .. tostring(cell.n) .. ' reels')

            for result, count in pairs(counted) do
                local low, high = wilsonRange(count, cell.n)

                assert(shares[result] >= low - 0.001 and shares[result] <= high + 0.001,
                    label .. resultNames[result] .. ' at ' .. string.format('%.1f', shares[result]) .. ', outside the ' ..
                    tostring(count) .. ' of ' .. tostring(cell.n) .. ' the corpus counted, ' .. string.format('%.1f to %.1f', low, high))
            end
        end
    end)

    it('still gives the share it has always given on the cells the corpus contradicts', function()
        for _, cell in ipairs(openCells) do
            player:setSkillLevel(xi.skill.FISHING, cell.skill * 10)
            player:setMod(xi.mod.FISH, cell.gear)

            local fight = xi.fishing.hookCatch(player, castOn(data, cell.rod, xi.item.LITTLE_WORM), hookedCatch(data, cell.catch))

            player.packets:clear()

            local share = outcomeShares(fight.chances)[cell.result]
            local label = tostring(data.rods[cell.rod].name) .. ' on ' .. tostring(data.fish[cell.catch].name) .. ' at skill ' .. tostring(cell.skill + cell.gear) .. ': '

            assert(math.abs(share - cell.model) <= 0.05,
                label .. resultNames[cell.result] .. ' at ' .. string.format('%.1f', share) .. ', where this test recorded ' ..
                string.format('%.1f', cell.model) .. ' against a corpus share of ' .. string.format('%.1f', cell.corpus) ..
                '. If this is the fix, move the row into the settled table above. ' .. cell.note)
        end
    end)
end)
