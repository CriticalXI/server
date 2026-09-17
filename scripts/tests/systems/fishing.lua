-----------------------------------
-- Fishing lifecycle framework
--
-- A player with no cast live is ignored by the entry points that need
-- one, the entry checks open or refuse a cast against an injected
-- catalog, and casts run through the client packets and the seam.
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

local ffi = require('ffi')

-- The 0x01A action and the 0x110 fishing packets as the client sends them, header first
ffi.cdef [[
    typedef struct {
        uint32_t header;
        uint32_t UniqueNo;
        uint16_t ActIndex;
        uint16_t ActionID;
        uint32_t ActionBuf[4];
    } FISHING_TEST_ACTION;

    typedef struct {
        uint32_t header;
        uint32_t UniqueNo;
        int32_t  para;
        uint16_t ActIndex;
        int8_t   mode;
        uint8_t  dammy;
        int32_t  para2;
    } FISHING_TEST_FISHING_2;
]]

-- A player in West Ronfaure, or the zone given, holding the catalog's rod and bait. Level 1 unless given; the leveled gear needs more.
local function spawnAngler(zone, level)
    local player = xi.test.world:spawnPlayer({ zone = zone or xi.zone.WEST_RONFAURE, level = level })

    player:addItem(xi.item.WILLOW_FISHING_ROD)
    player:addItem(xi.item.LITTLE_WORM)
    player:equipItem(xi.item.WILLOW_FISHING_ROD, nil, xi.slot.RANGED)
    player:equipItem(xi.item.LITTLE_WORM, nil, xi.slot.AMMO)

    return player
end

-- The Land Crab the zone data lets a West Ronfaure cast fish up
local crabId = 17186819

-- Get the crab, failing clearly if its ID has changed
local function landCrab()
    local crab = GetMobByID(crabId)

    assert(crab ~= nil, 'Expected the Land Crab the West Ronfaure zone data pools')

    return crab
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

-- Every fishing line sent to the player, as offsets from the same base, in order.
local function fishingMessages(player)
    local base     = zones[xi.zone.WEST_RONFAURE].text.FISHING_MESSAGE_OFFSET
    local messages = {}

    for _, packet in ipairs(player.packets:getIncoming()) do
        if packet.type == 0x036 then
            table.insert(messages, bit.band(packet.data[10] + packet.data[11] * 256, 0x7FFF) - base)
        end
    end

    return messages
end

-- Write and read the three meter char vars directly
local function setMeters(player, meters)
    player:setCharVar('[Fish]DailyPoints', meters.daily)
    player:setCharVar('[Fish]Fatigue', meters.fatigue)
    player:setCharVar('[Fish]Today', meters.today)
end

local function readMeters(player)
    return
    {
        daily   = player:getCharVar('[Fish]DailyPoints'),
        fatigue = player:getCharVar('[Fish]Fatigue'),
        today   = player:getCharVar('[Fish]Today'),
    }
end

-- A caught monster with only the type and mob name the fatigue classifier reads
local function fishedMonster(name)
    local mob = {}

    mob.getName = function()
        return name
    end

    return { type = xi.fishing.catchType.MONSTER, mob = mob }
end

