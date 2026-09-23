-----------------------------------
-- Fishing contest
--
-- The fish ranking contest's own tables and the two entry points the
-- C++ stage machine calls into: the fish a contest picks and the time
-- each stage runs for. The trade, trigger and event handlers need an
-- NPC and a live contest behind them and are not covered here.
-----------------------------------

describe('Fishing contest', function()
    local status = xi.fishingContest.status

    it('runs each stage for its own interval and never moves a contest that is closed', function()
        local stages =
        {
            status.CONTESTING,
            status.OPENING,
            status.ACCEPTING,
            status.RELEASING,
            status.PRESENTING,
            status.HIATUS,
        }

        for _, stage in ipairs(stages) do
            local interval = xi.fishingContest.interval[stage]

            assert(interval ~= nil and interval > 0, 'Stage ' .. tostring(stage) .. ' has no interval')
            assert(xi.fishingContest.getStageChangeTime(stage, 1000) == 1000 + interval, 'Stage ' .. tostring(stage) .. ' does not change at its own interval')
        end

        -- A closed contest, and anything outside the stage list, waits forever
        local never = xi.fishingContest.interval[status.CLOSED]

        assert(xi.fishingContest.getStageChangeTime(status.CLOSED, 1000) == never, 'A closed contest was given a change time')
        assert(xi.fishingContest.getStageChangeTime(status.CLOSED + 1, 1000) == never, 'A stage past the list was given a change time')
        assert(xi.fishingContest.getStageChangeTime(status.CONTESTING - 1, 1000) == never, 'A stage under the list was given a change time')
    end)

    it('spends 28 days and 35 minutes on one whole cycle, as the captures timed it', function()
        local cycle = 0
        for stage = status.CONTESTING, status.HIATUS do
            cycle = cycle + xi.fishingContest.interval[stage]
        end

        assert(cycle == 28 * 86400 + 35 * 60, 'The cycle runs ' .. tostring(cycle) .. ' seconds, expected 28 days and 35 minutes')
    end)

    it('picks a contest fish the fishing catalog can actually land, every time', function()
        local catalog = xi.fishing.getData().fish
        local ids     = {}

        for _, entry in ipairs(xi.fishingContest.fish) do
            assert(entry.id and entry.name and entry.realName, 'A contest fish row is missing its id or one of its names')
            assert(not ids[entry.id], 'The contest lists ' .. tostring(entry.realName) .. ' twice')
            assert(catalog[entry.id] ~= nil, 'The contest lists ' .. tostring(entry.realName) .. ', which the fishing catalog does not carry')

            ids[entry.id] = true
        end

        -- The C++ core calls this for every new contest, so it has to answer with a listed fish whatever it rolls
        for _ = 1, 200 do
            assert(ids[xi.fishingContest.selectContestFish()], 'A contest was given a fish that is not on its own list')
        end
    end)

    it('measures a contest fish, so every one of them can be scored and ranked', function()
        local catalog = xi.fishing.getData().fish

        for _, entry in ipairs(xi.fishingContest.fish) do
            local length = catalog[entry.id].length

            assert(length ~= nil and length[1] > 0 and length[2] > length[1], 'The contest lists ' .. tostring(entry.realName) .. ', which carries no length range to score')
        end
    end)

    it('rewards all twenty ranks, with the gil and the title on the first ten alone', function()
        for rank = 1, 20 do
            local reward = xi.fishingContest.reward[rank]

            assert(reward ~= nil, 'Rank ' .. tostring(rank) .. ' has no reward')
            assert(reward.item == xi.item.PELICAN_RING, 'Rank ' .. tostring(rank) .. ' does not carry the Pelican Ring')

            if rank <= 10 then
                assert(reward.gil and reward.gil > 0, 'Rank ' .. tostring(rank) .. ' carries no gil')
                assert(reward.title ~= nil, 'Rank ' .. tostring(rank) .. ' carries no title')
            else
                assert(reward.gil == nil, 'Rank ' .. tostring(rank) .. ' carries gil past the tenth place')
                assert(reward.title == nil, 'Rank ' .. tostring(rank) .. ' carries a title past the tenth place')
            end
        end

        assert(xi.fishingContest.reward[21] == nil, 'The table rewards a rank past the twentieth')

        -- The gil falls with the rank and the top three take their own titles
        for rank = 2, 10 do
            assert(xi.fishingContest.reward[rank].gil <= xi.fishingContest.reward[rank - 1].gil, 'Rank ' .. tostring(rank) .. ' pays more than the rank above it')
        end

        assert(xi.fishingContest.reward[1].title == xi.title.GOLD_HOOK, 'First place is not the gold hook')
        assert(xi.fishingContest.reward[2].title == xi.title.MYTHRIL_HOOK, 'Second place is not the mythril hook')
        assert(xi.fishingContest.reward[3].title == xi.title.SILVER_HOOK, 'Third place is not the silver hook')
    end)
end)
