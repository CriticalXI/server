-----------------------------------
-- Module to remove exp and gil from 'The Flipside of Things' quest reward.
-- Gil and exp were added to the quest reward in 2013 so they are removed here.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('era_quest_the_flipside_of_things', xi.pre(xi.expansion.SOA))

m:addOverride('xi.server.onServerStart', function()
    super()

    xi.module.modifyInteractionEntry('scripts/quests/crystalWar/The_Flipside_of_Things', function(quest)
        quest.reward = {
            keyItem = xi.keyItem.MAP_OF_VUNKERL_INLET,
        }
    end)
end)
