-----------------------------------
-- Module: Anniversary Ring for New Characters
-- Hands out an Anniversary Ring with the Adventurer's Coupon at the end of the opening cutscene.
-- Changing nations replays that cutscene, so only a character's first viewing grants the ring.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('anniversary_ring')

local introEvents =
{
    [xi.zone.BASTOK_MARKETS]     = 7,
    [xi.zone.BASTOK_MINES]       = 1,
    [xi.zone.PORT_BASTOK]        = 1,
    [xi.zone.NORTHERN_SAN_DORIA] = 535,
    [xi.zone.SOUTHERN_SAN_DORIA] = 503,
    [xi.zone.PORT_SAN_DORIA]     = 500,
    [xi.zone.WINDURST_WATERS]    = 531,
    [xi.zone.WINDURST_WOODS]     = 367,
    [xi.zone.PORT_WINDURST]      = 305,
}

m:addOverride('xi.server.onServerStart', function()
    super()

    xi.module.modifyInteractionEntry('scripts/quests/hiddenQuests/New_Character_Cutscenes', function(quest)
        for zoneId, eventId in pairs(introEvents) do
            local zoneSection = quest.sections[1][zoneId]
            local baseHandler = zoneSection and zoneSection.onEventFinish[eventId]

            -- A missing handler would leave the whole cutscene unregistered, taking the coupon with it.
            if baseHandler then
                zoneSection.onEventFinish[eventId] = function(player, csid, option, npc)
                    -- The base handler marks the nation, so the first viewing is read ahead of it.
                    local firstViewing = quest:getVar(player, 'nations') == 0
                    local result       = baseHandler(player, csid, option, npc)

                    if firstViewing then
                        npcUtil.giveItem(player, xi.item.ANNIVERSARY_RING)
                    end

                    return result
                end
            end
        end
    end)
end)
