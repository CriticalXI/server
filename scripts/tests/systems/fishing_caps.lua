-----------------------------------
-- Fishing daily and fatigue caps
--
-- A whole day of fishing driven cast by cast through the action entry,
-- until one of the two meters closes it. The caps are only read in the
-- bite roll, so a closed day still lets the line go out and simply
-- never hooks: these tests fish on well past the stop to prove it.
--
-- Kept out of the lifecycle file: a few hundred casts a case is far
-- more work than any case in that suite does.
-----------------------------------

-- Both caps are read inside the real bite roll, and the harness leaves that entry point pointing at a freed test double once
-- enough cases have stubbed and restored it, which is why the whole suite in one run can crash the runner. The real one is
-- taken while this file loads and put back before each case, so a day here is always driven by the real gate.
local realRollBite = xi.fishing.rollBite

-- A catalog with the Willow rod and the Ebisu beside it, the little worm, and a whole-zone area in West Ronfaure holding
-- only the moat carp. Built fresh per test so a test can reshape it.
local function capCatalog()
    return
    {
        fish =
        {
            [xi.item.MOAT_CARP_1] = { name = 'moat_carp', size = xi.fishingSize.SMALL, skill = 11 },
        },
        rods =
        {
            [xi.item.WILLOW_FISHING_ROD] = { name = 'willow_fishing_rod', size = xi.fishingSize.SMALL, time = 30 },
            [xi.item.EBISU_FISHING_ROD ] = { name = 'ebisu_fishing_rod', size = xi.fishingSize.SMALL, time = 30, legendary = true, legendaryTime = 10 },
        },
        baits =
        {
            [xi.item.LITTLE_WORM] = { name = 'little_worm', type = xi.fishingBaitType.BAIT, affinity = { [xi.item.MOAT_CARP_1] = true } },
        },
        zones =
        {
            [xi.zone.WEST_RONFAURE] =
            {
                areas    = { whole_zone = { pool = { xi.item.MOAT_CARP_1 } } },
                monsters = {},
            },
        },
    }
end

