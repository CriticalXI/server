-----------------------------------
-- Phoenix Pet EXP Penalty Module
--
-- Parties of 3 or less will not be affected by this module.
-- When 4 players are in the party, pets will only give 30% of their normal EXP (70% penalty).
-- When 5 players are in the party, pets will only give 20% of their normal EXP (80% penalty).
-- When 6 or more players are in the party/alliance, pets will only give 10% of their normal EXP (90% penalty).
-----------------------------------
require('modules/module_utils')

local m = Module:new('pet_exp_penalty')

-- Percent of exp removed per party size. Sizes past the table use the last entry.
local penaltyBySize =
{
    [4] = 70,
    [5] = 80,
    [6] = 90,
}

m:addOverride('xi.experiencePoints.calculate', function(member, mob, data)
    local result = super(member, mob, data)

    if not result or data.partySize < 4 then
        return result
    end

    -- Only pets owned by another monster. Charmed pets and player jug pets have
    -- a player master and keep full value.
    local master = mob:getMaster()
    if not master or not master:isMob() then
        return result
    end

    local penalty = penaltyBySize[math.min(data.partySize, 6)]
    result.exp = math.floor(result.exp * (100 - penalty) / 100)

    return result
end)
