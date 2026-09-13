-----------------------------------
-- Fishing lifecycle framework
--
-- The entry checks open or refuse a cast against an injected catalog.
-----------------------------------

-- A catalog in the GetFishingData shape with one rod, one bait and a whole-zone area in West Ronfaure. Built fresh per test so a test can reshape it.
local function testCatalog()
    return
    {
        fish  = {},
        rods  = { [xi.item.WILLOW_FISHING_ROD] = { name = 'willow_fishing_rod', size = xi.fishingSize.SMALL, time = 30 } },
        baits = { [xi.item.LITTLE_WORM] = { name = 'little_worm', type = xi.fishingBaitType.BAIT, affinity = {} } },
        zones =
        {
            [xi.zone.WEST_RONFAURE] =
            {
                areas    = { whole_zone = { pool = {} } },
                monsters = {},
            },
        },
    }
end

-- A player in West Ronfaure, or the zone given, holding the catalog's rod and bait. Level 1 unless given; the leveled gear needs more.
local function spawnAngler(zone, level)
    local player = xi.test.world:spawnPlayer({ zone = zone or xi.zone.WEST_RONFAURE, level = level })

    player:addItem(xi.item.WILLOW_FISHING_ROD)
    player:addItem(xi.item.LITTLE_WORM)
    player:equipItem(xi.item.WILLOW_FISHING_ROD, nil, xi.slot.RANGED)
    player:equipItem(xi.item.LITTLE_WORM, nil, xi.slot.AMMO)

    return player
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

