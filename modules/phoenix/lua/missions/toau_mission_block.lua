-----------------------------------
-- Module: ToAU Mission Progression Block
-- Currently blocking progressing past ToAU 18 Passing Glory. To be updated per Phoenix patch release.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('toau_mission_block')

m:addOverride('xi.server.onServerStart', function()
    super()

    xi.module.modifyInteractionEntry('scripts/missions/toau/19_Sweets_for_the_Soul', function(mission)
        local whitegate = mission.sections[1][xi.zone.AHT_URHGAN_WHITEGATE]

        whitegate.onTriggerAreaEnter[5] = nil
        whitegate.onEventFinish[3092]   = nil
    end)
end)