describe('Fishing daily and fatigue caps', function()
    ---@type CClientEntityPair
    local player
    local originalData

    -- Every bite is the catch given. The cap gate is left where it is, in the bite roll above the buckets, so a closed day
    -- still opens a cast and simply never hooks.
    local function alwaysHook(itemId)
        stub('xi.fishing.biteBuckets', function()
            return
            {
                weights = { [xi.fishing.catchType.FISH] = 1000 },
                entries = {},
                fishId  = itemId,
            }
        end)
    end

    -- One whole cast through the action entry: the line out, the hook check, the claim the client reports and the release.
    -- Answers with the result the cast ended on, or nil when nothing bit. The bait and the inventory are topped back up so a
    -- long day is never cut short by either.
    local function fishOnce(itemId, reported)
        if player:getEquippedItem(xi.slot.AMMO) == nil then
            player:addItem({ id = xi.item.LITTLE_WORM, quantity = 99, silent = true })
            player:equipItem(xi.item.LITTLE_WORM, nil, xi.slot.AMMO)
        end

        if player:hasItem(itemId) then
            player:delItem(itemId, 1)
        end

        assert(xi.fishing.onStart(player) ~= nil, 'Expected the cast to open')

        local cast = xi.fishing.casts[player:getID()]

        -- Move the start back past the hook timer and the claim floor, so the hook check and the claim that follow are on time
        cast.startedAt = cast.startedAt - cast.hookTime - 2

        local fight = xi.fishing.onAction(player, xi.fishing.mode.CHECK_HOOK, 0, 0)

        if fight then
            xi.fishing.onAction(player, xi.fishing.mode.END_MINIGAME, reported, fight.intuition)
        end

        xi.fishing.onAction(player, xi.fishing.mode.RELEASE, 0, 0)
        player.packets:clear()

        return cast.result
    end

    before_each(function()
        originalData    = xi.fishing.data
        xi.fishing.data = capCatalog()

        xi.test.world:setSetting('map.FISHING_ENABLE', true)
        xi.test.world:setSetting('map.FISHING_FATIGUE_ENABLE', true)
        xi.test.world:setSetting('map.FISHING_DAILY_CAP', 200)
        xi.test.world:setSetting('map.FISHING_FATIGUE_CAP', 20000)

        -- A job at the fishing minimum level keeps the full allowance: a character without one pays twenty times over
        player = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE, level = xi.settings.map.FISHING_MIN_LEVEL })

        player:addItem(xi.item.WILLOW_FISHING_ROD)
        player:addItem(xi.item.LITTLE_WORM)
        player:equipItem(xi.item.WILLOW_FISHING_ROD, nil, xi.slot.RANGED)
        player:equipItem(xi.item.LITTLE_WORM, nil, xi.slot.AMMO)
        player:setSkillLevel(xi.skill.FISHING, 980)

        -- A spawned angler can take a charid an earlier test left meters on, so the day starts explicitly empty
        player:setCharVar('[Fish]DailyPoints', 0)
        player:setCharVar('[Fish]Fatigue', 0)
        player:setCharVar('[Fish]Today', 1)

        xi.fishing.rollBite = realRollBite

        assert(type(xi.fishing.rollBite) == 'function', 'Expected the real bite roll, found a ' .. type(xi.fishing.rollBite))

        -- The day is about the meters, so no skill-up moves the gap under the test
        stub('xi.fishing.rollSkillUp', true)
    end)

    after_each(function()
        -- A spawned angler can take an id a previous test left a cast under, so the open casts go with the catalog
        xi.fishing.casts[player:getID()] = nil
        xi.fishing.data                  = originalData
    end)

    it('lands 200 carp, closes the day on the daily cap and leaves every cast after it empty', function()
        alwaysHook(xi.item.MOAT_CARP_1)

        local landed = 0
        for _ = 1, 200 do
            if fishOnce(xi.item.MOAT_CARP_1, 0) == xi.fishing.result.CAUGHT then
                landed = landed + 1
            end
        end

        assert(landed == 200, 'Expected all 200 carp while the day had room, landed ' .. tostring(landed))
        assert(player:getCharVar('[Fish]DailyPoints') == 200, 'Expected a point a carp, got ' .. tostring(player:getCharVar('[Fish]DailyPoints')))
        assert(player:getCharVar('[Fish]Fatigue') == 5000, 'Expected 25 fatigue a carp and room to spare in the pool, got ' .. tostring(player:getCharVar('[Fish]Fatigue')))
        assert(not xi.fishing.mayBite(player), 'Expected the day closed at the cap')

        -- The line still goes out; nothing takes it for the rest of the day
        for _ = 1, 40 do
            assert(fishOnce(xi.item.MOAT_CARP_1, 0) == nil, 'Expected nothing to bite past the daily cap')
        end

        assert(player:getCharVar('[Fish]DailyPoints') == 200, 'Expected the count to stand still once the day is closed')
        assert(player:getCharVar('[Fish]Fatigue') == 5000, 'Expected the pool to stand still with it')
    end)

    it('fills the pool on twenty losses to lack of skill without spending a daily point, and stops there', function()
        alwaysHook(xi.item.MOAT_CARP_1)

        -- The client reports the stamina it gave up on, and 5 to 20 is the band retail answered with the lack-of-skill line
        local lost = 0
        for _ = 1, 20 do
            if fishOnce(xi.item.MOAT_CARP_1, 10) == xi.fishing.result.LOW_SKILL then
                lost = lost + 1
            end
        end

        assert(lost == 20, 'Expected all 20 hooks lost to lack of skill, lost ' .. tostring(lost))
        assert(player:getCharVar('[Fish]Fatigue') == 20000, 'Expected 1000 a loss, got ' .. tostring(player:getCharVar('[Fish]Fatigue')))
        assert(player:getCharVar('[Fish]DailyPoints') == 0, 'Expected a loss to cost the pool alone, got ' .. tostring(player:getCharVar('[Fish]DailyPoints')))
        assert(not xi.fishing.mayBite(player), 'Expected the pool to close the day with the count still at zero')

        for _ = 1, 40 do
            assert(fishOnce(xi.item.MOAT_CARP_1, 10) == nil, 'Expected nothing to bite past the fatigue cap')
        end

        assert(player:getCharVar('[Fish]Fatigue') == 20000, 'Expected the pool to stand still once it is full')
    end)

    it('closes an over-level day on the pool long before the daily count reaches its cap', function()
        -- An istavrit 17 over a skill of 1 is over level, and the Ebisu holds it: no rod strength to strain and no size penalty
        xi.fishing.data.fish[xi.item.ISTAVRIT_1] = { name = 'istavrit', size = xi.fishingSize.LARGE, skill = 18 }

        player:setSkillLevel(xi.skill.FISHING, 10)
        player:addItem({ id = xi.item.EBISU_FISHING_ROD, silent = true })
        player:equipItem(xi.item.EBISU_FISHING_ROD, nil, xi.slot.RANGED)

        assert(player:getEquippedItem(xi.slot.RANGED):getID() == xi.item.EBISU_FISHING_ROD, 'Expected the Ebisu on the angler')

        alwaysHook(xi.item.ISTAVRIT_1)

        -- 200 fatigue a large fish over level, at the Ebisu's 85 percent, is 170: the 118th fills a pool of 20000
        local landed = 0
        for _ = 1, 160 do
            if fishOnce(xi.item.ISTAVRIT_1, 0) == xi.fishing.result.CAUGHT then
                landed = landed + 1
            end
        end

        assert(landed == 118, 'Expected the pool to stop the day on the 118th istavrit, landed ' .. tostring(landed))
        assert(player:getCharVar('[Fish]Fatigue') == 20060, 'Expected the reel that crosses the cap to land in full, got ' .. tostring(player:getCharVar('[Fish]Fatigue')))
        assert(player:getCharVar('[Fish]DailyPoints') == 118, 'Expected the count still well under its own cap, got ' .. tostring(player:getCharVar('[Fish]DailyPoints')))
        assert(not xi.fishing.mayBite(player), 'Expected the pool to close the day')
    end)

    it('spends nothing at all on a day of empty casts and give-ups', function()
        -- Nothing is in the water, so every cast comes back empty
        xi.fishing.data.zones[xi.zone.WEST_RONFAURE].areas.whole_zone.pool = {}

        for _ = 1, 120 do
            assert(fishOnce(xi.item.MOAT_CARP_1, 0) == nil, 'Expected an empty cast with nothing in the water')
        end

        assert(player:getCharVar('[Fish]DailyPoints') == 0, 'Expected an empty cast to cost nothing, got ' .. tostring(player:getCharVar('[Fish]DailyPoints')))
        assert(player:getCharVar('[Fish]Fatigue') == 0, 'Expected an empty cast to cost no fatigue, got ' .. tostring(player:getCharVar('[Fish]Fatigue')))

        -- A give-up on a hooked carp in range costs nothing either, so a day of them never closes
        alwaysHook(xi.item.MOAT_CARP_1)

        for _ = 1, 120 do
            assert(fishOnce(xi.item.MOAT_CARP_1, 200) == xi.fishing.result.GAVE_UP, 'Expected the give-up the corpus saw at 200')
        end

        assert(player:getCharVar('[Fish]DailyPoints') == 0, 'Expected a give-up in range to cost nothing, got ' .. tostring(player:getCharVar('[Fish]DailyPoints')))
        assert(player:getCharVar('[Fish]Fatigue') == 0, 'Expected a give-up in range to cost no fatigue, got ' .. tostring(player:getCharVar('[Fish]Fatigue')))
        assert(xi.fishing.mayBite(player), 'Expected the day still open after 240 casts that cost nothing')
    end)
end)