describe('Fishing cast entry', function()
    ---@type CClientEntityPair
    local player
    local originalData

    before_each(function()
        originalData    = xi.fishing.data
        xi.fishing.data = testCatalog()
        player          = spawnAngler()
    end)

    after_each(function()
        xi.fishing.data = originalData
    end)

    it('opens a cast with a rod, bait and an area', function()
        local hook = xi.fishing.onStart(player)
        local cast = xi.fishing.casts[player:getID()]

        assert(hook ~= nil and hook >= 7 and hook <= 13, 'Expected a hook time between 7 and 13, got ' .. tostring(hook))
        assert(cast ~= nil and cast.stage == xi.fishing.stage.CAST, 'Expected the cast to be open')
        assert(cast.areaName == 'whole_zone', 'Expected the whole-zone area')
        assert(cast.rod ~= nil and cast.bait ~= nil, 'Expected the rod and bait records on the cast')
        assert(player:getAnimation() == xi.animation.NEW_FISHING_START, 'Expected the start animation')
        assert(player:getCharVar('[Fish]LastCastTime') == cast.startedAt, 'Expected the contest stamp')
    end)

    it('refuses a cast without a rod', function()
        player:unequipItem(xi.slot.RANGED)

        assert(xi.fishing.onStart(player) == nil, 'Expected no hook time')
        assert(xi.fishing.casts[player:getID()] == nil, 'Expected no cast')
        assert(player:getAnimation() == xi.animation.NONE, 'Expected no animation')
        assert(lastFishingMessage(player) == xi.fishingMessage.NO_ROD, 'Expected the no rod line')
    end)

    it('refuses a cast without bait', function()
        player:unequipItem(xi.slot.AMMO)

        assert(xi.fishing.onStart(player) == nil, 'Expected no hook time')
        assert(xi.fishing.casts[player:getID()] == nil, 'Expected no cast')
        assert(lastFishingMessage(player) == xi.fishingMessage.NO_BAIT, 'Expected the no bait line')
    end)

    it('refuses a cast in a zone without fishing', function()
        xi.fishing.data.zones[xi.zone.WEST_RONFAURE] = nil

        assert(xi.fishing.onStart(player) == nil, 'Expected no hook time')
        assert(xi.fishing.casts[player:getID()] == nil, 'Expected no cast')
        assert(lastFishingMessage(player) == xi.fishingMessage.CANNOT_FISH_HERE, 'Expected the cannot fish here line')
    end)

    it('refuses a cast outside a cylinder area and opens one inside it', function()
        xi.fishing.data.zones[xi.zone.WEST_RONFAURE].areas =
        {
            pond = { cylinder = { x = 500, y = 0, z = 500, radius = 10 }, pool = {} },
        }

        assert(xi.fishing.onStart(player) == nil, 'Expected no cast away from the pond')
        assert(lastFishingMessage(player) == xi.fishingMessage.CANNOT_FISH_HERE, 'Expected the cannot fish here line')

        local angler = spawnAngler()
        angler:setPos({ x = 505, y = 0, z = 495, rot = 0 })

        assert(xi.fishing.onStart(angler) ~= nil, 'Expected a cast inside the pond')
        assert(xi.fishing.casts[angler:getID()].areaName == 'pond', 'Expected the pond area')
    end)

    it('refuses a cast outside a polygon area and opens one inside it', function()
        xi.fishing.data.zones[xi.zone.WEST_RONFAURE].areas =
        {
            bank =
            {
                poly = { { 500, 0, 500 }, { 520, 0, 500 }, { 520, 0, 520 }, { 500, 0, 520 } },
                pool = {},
            },
        }

        assert(xi.fishing.onStart(player) == nil, 'Expected no cast away from the bank')

        local angler = spawnAngler()
        angler:setPos({ x = 510, y = 0, z = 510, rot = 0 })

        assert(xi.fishing.onStart(angler) ~= nil, 'Expected a cast inside the bank')
        assert(xi.fishing.casts[angler:getID()].areaName == 'bank', 'Expected the bank area')
    end)

    it('falls back to the whole-zone area outside every shape', function()
        xi.fishing.data.zones[xi.zone.WEST_RONFAURE].areas =
        {
            pond       = { cylinder = { x = 500, y = 0, z = 500, radius = 10 }, pool = {} },
            whole_zone = { pool = {} },
        }

        assert(xi.fishing.onStart(player) ~= nil, 'Expected a cast on the fallback area')
        assert(xi.fishing.casts[player:getID()].areaName == 'whole_zone', 'Expected the whole-zone area')
    end)

    it('prefers whole_zone among unshaped areas, else the first by name', function()
        xi.fishing.data.zones[xi.zone.WEST_RONFAURE].areas =
        {
            pirates_chart_quest = { pool = {} },
            whole_zone          = { pool = {} },
        }

        assert(xi.fishing.onStart(player) ~= nil, 'Expected a cast')
        assert(xi.fishing.casts[player:getID()].areaName == 'whole_zone', 'Expected whole_zone over the chart area')

        xi.fishing.data.zones[xi.zone.WEST_RONFAURE].areas =
        {
            purgonorgo_isle   = { pool = {} },
            dhalmel_rock      = { pool = {} },
            maliyakaleya_reef = { pool = {} },
        }

        local sailor = spawnAngler()

        assert(xi.fishing.onStart(sailor) ~= nil, 'Expected a cast')
        assert(xi.fishing.casts[sailor:getID()].areaName == 'dhalmel_rock', 'Expected the first unshaped area by name')
    end)

    it('opens a cast again once an interrupt has cleared the last one', function()
        assert(xi.fishing.onStart(player) ~= nil, 'Expected the first cast to open')

        xi.fishing.onInterrupt(player)

        assert(xi.fishing.casts[player:getID()] == nil, 'Expected the interrupt to drop the cast')
        assert(player:getAnimation() == xi.animation.NONE, 'Expected the interrupt to clear the animation')
        assert(xi.fishing.onStart(player) ~= nil, 'Expected a cast after the interrupt')
    end)

    it('refuses a cast while already fishing with the system line alone', function()
        assert(xi.fishing.onStart(player) ~= nil, 'Expected the first cast to open')

        local cast = xi.fishing.casts[player:getID()]

        assert(xi.fishing.onStart(player) == nil, 'Expected no second cast')
        assert(xi.fishing.casts[player:getID()] == cast, 'Expected the first cast to stay open')
        assert(lastFishingMessage(player) ~= xi.fishingMessage.CANNOT_FISH_MOMENT, 'Expected no cannot fish line')

        -- 0x053 carries the message number in bytes 12 and 13
        local systemMessage = nil
        for _, packet in ipairs(player.packets:getIncoming()) do
            if packet.type == 0x053 then
                systemMessage = packet.data[12] + packet.data[13] * 256
            end
        end

        assert(systemMessage == xi.msg.system.CANNOT_USE_COMMAND_NOW, 'Expected system message 142, got ' .. tostring(systemMessage))
    end)

    it('drops invisible on a cast attempt', function()
        player:addStatusEffect(xi.effect.INVISIBLE, { duration = 60, origin = player, tick = 10 })
        player:unequipItem(xi.slot.RANGED)

        assert(xi.fishing.onStart(player) == nil, 'Expected the rodless cast to fail')
        assert(not player:hasStatusEffect(xi.effect.INVISIBLE), 'Expected invisible to drop even so')
    end)

    it('shortens the hook time at hour 5 and by a second more on the Fisher\'s Rope', function()
        xi.test.world:setVanaTime(5, 0)

        -- 13, minus 4 at new or full moon, minus 1 for the hour.
        local moon     = getVanadielMoonCycle()
        local expected = 12
        if
            moon == xi.moonCycle.NEW_MOON or
            moon == xi.moonCycle.FULL_MOON
        then
            expected = 8
        end

        local dawn = xi.fishing.onStart(player)

        assert(dawn == expected, 'Expected a hook time of ' .. tostring(expected) .. ' at hour 5, got ' .. tostring(dawn))

        local roped = spawnAngler(nil, 99)

        roped:addItem(xi.item.FISHERS_ROPE)
        roped:equipItem(xi.item.FISHERS_ROPE, nil, xi.slot.WAIST)

        local worn = xi.fishing.onStart(roped)

        assert(worn == expected - 1, 'Expected the rope to take a second off, got ' .. tostring(worn))
    end)
end)

