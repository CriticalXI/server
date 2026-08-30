-----------------------------------
-- Module: Mercenary Promotion Block
-- Currently blocking promotion past Lance Corporal. To be updated per Phoenix patch release.
-- No Promotion: Captain block yet because the quest is not yet implemented, so it cannot be called.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('promotion_quest_block')

-- Every quest in the chain, so a GM-flagged one goes nowhere either.
local blockedQuests =
{
    'scripts/quests/ahtUrhgan/Promotion_Corporal',
    'scripts/quests/ahtUrhgan/Promotion_Sergeant',
    'scripts/quests/ahtUrhgan/Promotion_Sergeant_Major',
    'scripts/quests/ahtUrhgan/Promotion_Chief_Sergeant',
    'scripts/quests/ahtUrhgan/Promotion_Second_Lieutenant',
    'scripts/quests/ahtUrhgan/Promotion_First_Lieutenant',
}

m:addOverride('xi.server.onServerStart', function()
    super()

    for _, questPath in ipairs(blockedQuests) do
        xi.module.modifyInteractionEntry(questPath, function(quest)
            -- Every section, not just the offer. First Lieutenant is offered by a trigger area with no NPC key.
            for _, section in ipairs(quest.sections) do
                section.check = function()
                    return false
                end
            end
        end)
    end
end)
