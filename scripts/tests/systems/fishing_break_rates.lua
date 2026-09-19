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

-- Hook the catch on the rod and claim it at once, the fight's own rolls deciding the outcome.
local function claimOn(player, data, rodId, itemId)
    local cast = castOn(data, rodId, xi.item.LITTLE_WORM)

    cast.catch = hookedCatch(data, itemId)
    cast.fight = xi.fishing.hookCatch(player, cast, cast.catch)
    cast.stage = xi.fishing.stage.FIGHTING

    assert(cast.fight ~= nil, 'No fight row for rod ' .. tostring(rodId) .. ' and catch ' .. tostring(itemId))

    player.packets:clear()

    local result = xi.fishing.resolveCatch(player, cast, 0, cast.fight.intuition)

    player.packets:clear()

    return result, cast
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

-- One report line: the observed share of each outcome, with the model's share beside the breaks and snaps.
local function reportLine(name, counts)
    print(string.format(
        '[BREAKS] %-46s n %5d  caught %5.1f%%  rod break %5.1f%% (model %5.1f%%)  snap %5.1f%% (model %5.1f%%)  low skill %5.1f%% (model %5.1f%%)  lost %5.1f%%',
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

-- The observed count sits within three standard deviations of the model's, and one more for the rounding
local function checkCount(observed, expected, variance, label)
    local slack = 3 * math.sqrt(variance) + 1

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

            for _, itemId in ipairs(sortedIds(xi.fishing.luShangBreaks)) do
                local cast  = castOn(data, rodId, xi.item.LITTLE_WORM)
                local fight = xi.fishing.hookCatch(player, cast, hookedCatch(data, itemId))

                player.packets:clear()

                assert(fight.chances.rodBreak == xi.fishing.luShangBreaks[itemId], rodName .. ' on ' .. tostring(data.fish[itemId].name) .. ': a break chance of ' .. tostring(fight.chances.rodBreak) .. ', expected ' .. tostring(xi.fishing.luShangBreaks[itemId]))
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

        -- At skill 1 the hold drops to 95 and the list still rules: the Lik would break at 100 by the hold
        player:setSkillLevel(xi.skill.FISHING, 10)

        local lowLik = xi.fishing.hookCatch(player, castOn(data, xi.item.LU_SHANGS_FISHING_ROD, xi.item.LITTLE_WORM), hookedCatch(data, xi.item.LIK))

        player.packets:clear()

        assert(lowLik.chances.rodBreak == xi.fishing.luShangBreaks[xi.item.LIK], 'Lu Shang\'s on the lik at skill 1: a break chance of ' .. tostring(lowLik.chances.rodBreak))
    end)

    -- Retail lost hooks that felt positive to lack of skill on a Tarutaru rod, so the positive line no longer forces a break
    it('leaves the break chance alone on a positive hook, and scales only the snap by the other two doubts', function()
        player:setSkillLevel(xi.skill.FISHING, 100)

        -- The bluetail, 55 over a Tarutaru rod's hold of 35, breaks the rod at 60 on any doubt; the bastore bream, 86 over the
        -- Halcyon's hold of 60, snaps at 78 on a positive hook, 100 on a fairly sure one, 7 on one that doesn't know
        local rows =
        {
            { xi.item.TARUTARU_FISHING_ROD, xi.item.BLUETAIL_1,    60, 60,  60,  0, 0,   0 },
            { xi.item.HALCYON_FISHING_ROD,  xi.item.BASTORE_BREAM,  0,  0,   0, 78, 100, 7 },
        }

        for _, row in ipairs(rows) do
            local seen  = {}
            local label = tostring(data.rods[row[1]].name) .. ' on ' .. tostring(data.fish[row[2]].name) .. ': '

            xi.test.world:setSeed(row[1] + row[2])

            for _ = 1, 200 do
                local fight = xi.fishing.hookCatch(player, castOn(data, row[1], xi.item.LITTLE_WORM), hookedCatch(data, row[2]))

                player.packets:clear()

                local feeling = fight.feeling
                local slot    = feeling == xi.fishing.feeling.NO_SKILL_POSITIVE and 1 or (feeling == xi.fishing.feeling.NO_SKILL_SURE and 2 or (feeling == xi.fishing.feeling.NO_SKILL and 3 or nil))

                assert(slot ~= nil, label .. 'feeling ' .. tostring(feeling) .. ' far over the angler')
                assert(fight.chances.rodBreak == row[2 + slot], label .. 'a break chance of ' .. tostring(fight.chances.rodBreak) .. ' on feeling ' .. tostring(feeling) .. ', expected ' .. tostring(row[2 + slot]))
                assert(fight.chances.lineSnap == row[5 + slot], label .. 'a snap chance of ' .. tostring(fight.chances.lineSnap) .. ' on feeling ' .. tostring(feeling) .. ', expected ' .. tostring(row[5 + slot]))

                seen[feeling] = true
            end

            assert(seen[xi.fishing.feeling.NO_SKILL_POSITIVE] and seen[xi.fishing.feeling.NO_SKILL_SURE] and seen[xi.fishing.feeling.NO_SKILL], label .. 'not every doubt came up in 200 hooks')
        end
    end)

    it('swaps a broken rod for its broken form and keeps the bait on the hook when the line stays', function()
        player:setSkillLevel(xi.skill.FISHING, 80)
        player:addItem({ id = xi.item.WILLOW_FISHING_ROD, silent = true })
        player:addItem({ id = xi.item.LITTLE_WORM, quantity = 12, silent = true })
        player:equipItem(xi.item.WILLOW_FISHING_ROD, nil, xi.slot.RANGED)
        player:equipItem(xi.item.LITTLE_WORM, nil, xi.slot.AMMO)

        -- The gold carp, 56, over the Willow rod's hold of 26 breaks it 90 times in 100, so the first break is close; a worm
        -- goes with every claim, landed or not, so only the last one is counted
        local result = nil
        local worms  = 0
        for _ = 1, 20 do
            worms  = player:getEquippedItem(xi.slot.AMMO):getQuantity()
            result = claimOn(player, data, xi.item.WILLOW_FISHING_ROD, xi.item.GOLD_CARP)

            if result == xi.fishing.result.ROD_BREAK then
                break
            end

            if player:hasItem(xi.item.GOLD_CARP) then
                player:delItem(xi.item.GOLD_CARP, 1)
            end
        end

        assert(result == xi.fishing.result.ROD_BREAK, 'Expected the gold carp to break the Willow rod inside 20 claims')
        assert(player:getEquippedItem(xi.slot.RANGED) == nil, 'Expected the broken rod out of the ranged slot')
        assert(player:hasItem(xi.item.BROKEN_WILLOW_FISHING_ROD) and not player:hasItem(xi.item.WILLOW_FISHING_ROD), 'Expected the broken Willow rod in place of the whole one')
        assert(player:getAnimation() == xi.animation.NEW_FISHING_ROD_BREAK, 'Expected the rod break animation')

        -- The worm went with the line
        local worm = player:getEquippedItem(xi.slot.AMMO)

        assert(worm ~= nil and worm:getQuantity() == worms - 1, 'Expected one worm gone with the broken rod, held ' .. tostring(worms) .. ' before')
    end)
end)