describe('Fishing bite roll', function()
    ---@type CClientEntityPair
    local player
    local originalData
    local preferredWorm

    -- Two fish the bait attracts, one it does not, a plain item, a key item fish and a quest item, all in the whole-zone pool.
    local function stockedCatalog()
        local data = testCatalog()

        data.fish =
        {
            [xi.item.GOLD_CARP]       = { name = 'gold_carp', size = xi.fishingSize.SMALL, skill = 11 },
            [xi.item.TRICOLORED_CARP] = { name = 'tricolored_carp', size = xi.fishingSize.SMALL, skill = 20 },
            [xi.item.GUGRUSAURUS]     = { name = 'gugrusaurus', size = xi.fishingSize.LARGE, skill = 140, legendary = xi.fishingLegendaryTier.SUPER, keyItem = xi.keyItem.SERPENT_RUMORS },
            [xi.item.RUSTY_BUCKET]    = { name = 'rusty_bucket', item = true, size = xi.fishingSize.SMALL, skill = 1 },
            [xi.item.RUSTY_LEGGINGS]  = { name = 'rusty_leggings', item = true, size = xi.fishingSize.SMALL, skill = 1, quest = { log = xi.questLog.OTHER_AREAS, id = 25 } },
        }

        data.baits[xi.item.LITTLE_WORM].affinity = { [xi.item.GOLD_CARP] = true, [xi.item.GUGRUSAURUS] = true }

        data.zones[xi.zone.WEST_RONFAURE].areas.whole_zone.pool =
        {
            xi.item.GOLD_CARP,
            xi.item.TRICOLORED_CARP,
            xi.item.GUGRUSAURUS,
            xi.item.RUSTY_BUCKET,
            xi.item.RUSTY_LEGGINGS,
        }

        return data
    end

    -- The values of one bucket's entries, in order.
    local function entryIds(buckets, catchType)
        local ids = {}
        for _, entry in ipairs(buckets.entries[catchType]) do
            table.insert(ids, entry[1])
        end

        return ids
    end

    -- The weight one bucket gives the value, nil when it is not listed.
    local function entryWeight(buckets, catchType, value)
        for _, entry in ipairs(buckets.entries[catchType]) do
            if entry[1] == value then
                return entry[2]
            end
        end

        return nil
    end

    before_each(function()
        originalData    = xi.fishing.data
        preferredWorm   = xi.fishing.preferredCatches[xi.item.LITTLE_WORM]
        xi.fishing.data = stockedCatalog()
        player          = spawnAngler()
    end)

    after_each(function()
        xi.fishing.preferredCatches[xi.item.LITTLE_WORM] = preferredWorm
        xi.fishing.data                                  = originalData
    end)

    -- The gloves are worn too, to prove a piece the captures cleared of any effect changes nothing
    it('moves a quarter of the item pool to no catch under the Fisherman\'s Apron', function()
        xi.test.world:setVanaTime(12, 0)

        local plain = spawnAngler(nil, 99)
        local worn  = spawnAngler(nil, 99)

        worn:addItem(xi.item.FISHERMANS_APRON)
        worn:equipItem(xi.item.FISHERMANS_APRON, nil, xi.slot.BODY)

        assert(xi.fishing.onStart(plain) ~= nil and xi.fishing.onStart(worn) ~= nil, 'Expected both casts')

        local bare  = xi.fishing.biteBuckets(plain, xi.fishing.casts[plain:getID()], xi.fishing.data)
        local apron = xi.fishing.biteBuckets(worn, xi.fishing.casts[worn:getID()], xi.fishing.data)
        local cut   = math.floor(bare.weights[xi.fishing.catchType.ITEM] / 4)

        assert(cut > 0, 'Expected an item pool to cut')
        assert(apron.weights[xi.fishing.catchType.ITEM] == bare.weights[xi.fishing.catchType.ITEM] - cut, 'Expected a quarter off the items, got ' .. tostring(apron.weights[xi.fishing.catchType.ITEM]))
        assert(apron.weights[xi.fishing.catchType.NOTHING] == bare.weights[xi.fishing.catchType.NOTHING] + cut, 'Expected the cut on no catch, got ' .. tostring(apron.weights[xi.fishing.catchType.NOTHING]))
    end)

    it('favours the fish that prefers the bait from skill 20, gear counted', function()
        xi.fishing.preferredCatches[xi.item.LITTLE_WORM]                     = { xi.item.GOLD_CARP }
        xi.fishing.data.baits[xi.item.LITTLE_WORM].affinity[xi.item.TRICOLORED_CARP] = true

        player:setSkillLevel(xi.skill.FISHING, 199)

        assert(xi.fishing.onStart(player) ~= nil, 'Expected a cast')

        local cast    = xi.fishing.casts[player:getID()]
        local buckets = xi.fishing.biteBuckets(player, cast, xi.fishing.data)

        -- The gold carp sits 8 under the angler at skill 19 (57), the tricolored carp 1 over (42)
        assert(entryWeight(buckets, xi.fishing.catchType.FISH, xi.item.GOLD_CARP) == 57, 'Expected the gap weight alone under skill 20')
        assert(entryWeight(buckets, xi.fishing.catchType.FISH, xi.item.TRICOLORED_CARP) == 42, 'Expected the gap weight alone under skill 20')

        player:setSkillLevel(xi.skill.FISHING, 200)

        buckets = xi.fishing.biteBuckets(player, cast, xi.fishing.data)

        assert(entryWeight(buckets, xi.fishing.catchType.FISH, xi.item.GOLD_CARP) == 118, 'Expected the gold carp doubled at skill 20, 59 for 9 under')
        assert(entryWeight(buckets, xi.fishing.catchType.FISH, xi.item.TRICOLORED_CARP) == 42, 'Expected the tricolored carp unchanged')

        player:setSkillLevel(xi.skill.FISHING, 199)
        player:setMod(xi.mod.FISH, 1)

        buckets = xi.fishing.biteBuckets(player, cast, xi.fishing.data)

        assert(entryWeight(buckets, xi.fishing.catchType.FISH, xi.item.GOLD_CARP) == 118, 'Expected gear skill to reach 20')
    end)

    it('weighs each fish by its level against the angler and sums the pool into the fish bucket', function()
        xi.fishing.data.baits[xi.item.LITTLE_WORM].affinity[xi.item.TRICOLORED_CARP] = true

        assert(xi.fishing.onStart(player) ~= nil, 'Expected a cast')

        local cast = xi.fishing.casts[player:getID()]

        -- Skill, then the gold carp at level 11 and the tricolored carp at level 20
        local ladder =
        {
            { 10,  27,  15 }, -- 10 and 19 over: 42 falls 6 percent a level past 3 over
            { 110, 42,  28 }, -- at the carp, 9 over
            { 500, 193, 136 }, -- 39 and 30 under: 42 climbs 4 percent a level
            { 990, 400, 400 }, -- the climb caps at 400
        }

        for _, rung in ipairs(ladder) do
            player:setSkillLevel(xi.skill.FISHING, rung[1])

            local buckets = xi.fishing.biteBuckets(player, cast, xi.fishing.data)

            assert(entryWeight(buckets, xi.fishing.catchType.FISH, xi.item.GOLD_CARP) == rung[2], 'Expected ' .. tostring(rung[2]) .. ' for the gold carp at skill ' .. tostring(rung[1]) .. ', got ' .. tostring(entryWeight(buckets, xi.fishing.catchType.FISH, xi.item.GOLD_CARP)))
            assert(entryWeight(buckets, xi.fishing.catchType.FISH, xi.item.TRICOLORED_CARP) == rung[3], 'Expected ' .. tostring(rung[3]) .. ' for the tricolored carp at skill ' .. tostring(rung[1]) .. ', got ' .. tostring(entryWeight(buckets, xi.fishing.catchType.FISH, xi.item.TRICOLORED_CARP)))
            assert(buckets.weights[xi.fishing.catchType.FISH] == rung[2] + rung[3], 'Expected the fish bucket to hold the sum of the pool')
        end

        -- Sixty over, the floor
        xi.fishing.data.fish[xi.item.GOLD_CARP].skill = 71
        player:setSkillLevel(xi.skill.FISHING, 110)

        assert(entryWeight(xi.fishing.biteBuckets(player, cast, xi.fishing.data), xi.fishing.catchType.FISH, xi.item.GOLD_CARP) == 7, 'Expected the floor far over the angler')
    end)

    -- The Ebisu once hooked every fish at or under the angler's skill; it now draws the same buckets as any rod
    it('draws the same weights on the Ebisu as on the starter rod, at every gap', function()
        xi.fishing.data.rods[xi.item.EBISU_FISHING_ROD] = { name = 'ebisu_fishing_rod', size = xi.fishingSize.SMALL, time = 30, legendary = true }

        assert(xi.fishing.onStart(player) ~= nil, 'Expected a cast')

        local cast = xi.fishing.casts[player:getID()]

        -- 10 and 29 over the carp, at it, 39 under and 88 under
        for _, skill in ipairs({ 10, 110, 500, 990 }) do
            player:setSkillLevel(xi.skill.FISHING, skill)

            cast.rodId = xi.item.WILLOW_FISHING_ROD
            cast.rod   = xi.fishing.data.rods[cast.rodId]

            local willow = xi.fishing.biteBuckets(player, cast, xi.fishing.data)

            cast.rodId = xi.item.EBISU_FISHING_ROD
            cast.rod   = xi.fishing.data.rods[cast.rodId]

            local ebisu = xi.fishing.biteBuckets(player, cast, xi.fishing.data)

            for _, catchType in ipairs({ xi.fishing.catchType.FISH, xi.fishing.catchType.ITEM, xi.fishing.catchType.NOTHING }) do
                assert(ebisu.weights[catchType] == willow.weights[catchType], 'Expected weight ' .. tostring(willow.weights[catchType]) .. ' for catch type ' .. tostring(catchType) .. ' on the Ebisu at skill ' .. tostring(skill) .. ', got ' .. tostring(ebisu.weights[catchType]))
            end

            for _, itemId in ipairs({ xi.item.GOLD_CARP, xi.item.GUGRUSAURUS }) do
                assert(entryWeight(ebisu, xi.fishing.catchType.FISH, itemId) == entryWeight(willow, xi.fishing.catchType.FISH, itemId), 'Expected the same weight for fish ' .. tostring(itemId) .. ' on both rods at skill ' .. tostring(skill))
            end
        end
    end)

    it('lists the fish the bait attracts and the items past their gates', function()
        assert(xi.fishing.onStart(player) ~= nil, 'Expected a cast')

        local cast    = xi.fishing.casts[player:getID()]
        local buckets = xi.fishing.biteBuckets(player, cast, xi.fishing.data)
        local fish    = entryIds(buckets, xi.fishing.catchType.FISH)
        local items   = entryIds(buckets, xi.fishing.catchType.ITEM)

        assert(#fish == 1 and fish[1] == xi.item.GOLD_CARP, 'Expected only the gold carp: no affinity for the tricolored carp, no key item for the gugrusaurus')
        assert(#items == 1 and items[1] == xi.item.RUSTY_BUCKET, 'Expected only the bucket, the leggings quest is not accepted')
        assert(buckets.weights[xi.fishing.catchType.FISH] == entryWeight(buckets, xi.fishing.catchType.FISH, xi.item.GOLD_CARP), 'Expected the fish bucket to hold the carp alone')
        assert(buckets.weights[xi.fishing.catchType.ITEM] == 6, 'Expected the junk weight of the bucket alone')
        assert(buckets.weights[xi.fishing.catchType.NOTHING] > 0, 'Expected an empty cast weight')

        player:addKeyItem(xi.keyItem.SERPENT_RUMORS)

        buckets = xi.fishing.biteBuckets(player, cast, xi.fishing.data)
        fish    = entryIds(buckets, xi.fishing.catchType.FISH)

        assert(#fish == 2, 'Expected the gugrusaurus once the key item is held')
    end)

    it('draws items as often as fish under the Moghancement: Fishing Item', function()
        assert(xi.fishing.onStart(player) ~= nil, 'Expected a cast')

        local cast    = xi.fishing.casts[player:getID()]
        local buckets = xi.fishing.biteBuckets(player, cast, xi.fishing.data)

        assert(buckets.weights[xi.fishing.catchType.ITEM] < buckets.weights[xi.fishing.catchType.FISH], 'Expected items behind fish without the moghancement')

        player:addKeyItem(xi.keyItem.MOGHANCEMENT_FISHING_ITEMS)

        buckets = xi.fishing.biteBuckets(player, cast, xi.fishing.data)

        assert(buckets.weights[xi.fishing.catchType.ITEM] == buckets.weights[xi.fishing.catchType.FISH], 'Expected items level with fish under the moghancement')
    end)

    -- A full lunar cycle is 84 days, so the walk ends on the phase it started from
    it('draws the same item and empty cast weights at every moon phase', function()
        xi.test.world:setVanaTime(12, 0)

        assert(xi.fishing.onStart(player) ~= nil, 'Expected a cast')

        local cast   = xi.fishing.casts[player:getID()]
        local first  = xi.fishing.biteBuckets(player, cast, xi.fishing.data).weights
        local phases = {}
        local seen   = 0

        for _ = 1, 84 do
            xi.test.world:skipVanaDays(1)

            local moon    = getVanadielMoonCycle()
            local weights = xi.fishing.biteBuckets(player, cast, xi.fishing.data).weights

            if not phases[moon] then
                phases[moon] = true
                seen         = seen + 1
            end

            for _, catchType in ipairs({ xi.fishing.catchType.ITEM, xi.fishing.catchType.NOTHING }) do
                assert(weights[catchType] == first[catchType], 'Expected weight ' .. tostring(first[catchType]) .. ' for catch type ' .. tostring(catchType) .. ' at moon phase ' .. tostring(moon) .. ', got ' .. tostring(weights[catchType]))
            end
        end

        assert(seen == 12, 'Expected the walk to visit all 12 moon phases, saw ' .. tostring(seen))
    end)

    it('hooks nothing from an empty area', function()
        xi.fishing.data.zones[xi.zone.WEST_RONFAURE].areas.whole_zone.pool = {}

        assert(xi.fishing.onStart(player) ~= nil, 'Expected a cast')

        local cast    = xi.fishing.casts[player:getID()]
        local buckets = xi.fishing.biteBuckets(player, cast, xi.fishing.data)

        assert(buckets.weights[xi.fishing.catchType.NOTHING] == 1000, 'Expected a certain empty cast')
        assert(xi.fishing.rollBite(player, cast, xi.fishing.data) == nil, 'Expected nothing to bite')
    end)
end)