describe('Fishing lifecycle', function()
    ---@type CClientEntityPair
    local player

    before_each(function()
        player = xi.test.world:spawnPlayer()
    end)

    it('ignores a fishing action and an interrupt while the player is idle', function()
        assert(xi.fishing.onAction(player, xi.fishing.mode.CHECK_HOOK, 0, 0) == nil, 'Expected no fight')
        xi.fishing.onInterrupt(player)

        assert(xi.fishing.casts[player:getID()] == nil, 'Expected no cast to be opened')
    end)
end)

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

    it('fishes the area named after the leg a transport is on, else falls back', function()
        xi.fishing.data.zones[xi.zone.MANACLIPPER] =
        {
            areas    =
            {
                east_bank  = { pool = {} },
                west_bank  = { pool = {} },
                whole_zone = { pool = {} },
            },
            monsters = {},
        }

        local leg    = stub('xi.manaclipper.currentRoute', 'west_bank')
        local sailor = spawnAngler(xi.zone.MANACLIPPER)

        assert(xi.fishing.onStart(sailor) ~= nil, 'Expected a cast')
        assert(xi.fishing.casts[sailor:getID()].areaName == 'west_bank', 'Expected the area of the leg in progress')

        leg:returnValue('harbour')

        local drifter = spawnAngler(xi.zone.MANACLIPPER)

        assert(xi.fishing.onStart(drifter) ~= nil, 'Expected a cast')
        assert(xi.fishing.casts[drifter:getID()].areaName == 'whole_zone', 'Expected the fallback on a leg no area names')
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

    -- Reset the crab in case a failed test left it hooked or on a cooldown
    after_each(function()
        local crab = landCrab()

        crab:setLocalVar('hooked', 0)
        crab:setLocalVar('respawnAt', 0)

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

            for _, catchType in ipairs({ xi.fishing.catchType.FISH, xi.fishing.catchType.ITEM, xi.fishing.catchType.MONSTER, xi.fishing.catchType.NOTHING }) do
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
        assert(buckets.weights[xi.fishing.catchType.MONSTER] == 0, 'Expected no monster weight with no monsters')
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
    it('draws the same item, monster and empty cast weights at every moon phase', function()
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

            for _, catchType in ipairs({ xi.fishing.catchType.ITEM, xi.fishing.catchType.MONSTER, xi.fishing.catchType.NOTHING }) do
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

    it('lets a dead crab bite until it is hooked or on its respawn time', function()
        local crab = landCrab()

        xi.fishing.data.zones[xi.zone.WEST_RONFAURE].monsters = { [crabId] = {} }

        assert(xi.fishing.onStart(player) ~= nil, 'Expected a cast')
        assert(not crab:isSpawned(), 'Expected the fished crab dead in the water')

        local cast = xi.fishing.casts[player:getID()]

        assert(#entryIds(xi.fishing.biteBuckets(player, cast, xi.fishing.data), xi.fishing.catchType.MONSTER) == 1, 'Expected the crab to bite')

        crab:setLocalVar('hooked', 1)

        assert(#entryIds(xi.fishing.biteBuckets(player, cast, xi.fishing.data), xi.fishing.catchType.MONSTER) == 0, 'Expected no bite while another line holds it')

        crab:setLocalVar('hooked', 0)
        crab:setLocalVar('respawnAt', GetSystemTime() + 600)

        assert(#entryIds(xi.fishing.biteBuckets(player, cast, xi.fishing.data), xi.fishing.catchType.MONSTER) == 0, 'Expected no bite on its respawn time')
    end)

    it('answers an early hook check with an empty cast', function()
        assert(xi.fishing.onStart(player) ~= nil, 'Expected a cast')
        assert(xi.fishing.onAction(player, xi.fishing.mode.CHECK_HOOK, 0, 0) == nil, 'Expected no fight before the timer')

        assert(xi.fishing.casts[player:getID()].stage == xi.fishing.stage.EMPTY, 'Expected the empty stage')
        assert(player:getAnimation() == xi.animation.NEW_FISHING_STOP, 'Expected the stop animation')
        assert(lastFishingMessage(player) == xi.fishingMessage.NO_CATCH, 'Expected the no catch line')
    end)
end)

describe('Fishing outcome', function()
    ---@type CClientEntityPair
    local player
    local originalData

    local function outcomeCatalog()
        local data = testCatalog()

        data.fish[xi.item.MOAT_CARP_1]       = { name = 'moat_carp', size = xi.fishingSize.SMALL, skill = 11 }
        data.rods[xi.item.EBISU_FISHING_ROD] = { name = 'ebisu_fishing_rod', size = xi.fishingSize.SMALL, time = 30, legendary = true, legendaryTime = 10 }

        return data
    end

    -- A cast in the fighting stage with a moat carp on the line, as the hook check leaves it, the bite long past.
    local function fightingCast(rodId)
        local cast =
        {
            zone     = xi.fishing.data.zones[xi.zone.WEST_RONFAURE],
            rodId    = rodId,
            rod      = xi.fishing.data.rods[rodId],
            baitId   = xi.item.LITTLE_WORM,
            bait     = xi.fishing.data.baits[xi.item.LITTLE_WORM],
            stage    = xi.fishing.stage.FIGHTING,
            hookedAt = 0,
        }

        cast.catch = { type = xi.fishing.catchType.FISH, itemId = xi.item.MOAT_CARP_1, record = xi.fishing.data.fish[xi.item.MOAT_CARP_1], count = 1 }
        cast.fight = xi.fishing.hookCatch(player, cast, cast.catch)

        return cast
    end

    before_each(function()
        originalData    = xi.fishing.data
        xi.fishing.data = outcomeCatalog()
        player          = spawnAngler()
        player:setSkillLevel(xi.skill.FISHING, 980)
    end)

    after_each(function()
        xi.fishing.data = originalData
    end)

    it('lands a claimed moat carp and takes the bait', function()
        local cast   = fightingCast(xi.item.EBISU_FISHING_ROD)
        local result = xi.fishing.resolveCatch(player, cast, 0, cast.fight.intuition)

        assert(result == xi.fishing.result.CAUGHT, 'Expected the catch, nothing can fail on Ebisu at 98')
        assert(player:hasItem(xi.item.MOAT_CARP_1), 'Expected the fish in the inventory')
        assert(not player:hasItem(xi.item.LITTLE_WORM), 'Expected the worm gone')
        assert(player:getAnimation() == xi.animation.NEW_FISHING_CAUGHT, 'Expected the caught animation')
    end)

    it('loses a claim whose intuition echo is wrong', function()
        local cast   = fightingCast(xi.item.EBISU_FISHING_ROD)
        local result = xi.fishing.resolveCatch(player, cast, 0, cast.fight.intuition + 1)

        assert(result == xi.fishing.result.LOST, 'Expected the catch lost')
        assert(not player:hasItem(xi.item.MOAT_CARP_1), 'Expected no fish')
        assert(player:getAnimation() == xi.animation.NEW_FISHING_STOP, 'Expected the stop animation')
        assert(lastFishingMessage(player) == xi.fishingMessage.LOST, 'Expected the lost line')
    end)

    it('charges a loss to lack of skill ten daily points', function()
        local angler = spawnAngler(nil, xi.settings.map.FISHING_MIN_LEVEL)
        local cast   = fightingCast(xi.item.WILLOW_FISHING_ROD)

        xi.test.world:setSetting('map.FISHING_FATIGUE_ENABLE', true)

        -- Put the claim roll on the lack-of-skill loss
        cast.fight.chances = { lowSkill = 100, lineSnap = 0, rodBreak = 0, sizeLoss = 0 }

        local result = xi.fishing.resolveCatch(angler, cast, 0, cast.fight.intuition)

        assert(result == xi.fishing.result.LOW_SKILL, 'Expected the lack-of-skill loss')
        assert(angler:getCharVar('[Fish]DailyPoints') == 10, 'Expected 10 daily points, got ' .. tostring(angler:getCharVar('[Fish]DailyPoints')))
    end)

    it('charges a catch won into a full inventory its point', function()
        local angler = spawnAngler(nil, xi.settings.map.FISHING_MIN_LEVEL)
        local cast   = fightingCast(xi.item.EBISU_FISHING_ROD)

        xi.test.world:setSetting('map.FISHING_FATIGUE_ENABLE', true)

        while angler:getFreeSlotsCount() > 0 do
            angler:addItem({ id = xi.item.WILLOW_FISHING_ROD, silent = true })
        end

        local result = xi.fishing.resolveCatch(angler, cast, 0, cast.fight.intuition)

        assert(result == xi.fishing.result.LOST, 'Expected the catch lost to the full inventory')
        assert(not angler:hasItem(xi.item.MOAT_CARP_1), 'Expected no fish')
        assert(angler:getCharVar('[Fish]DailyPoints') == 1, 'Expected the won catch to cost its point, got ' .. tostring(angler:getCharVar('[Fish]DailyPoints')))
    end)

    it('reads over-level as 17 or more levels above the effective skill, gear included', function()
        local carp = xi.fishing.data.fish[xi.item.MOAT_CARP_1]

        xi.test.world:setSetting('map.FISHING_FATIGUE_ENABLE', true)

        -- A give-up only costs fatigue when over level and skips the claim roll
        local function fatigueAfterGiveUp(level)
            carp.skill = level
            setMeters(player, { daily = 0, fatigue = 0, today = 1 })
            xi.fishing.resolveCatch(player, fightingCast(xi.item.WILLOW_FISHING_ROD), 200, 0)

            return player:getCharVar('[Fish]Fatigue')
        end

        assert(fatigueAfterGiveUp(98 + 16) == 0, 'Expected 16 over to be in range')
        assert(fatigueAfterGiveUp(98 + 17) == 100, 'Expected 17 over to be over-level')

        player:setMod(xi.mod.FISH, 3)

        assert(fatigueAfterGiveUp(98 + 19) == 0, 'Expected gear skill to count')

        player:setMod(xi.mod.FISH, 0)
    end)

    it('ends a give-up with the bait gone and says so', function()
        local cast   = fightingCast(xi.item.EBISU_FISHING_ROD)
        local result = xi.fishing.resolveCatch(player, cast, 200, cast.fight.intuition)

        assert(result == xi.fishing.result.GAVE_UP, 'Expected the give-up the corpus saw at 200')
        assert(not player:hasItem(xi.item.LITTLE_WORM), 'Expected the worm gone')
        assert(lastFishingMessage(player) == xi.fishingMessage.GIVE_UP_BAIT_LOSS, 'Expected the give-up line with the bait')
        assert(player:getAnimation() == xi.animation.NEW_FISHING_STOP, 'Expected the stop animation')
    end)

    it('takes the client at its word on a line break', function()
        local cast   = fightingCast(xi.item.EBISU_FISHING_ROD)
        local result = xi.fishing.resolveCatch(player, cast, 100, 0)

        assert(result == xi.fishing.result.LINE_BREAK, 'Expected the line break')
        assert(player:getAnimation() == xi.animation.NEW_FISHING_LINE_BREAK, 'Expected the line break animation')
        assert(lastFishingMessage(player) == xi.fishingMessage.LINE_BREAK, 'Expected the line break line')
    end)
end)

describe('Fishing cast end to end', function()
    ---@type CClientEntityPair
    local player
    local originalData

    -- A moat carp the worm attracts as the only thing in the water, an Ebisu beside the Willow rod, and the crab.
    local function riverCatalog()
        local data = testCatalog()

        data.fish[xi.item.MOAT_CARP_1]                          = { name = 'moat_carp', size = xi.fishingSize.SMALL, skill = 11 }
        data.rods[xi.item.EBISU_FISHING_ROD]                    = { name = 'ebisu_fishing_rod', size = xi.fishingSize.SMALL, time = 30, legendary = true, legendaryTime = 10 }
        data.baits[xi.item.LITTLE_WORM].affinity                = { [xi.item.MOAT_CARP_1] = true }
        data.zones[xi.zone.WEST_RONFAURE].areas.whole_zone.pool = { xi.item.MOAT_CARP_1 }
        data.zones[xi.zone.WEST_RONFAURE].monsters              = { [crabId] = {} }

        return data
    end

    -- Opens a cast and moves its start back past the hook timer and the claim floor, so the hook check and the claim that follow are on time.
    local function openCast(angler)
        assert(xi.fishing.onStart(angler) ~= nil, 'Expected the cast to open')

        local cast = xi.fishing.casts[angler:getID()]

        cast.startedAt = cast.startedAt - cast.hookTime - 2

        return cast
    end

    -- Serves the moat carp on every bite roll.
    local function biteMoatCarp()
        stub('xi.fishing.rollBite', function()
            return { type = xi.fishing.catchType.FISH, itemId = xi.item.MOAT_CARP_1, record = xi.fishing.data.fish[xi.item.MOAT_CARP_1], count = 1 }
        end)
    end

    -- The 0x01A fishing action and the 0x110 fishing packets, through the C++ seam
    ---@diagnostic disable: inject-field
    local function sendCastPacket(angler)
        local action    = ffi.new('FISHING_TEST_ACTION')
        action.UniqueNo = angler:getID()
        action.ActIndex = angler:getTargID()
        action.ActionID = 14 -- GP_CLI_COMMAND_ACTION_ACTIONID::Fish

        angler.packets:send(0x01A, action, ffi.sizeof(action))
    end

    local function sendFishingPacket(angler, mode, para, para2)
        local fishing    = ffi.new('FISHING_TEST_FISHING_2')
        fishing.UniqueNo = angler:getID()
        fishing.ActIndex = angler:getTargID()
        fishing.mode     = mode
        fishing.para     = para
        fishing.para2    = para2

        angler.packets:send(0x110, fishing, ffi.sizeof(fishing))
    end

    ---@diagnostic enable: inject-field

    local function countPackets(angler, packetType)
        local count = 0
        for _, packet in ipairs(angler.packets:getIncoming()) do
            if packet.type == packetType then
                count = count + 1
            end
        end

        return count
    end

    -- Serves the crab on every bite roll.
    local function biteCrab(crab)
        stub('xi.fishing.rollBite', function()
            return { type = xi.fishing.catchType.MONSTER, spawnId = crabId, mob = crab, record = xi.fishing.data.zones[xi.zone.WEST_RONFAURE].monsters[crabId] }
        end)
    end

    before_each(function()
        originalData    = xi.fishing.data
        xi.fishing.data = riverCatalog()

        xi.test.world:setSetting('map.FISHING_ENABLE', true)

        -- A job at the fishing minimum level keeps the full daily allowance
        player = spawnAngler(nil, xi.settings.map.FISHING_MIN_LEVEL)

        player:setSkillLevel(xi.skill.FISHING, 980)
    end)

    -- Clean up the crab in case a failed test left it spawned, hooked or on a cooldown
    after_each(function()
        local crab = landCrab()

        if crab:isSpawned() then
            player.entities:get(crab):despawn()
        end

        crab:removeListener('FISHING_COOLDOWN')
        crab:setLocalVar('hooked', 0)
        crab:setLocalVar('respawnAt', 0)

        xi.fishing.monsters[crab:getName()] = nil
        xi.fishing.data                     = originalData
    end)

    it('lands a moat carp from the cast to the release', function()
        biteMoatCarp()

        local cast  = openCast(player)
        local fight = xi.fishing.onAction(player, xi.fishing.mode.CHECK_HOOK, 0, 0)

        assert(fight ~= nil and fight == cast.fight, 'Expected the hook check to answer with the fight')

        assert(cast.stage == xi.fishing.stage.FIGHTING, 'Expected the fighting stage')
        assert(player:getAnimation() == xi.animation.NEW_FISHING_FISH, 'Expected the fighting animation')
        assert(fishingMessages(player)[1] == xi.fishingMessage.HOOKED_SMALL_FISH, 'Expected the small fish hook line')

        assert(xi.fishing.onAction(player, xi.fishing.mode.END_MINIGAME, 0, fight.intuition) == nil, 'Expected nothing back on the claim')
        assert(cast.result == xi.fishing.result.CAUGHT, 'Expected the catch, nothing can fail 87 levels over')
        assert(cast.stage == xi.fishing.stage.RESOLVED, 'Expected the resolved stage')
        assert(player:hasItem(xi.item.MOAT_CARP_1), 'Expected the carp in the inventory')
        assert(not player:hasItem(xi.item.LITTLE_WORM), 'Expected the worm gone')
        assert(player:getAnimation() == xi.animation.NEW_FISHING_CAUGHT, 'Expected the caught animation')

        xi.fishing.onAction(player, xi.fishing.mode.RELEASE, 0, 0)

        assert(xi.fishing.casts[player:getID()] == nil, 'Expected the cast closed at the release')
        assert(player:getAnimation() == xi.animation.NONE, 'Expected the animation cleared')
    end)

    it('closes the cast empty and warns on a fish with no fight row', function()
        assert(xi.fishing.catchStats[60001] == nil, 'Expected no fight row at the test id')

        xi.fishing.data.fish[60001] = { name = 'rowless fish', size = xi.fishingSize.SMALL, skill = 11 }

        stub('xi.fishing.rollBite', function()
            return { type = xi.fishing.catchType.FISH, itemId = 60001, record = xi.fishing.data.fish[60001], count = 1 }
        end)

        local warned = spy('printf')
        local cast   = openCast(player)

        xi.fishing.onAction(player, xi.fishing.mode.CHECK_HOOK, 0, 0)

        warned:calledWith('[warning] fishing: no fight row for item %i', 60001)
        assert(cast.stage == xi.fishing.stage.EMPTY, 'Expected the empty stage')
        assert(player:getAnimation() == xi.animation.NEW_FISHING_STOP, 'Expected the stop animation')
        assert(lastFishingMessage(player) == xi.fishingMessage.NO_CATCH, 'Expected the no catch line')

        xi.fishing.onAction(player, xi.fishing.mode.RELEASE, 0, 0)

        assert(xi.fishing.casts[player:getID()] == nil, 'Expected the cast closed at the release')
    end)

    it('ends an empty cast at the release with the worm still on the hook', function()
        stub('xi.fishing.rollBite', function()
            return nil
        end)

        local cast = openCast(player)

        assert(xi.fishing.onAction(player, xi.fishing.mode.CHECK_HOOK, 0, 0) == nil, 'Expected no fight')
        assert(cast.stage == xi.fishing.stage.EMPTY, 'Expected the empty stage')
        assert(player:getAnimation() == xi.animation.NEW_FISHING_STOP, 'Expected the stop animation')
        assert(lastFishingMessage(player) == xi.fishingMessage.NO_CATCH, 'Expected the no catch line')

        assert(xi.fishing.onAction(player, xi.fishing.mode.END_MINIGAME, 200, 0) == nil, 'Expected a claim with nothing hooked ignored')
        assert(cast.stage == xi.fishing.stage.EMPTY, 'Expected the stage untouched by it')

        xi.fishing.onAction(player, xi.fishing.mode.RELEASE, 0, 0)

        assert(xi.fishing.casts[player:getID()] == nil, 'Expected the cast closed')
        assert(player:getAnimation() == xi.animation.NONE, 'Expected the animation cleared')
        assert(player:hasItem(xi.item.LITTLE_WORM), 'Expected the worm kept')
    end)

    it('counts the casts and the hits for Katsunaga and keeps the longest and heaviest carp', function()
        -- The first carp is 30 ilms, the second 20, and the third cast hooks nothing
        local castsMade = 0
        stub('xi.fishing.rollBite', function()
            castsMade = castsMade + 1
            if castsMade == 3 then
                return nil
            end

            xi.fishing.data.fish[xi.item.MOAT_CARP_1].length = { 40 - castsMade * 10, 40 - castsMade * 10 }

            return { type = xi.fishing.catchType.FISH, itemId = xi.item.MOAT_CARP_1, record = xi.fishing.data.fish[xi.item.MOAT_CARP_1], count = 1 }
        end)

        local cast = openCast(player)
        xi.fishing.onAction(player, xi.fishing.mode.CHECK_HOOK, 0, 0)
        xi.fishing.onAction(player, xi.fishing.mode.END_MINIGAME, 0, cast.fight.intuition)
        xi.fishing.onAction(player, xi.fishing.mode.RELEASE, 0, 0)

        assert(player:getCharVar('[Fish]Casts') == 1, 'Expected the cast counted')
        assert(player:getCharVar('[Fish]Hits') == 1, 'Expected the hit counted')
        assert(player:getCharVar('[Fish]Longest') == 30, 'Expected the carp as the longest fish')
        assert(player:getCharVar('[Fish]LongestFish') == xi.item.MOAT_CARP_1, 'Expected the carp named for its length')
        assert(player:getCharVar('[Fish]HeaviestFish') == xi.item.MOAT_CARP_1, 'Expected the carp named for its weight')

        local heaviest = player:getCharVar('[Fish]Heaviest')
        assert(heaviest > 0, 'Expected the carp as the heaviest fish')

        -- The smaller carp leaves both records, and the empty cast counts a cast but no hit
        for _ = 1, 2 do
            player:addItem(xi.item.LITTLE_WORM)
            player:equipItem(xi.item.LITTLE_WORM, nil, xi.slot.AMMO)

            cast = openCast(player)
            if xi.fishing.onAction(player, xi.fishing.mode.CHECK_HOOK, 0, 0) then
                xi.fishing.onAction(player, xi.fishing.mode.END_MINIGAME, 0, cast.fight.intuition)
            end

            xi.fishing.onAction(player, xi.fishing.mode.RELEASE, 0, 0)
        end

        assert(player:getCharVar('[Fish]Casts') == 3, 'Expected three casts counted')
        assert(player:getCharVar('[Fish]Hits') == 2, 'Expected two hits, the empty cast not among them')
        assert(player:getCharVar('[Fish]Longest') == 30, 'Expected the longest record kept')
        assert(player:getCharVar('[Fish]Heaviest') == heaviest, 'Expected the heaviest record kept')
    end)

    it('gives up on a hooked carp and loses the worm', function()
        biteMoatCarp()

        local cast = openCast(player)

        assert(xi.fishing.onAction(player, xi.fishing.mode.CHECK_HOOK, 0, 0) ~= nil, 'Expected the fight')

        xi.fishing.onAction(player, xi.fishing.mode.END_MINIGAME, 200, 0)

        assert(cast.result == xi.fishing.result.GAVE_UP, 'Expected the give-up the corpus saw at 200')
        assert(not player:hasItem(xi.item.LITTLE_WORM), 'Expected the worm gone')
        assert(not player:hasItem(xi.item.MOAT_CARP_1), 'Expected no carp')
        assert(lastFishingMessage(player) == xi.fishingMessage.GIVE_UP_BAIT_LOSS, 'Expected the give-up line with the bait')
        assert(player:getAnimation() == xi.animation.NEW_FISHING_STOP, 'Expected the stop animation')

        xi.fishing.onAction(player, xi.fishing.mode.RELEASE, 0, 0)

        assert(xi.fishing.casts[player:getID()] == nil, 'Expected the cast closed')
    end)

    it('ignores a claim before the bite and warns on a timeout during the fight', function()
        local cast = openCast(player)

        assert(xi.fishing.onAction(player, xi.fishing.mode.END_MINIGAME, 0, 0) == nil, 'Expected nothing back')
        assert(cast.stage == xi.fishing.stage.CAST and cast.result == nil, 'Expected a claim before the bite ignored')

        biteMoatCarp()

        assert(xi.fishing.onAction(player, xi.fishing.mode.CHECK_HOOK, 0, 0) ~= nil, 'Expected the fight')

        xi.fishing.onAction(player, xi.fishing.mode.POTENTIAL_TIMEOUT, 5, 0)

        assert(lastFishingMessage(player) == xi.fishingMessage.WARNING, 'Expected the warning line')
        assert(cast.stage == xi.fishing.stage.FIGHTING, 'Expected the fight to go on')
    end)

    -- Mode 0 is outside the 0x110 enum, which the core hands over unchecked
    it('ignores a mode the client never sends', function()
        local cast = openCast(player)

        assert(xi.fishing.onAction(player, 0, 0, 0) == nil, 'Expected nothing back')
        assert(cast.stage == xi.fishing.stage.CAST, 'Expected the cast untouched')
    end)

    it('takes the worm and closes the cast on an interrupt mid-fight', function()
        biteMoatCarp()

        openCast(player)

        assert(xi.fishing.onAction(player, xi.fishing.mode.CHECK_HOOK, 0, 0) ~= nil, 'Expected the fight')

        xi.fishing.onInterrupt(player)

        assert(xi.fishing.casts[player:getID()] == nil, 'Expected the cast closed')
        assert(player:getAnimation() == xi.animation.NONE, 'Expected the animation cleared')
        assert(not player:hasItem(xi.item.LITTLE_WORM), 'Expected the worm gone as on a give-up')

        player:addItem(xi.item.LITTLE_WORM)
        player:equipItem(xi.item.LITTLE_WORM, nil, xi.slot.AMMO)

        assert(xi.fishing.onStart(player) ~= nil, 'Expected a cast to open again')
    end)

    it('gives the crab back and takes the worm on a release sent mid-fight', function()
        local crab = landCrab()

        biteCrab(crab)
        openCast(player)

        assert(xi.fishing.onAction(player, xi.fishing.mode.CHECK_HOOK, 0, 0) ~= nil, 'Expected the fight')
        assert(crab:getLocalVar('hooked') == 1, 'Expected the crab on the line')

        xi.fishing.onAction(player, xi.fishing.mode.RELEASE, 0, 0)

        assert(crab:getLocalVar('hooked') == 0, 'Expected the crab back in the water')
        assert(xi.fishing.casts[player:getID()] == nil, 'Expected the cast closed')
        assert(not player:hasItem(xi.item.LITTLE_WORM), 'Expected the worm gone as on a give-up')
    end)

    it('loses a claim sent inside two seconds of the bite', function()
        biteMoatCarp()

        local cast  = openCast(player)
        local fight = xi.fishing.onAction(player, xi.fishing.mode.CHECK_HOOK, 0, 0)

        assert(fight ~= nil, 'Expected the fight')

        cast.hookedAt = GetSystemTime()
        xi.fishing.onAction(player, xi.fishing.mode.END_MINIGAME, 0, fight.intuition)

        assert(cast.result == xi.fishing.result.LOST, 'Expected the instant claim lost')
        assert(not player:hasItem(xi.item.MOAT_CARP_1), 'Expected no carp')
    end)

    it('raises the skill at the release on a landed carp two levels over', function()
        player:setSkillLevel(xi.skill.FISHING, 90)

        -- Every roll is 1 so the claim can't fail and the skill-up chance is met
        stub('math.randomInt', function()
            return 1
        end)

        biteMoatCarp()

        local cast  = openCast(player)
        local fight = xi.fishing.onAction(player, xi.fishing.mode.CHECK_HOOK, 0, 0)

        assert(fight ~= nil, 'Expected the fight')

        xi.fishing.onAction(player, xi.fishing.mode.END_MINIGAME, 0, fight.intuition)

        assert(cast.result == xi.fishing.result.CAUGHT, 'Expected the catch')

        xi.fishing.onAction(player, xi.fishing.mode.RELEASE, 0, 0)

        assert(player:getCharSkillLevel(xi.skill.FISHING) == 91, 'Expected a tenth of a point at the release, got ' .. tostring(player:getCharSkillLevel(xi.skill.FISHING)))
    end)

    it('fishes up the crab, engages it and stamps its cooldown when it leaves the world', function()
        local crab = landCrab()

        assert(not crab:isSpawned(), 'Expected the fished crab dead in the water')

        xi.fishing.monsters[crab:getName()] = { cooldown = 600 }

        player:addItem(xi.item.EBISU_FISHING_ROD)
        player:equipItem(xi.item.EBISU_FISHING_ROD, nil, xi.slot.RANGED)
        biteCrab(crab)

        local cast  = openCast(player)
        local fight = xi.fishing.onAction(player, xi.fishing.mode.CHECK_HOOK, 0, 0)

        assert(fight ~= nil, 'Expected the fight')
        assert(crab:getLocalVar('hooked') == 1, 'Expected the crab on the line')
        assert(fishingMessages(player)[1] == xi.fishingMessage.HOOKED_MONSTER, 'Expected the monster hook line')
        assert(bit.band(fight.angler_sense, 1) == 1, 'Expected the large bit on a monster')

        xi.fishing.onAction(player, xi.fishing.mode.END_MINIGAME, 0, fight.intuition)

        assert(cast.result == xi.fishing.result.CAUGHT, 'Expected the crab landed, nothing can fail on Ebisu')
        assert(crab:isSpawned(), 'Expected the crab in the world')
        assert(crab:getLocalVar('hooked') == 0, 'Expected the line freed')
        assert(crab:getLocalVar('respawnAt') == 0, 'Expected no cooldown while the crab is up')
        assert(crab:hasListener('DESPAWN'), 'Expected the cooldown waiting on the despawn')
        assert(player:getAnimation() == xi.animation.NEW_FISHING_MONSTER, 'Expected the monster animation')

        xi.fishing.onAction(player, xi.fishing.mode.RELEASE, 0, 0)

        assert(xi.fishing.casts[player:getID()] == nil, 'Expected the cast closed')

        -- Despawn the crab so its cooldown starts and keeps it out of the pool
        player.entities:get(crab):despawn()

        assert(not crab:isSpawned(), 'Expected the crab gone')

        local record = xi.fishing.data.zones[xi.zone.WEST_RONFAURE].monsters[crabId]

        assert(crab:getLocalVar('respawnAt') >= GetSystemTime() + 599, 'Expected the cooldown stamped 600 seconds out from the despawn')
        assert(not crab:hasListener('DESPAWN'), 'Expected the listener gone with its one use')
        assert(not xi.fishing.confirmMonsterEntry(player, record, crab), 'Expected the crab off the pool on its cooldown')

        crab:setLocalVar('respawnAt', 0)

        assert(xi.fishing.confirmMonsterEntry(player, record, crab), 'Expected the crab back on the pool once the cooldown is served')
    end)

    it('ends the cast empty when the crab drawn is already in the world', function()
        local crab = landCrab()

        crab:spawn()
        biteCrab(crab)

        local cast = openCast(player)

        assert(xi.fishing.onAction(player, xi.fishing.mode.CHECK_HOOK, 0, 0) == nil, 'Expected no fight on a crab that is up')
        assert(cast.stage == xi.fishing.stage.EMPTY, 'Expected the empty stage')
        assert(lastFishingMessage(player) == xi.fishingMessage.NO_CATCH, 'Expected the no catch line')
        assert(player:hasItem(xi.item.LITTLE_WORM), 'Expected the worm kept')
    end)

    it('answers the client packets on an empty cast, where every answer crosses the seam as nil', function()
        stub('xi.fishing.rollBite', function()
            return nil
        end)

        sendCastPacket(player)

        local cast = xi.fishing.casts[player:getID()]

        assert(cast ~= nil and cast.stage == xi.fishing.stage.CAST, 'Expected the action packet to open the cast')

        cast.startedAt = cast.startedAt - cast.hookTime - 2
        sendFishingPacket(player, xi.fishing.mode.CHECK_HOOK, 0, 0)

        assert(cast.stage == xi.fishing.stage.EMPTY, 'Expected the hook check to end the cast empty')
        assert(countPackets(player, 0x115) == 0, 'Expected no fight packet')

        sendFishingPacket(player, xi.fishing.mode.RELEASE, 0, 0)

        assert(xi.fishing.casts[player:getID()] == nil, 'Expected the release to close the cast')
    end)

    it('stops a cast the client cancels before the bite and keeps the worm', function()
        sendCastPacket(player)

        local cast = xi.fishing.casts[player:getID()]

        assert(cast ~= nil and cast.stage == xi.fishing.stage.CAST, 'Expected the action packet to open the cast')

        sendFishingPacket(player, xi.fishing.mode.END_MINIGAME, 201, 0)

        assert(cast.stage == xi.fishing.stage.EMPTY, 'Expected the cancel to end the cast empty')
        assert(player:getAnimation() == xi.animation.NEW_FISHING_STOP, 'Expected the stop animation')
        assert(lastFishingMessage(player) == xi.fishingMessage.NO_CATCH, 'Expected the no catch line')

        sendFishingPacket(player, xi.fishing.mode.RELEASE, 0, 0)

        assert(xi.fishing.casts[player:getID()] == nil, 'Expected the release to close the cast')
        assert(player:getAnimation() == xi.animation.NONE, 'Expected the animation cleared')
        assert(player:hasItem(xi.item.LITTLE_WORM), 'Expected the worm kept')
    end)

    it('answers the fishing packets of a character under the fishing minimum level', function()
        xi.test.world:setSetting('map.FISHING_MIN_LEVEL', xi.settings.map.FISHING_MIN_LEVEL + 1)

        sendCastPacket(player)

        local cast = xi.fishing.casts[player:getID()]

        assert(cast ~= nil and cast.stage == xi.fishing.stage.CAST, 'Expected the action packet to open the cast')

        sendFishingPacket(player, xi.fishing.mode.END_MINIGAME, 201, 0)

        assert(cast.stage == xi.fishing.stage.EMPTY, 'Expected the cancel answered under the minimum level')

        sendFishingPacket(player, xi.fishing.mode.RELEASE, 0, 0)

        assert(xi.fishing.casts[player:getID()] == nil, 'Expected the release to close the cast')
        assert(player:getAnimation() == xi.animation.NONE, 'Expected the animation cleared')
    end)

    it('sends the fight packet on a bite and resolves the claim the client packets make', function()
        biteMoatCarp()
        sendCastPacket(player)

        local cast = xi.fishing.casts[player:getID()]

        assert(cast ~= nil, 'Expected the action packet to open the cast')

        cast.startedAt = cast.startedAt - cast.hookTime - 2
        sendFishingPacket(player, xi.fishing.mode.CHECK_HOOK, 0, 0)

        assert(cast.stage == xi.fishing.stage.FIGHTING, 'Expected the hook check to start the fight')
        assert(countPackets(player, 0x115) == 1, 'Expected one fight packet')

        sendFishingPacket(player, xi.fishing.mode.END_MINIGAME, 0, cast.fight.intuition)

        assert(cast.stage == xi.fishing.stage.RESOLVED, 'Expected the end of the minigame to resolve the cast')

        sendFishingPacket(player, xi.fishing.mode.RELEASE, 0, 0)

        assert(xi.fishing.casts[player:getID()] == nil, 'Expected the release to close the cast')
    end)
end)

describe('Transport routes', function()
    it('names the leg each transport is on from its schedule', function()
        -- The Manaclipper heads for Dhalmel Rock from 00:10 to 04:50 and the barge for North Landing from 08:55 to 16:00
        xi.test.world:setVanaTime(2, 0)

        assert(xi.manaclipper.currentRoute() == 'dhalmel_rock', 'Expected the Dhalmel Rock leg, got ' .. tostring(xi.manaclipper.currentRoute()))

        -- The trip back from Purgonorgo Isle fishes the same waters as the trip out
        xi.test.world:setVanaTime(10, 0)

        assert(xi.manaclipper.currentRoute() == 'purgonorgo_isle', 'Expected the Purgonorgo Isle crossing on the way back, got ' .. tostring(xi.manaclipper.currentRoute()))

        xi.test.world:setVanaTime(12, 0)

        assert(xi.barge.currentRoute() == 'north_landing', 'Expected the North Landing leg, got ' .. tostring(xi.barge.currentRoute()))
    end)
end)

describe('Fishing fatigue meters', function()
    local event = xi.fishing.fatigueEvent

    -- Use the retail caps and a job at 20 regardless of the server's settings
    before_each(function()
        xi.test.world:setSetting('map.FISHING_FATIGUE_ENABLE', true)
        xi.test.world:setSetting('map.FISHING_MIN_LEVEL', 20)
        xi.test.world:setSetting('map.FISHING_DAILY_CAP', 200)
        xi.test.world:setSetting('map.FISHING_FATIGUE_CAP', 40000)
    end)

    it('reads the meters from the char vars and writes them back through updateMeters', function()
        local player = xi.test.world:spawnPlayer({ job = xi.job.WAR, level = 20 })
        local update = stub('xi.fishing.updateMeters', true)

        setMeters(player, { daily = 200, fatigue = 0, today = 1 })

        assert(not xi.fishing.mayBite(player), 'Expected the stored points to be read')

        xi.fishing.accrueFatigue(player, { rodId = xi.item.WILLOW_FISHING_ROD }, event.SMALL_FISH, false)

        update:called(1)
    end)

    it('charges the cost table, with the over-level fatigue on an ordinary fish and a release only', function()
        local player   = xi.test.world:spawnPlayer({ job = xi.job.WAR, level = 20 })
        local cast     = { rodId = xi.item.WILLOW_FISHING_ROD }
        local expected =
        {
            [event.SMALL_FISH     ] = { 1, 25 },
            [event.LARGE_FISH     ] = { 1, 50 },
            [event.BASIC_LEGENDARY] = { 1, 140 },
            [event.SUPER_LEGENDARY] = { 1, 780 },
            [event.VALUABLE_ITEM  ] = { 1, 400 },
            [event.COUNTABLE_ITEM ] = { 1, 25 },
            [event.JUNK_ITEM      ] = { 0, 0 },
            [event.EMPTY_CAST     ] = { 0, 0 },
            [event.RELEASE        ] = { 0, 0 },
            [event.LOW_SKILL      ] = { 10, 1000 },
        }

        for ev, pair in pairs(expected) do
            setMeters(player, { daily = 0, fatigue = 0, today = 1 })
            xi.fishing.accrueFatigue(player, cast, ev, false)

            local meters = readMeters(player)
            assert(meters.daily == pair[1] and meters.fatigue == pair[2], 'Wrong cost for event ' .. tostring(ev) .. ': ' .. tostring(meters.daily) .. ' / ' .. tostring(meters.fatigue))
        end

        local overLevel =
        {
            [event.SMALL_FISH     ] = { 1, 100 },
            [event.LARGE_FISH     ] = { 1, 200 },
            [event.RELEASE        ] = { 0, 100 },
            [event.SUPER_LEGENDARY] = { 1, 780 },
            [event.LOW_SKILL      ] = { 10, 1000 },
        }

        for ev, pair in pairs(overLevel) do
            setMeters(player, { daily = 0, fatigue = 0, today = 1 })
            xi.fishing.accrueFatigue(player, cast, ev, true)

            local meters = readMeters(player)
            assert(meters.daily == pair[1] and meters.fatigue == pair[2], 'Wrong over-level cost for event ' .. tostring(ev) .. ': ' .. tostring(meters.daily) .. ' / ' .. tostring(meters.fatigue))
        end
    end)

    it('applies the legendary rod percent to the fatigue side only, and not to a loss to lack of skill', function()
        local player = xi.test.world:spawnPlayer({ job = xi.job.WAR, level = 20 })

        setMeters(player, { daily = 0, fatigue = 0, today = 1 })
        xi.fishing.accrueFatigue(player, { rodId = xi.item.EBISU_FISHING_ROD }, event.SUPER_LEGENDARY, false)

        local meters = readMeters(player)
        assert(meters.daily == 1 and meters.fatigue == 663, 'Expected 780 at 85 percent to be 663, got ' .. tostring(meters.fatigue))

        setMeters(player, { daily = 0, fatigue = 0, today = 1 })
        xi.fishing.accrueFatigue(player, { rodId = xi.item.EBISU_FISHING_ROD }, event.LOW_SKILL, false)

        meters = readMeters(player)
        assert(meters.daily == 10 and meters.fatigue == 1000, 'Expected the loss unscaled, got ' .. tostring(meters.fatigue))
    end)

    it('charges a character with no job at 20 twenty times on both meters, so ten catches or one loss fill the day', function()
        local player = xi.test.world:spawnPlayer({ job = xi.job.WAR, level = 1 })
        local cast   = { rodId = xi.item.WILLOW_FISHING_ROD }

        setMeters(player, { daily = 0, fatigue = 0, today = 1 })
        xi.fishing.accrueFatigue(player, cast, event.SMALL_FISH, false)

        local meters = readMeters(player)
        assert(meters.daily == 20 and meters.fatigue == 500, 'Expected 20 daily points and 500 fatigue, got ' .. tostring(meters.daily) .. ' / ' .. tostring(meters.fatigue))

        for _ = 1, 8 do
            xi.fishing.accrueFatigue(player, cast, event.SMALL_FISH, false)
        end

        assert(xi.fishing.mayBite(player), 'Expected bites after nine catches')

        xi.fishing.accrueFatigue(player, cast, event.SMALL_FISH, false)

        assert(not xi.fishing.mayBite(player), 'Expected no bites after ten catches')

        setMeters(player, { daily = 0, fatigue = 0, today = 1 })
        xi.fishing.accrueFatigue(player, cast, event.LOW_SKILL, false)

        assert(not xi.fishing.mayBite(player), 'Expected one loss to end the day')
    end)

    it('classifies a catch by tier, size, item class and monster', function()
        local classify = xi.fishing.catchFatigueEvent
        local fish     = xi.fishing.catchType.FISH
        local item     = xi.fishing.catchType.ITEM

        assert(classify({ catch = { type = fish, record = { size = xi.fishingSize.SMALL } } }) == event.SMALL_FISH, 'small fish')
        assert(classify({ catch = { type = fish, record = { size = xi.fishingSize.LARGE } } }) == event.LARGE_FISH, 'large fish')
        assert(classify({ catch = { type = fish, record = { size = xi.fishingSize.LARGE, legendary = xi.fishingLegendaryTier.BASIC } } }) == event.BASIC_LEGENDARY, 'basic legendary')
        assert(classify({ catch = { type = fish, record = { size = xi.fishingSize.LARGE, legendary = xi.fishingLegendaryTier.SUPER } } }) == event.SUPER_LEGENDARY, 'super legendary')
        assert(classify({ catch = { type = item, record = { item = true } } }) == event.COUNTABLE_ITEM, 'item with no class yet')
        assert(classify({ catch = { type = item, record = { item = true, fatigue = xi.fishing.fatigueClass.VALUABLE } } }) == event.VALUABLE_ITEM, 'valuable item')
        assert(classify({ catch = { type = item, record = { item = true, fatigue = xi.fishing.fatigueClass.JUNK } } }) == event.JUNK_ITEM, 'junk item')
        assert(classify({ catch = { type = item, itemId = xi.item.CORAL_FRAGMENT, record = { item = true } } }) == event.VALUABLE_ITEM, 'coral fragment by id')
        assert(classify({ catch = { type = item, itemId = xi.item.RUSTY_LEGGINGS, record = { item = true } } }) == event.JUNK_ITEM, 'rusty leggings by id')
        assert(classify({ catch = fishedMonster('Devil_Manta') }) == event.VALUABLE_ITEM, 'the monster the notes price as a valuable by-catch')
        assert(classify({ catch = fishedMonster('Land_Crab') }) == event.EMPTY_CAST, 'any other monster')
    end)

    it('spends one daily point on a sabiki event whatever it lands', function()
        local player = xi.test.world:spawnPlayer({ job = xi.job.WAR, level = 20 })

        setMeters(player, { daily = 0, fatigue = 0, today = 1 })
        xi.fishing.accrueFatigue(player, { rodId = xi.item.WILLOW_FISHING_ROD, catch = { count = 3 } }, event.SMALL_FISH, false)

        local meters = readMeters(player)
        assert(meters.daily == 1 and meters.fatigue == 25, 'Expected one point and 25 fatigue for the event')
    end)

    it('stops the bites at either cap, letting the reel that crosses it land in full', function()
        local player = xi.test.world:spawnPlayer({ job = xi.job.WAR, level = 20 })
        local cast   = { rodId = xi.item.WILLOW_FISHING_ROD }

        setMeters(player, { daily = 199, fatigue = 0, today = 1 })

        assert(xi.fishing.mayBite(player), 'Expected bites at 199 points')

        xi.fishing.accrueFatigue(player, cast, event.LOW_SKILL, false)

        assert(player:getCharVar('[Fish]DailyPoints') == 209, 'Expected the loss to overshoot to 209, got ' .. tostring(player:getCharVar('[Fish]DailyPoints')))
        assert(not xi.fishing.mayBite(player), 'Expected no bites past 200 points')

        setMeters(player, { daily = 0, fatigue = 39999, today = 1 })

        assert(xi.fishing.mayBite(player), 'Expected bites under the fatigue cap')

        xi.fishing.accrueFatigue(player, cast, event.SMALL_FISH, false)

        assert(player:getCharVar('[Fish]Fatigue') == 40024, 'Expected the catch to overshoot the pool, got ' .. tostring(player:getCharVar('[Fish]Fatigue')))
        assert(not xi.fishing.mayBite(player), 'Expected no bites with the pool full')
    end)

    -- The meters expire at midnight on their own, and a full fatigue pool sheds 80 percent a night so it lasts until the second midnight
    it('expires the daily points and the day marker at JST midnight for a character kept online, and sheds 32000 fatigue', function()
        local player = xi.test.world:spawnPlayer({ job = xi.job.WAR, level = 20 })

        xi.fishing.updateMeters(player, { daily = 200, fatigue = 40000, today = 1 })

        assert(player:getCharVar('[Fish]DailyPoints') == 200, 'Expected the points stored while their midnight is still ahead')
        assert(not xi.fishing.mayBite(player), 'Expected no bites with both meters spent')

        -- The daily tick lands on the midnight boundary, so a Vana'diel hour moves the clock past it
        xi.test.world:tick(xi.tick.JST_DAY)
        xi.test.world:tick(xi.tick.VANA_HOUR)

        assert(player:getCharVar('[Fish]DailyPoints') == 0, 'Expected the points to expire at the rollover')
        assert(player:getCharVar('[Fish]Today') == 0, 'Expected the day marker to expire with it')
        assert(player:getCharVar('[Fish]Fatigue') == 40000, 'Expected a full pool to outlive the first midnight')
        assert(xi.fishing.mayBite(player), 'Expected bites once the points have gone and the pool has shed a night')

        xi.fishing.accrueFatigue(player, { rodId = xi.item.WILLOW_FISHING_ROD }, event.SMALL_FISH, false)

        assert(player:getCharVar('[Fish]DailyPoints') == 1, 'Expected a fresh count')
        assert(player:getCharVar('[Fish]Fatigue') == 8025, 'Expected the carried 8000 plus the catch, got ' .. tostring(player:getCharVar('[Fish]Fatigue')))
        assert(player:getCharVar('[Fish]Today') == 1, 'Expected the day marked again')
    end)
end)
