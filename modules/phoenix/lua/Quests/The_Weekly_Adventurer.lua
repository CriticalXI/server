-----------------------------------
-- Module to remove exp and gil from 'The Weekly Adventurer' quest reward.
-- Gil and exp were added to the quest reward in 2013 so they are removed here.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('era_quest_the_weekly_adventurer', xi.pre(xi.expansion.SOA))

m:addOverride('xi.server.onServerStart', function()
    super()

    xi.module.modifyInteractionEntry('scripts/quests/crystalWar/The_Weekly_Adventurer', function(quest)
        quest.reward = {
            keyItem = xi.keyItem.MAP_OF_FORT_KARUGO_NARUGO,
        }
    end)
end)
