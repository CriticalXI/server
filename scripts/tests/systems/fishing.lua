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
