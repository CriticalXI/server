-----------------------------------
-- Adds the ability for the Kirin teleport to occasionally misfire and send you to the wrong location
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('kirin_teleporter')

m:addOverride('xi.zones.The_Shrine_of_RuAvitau.Zone.onTriggerAreaEnter', function(player, triggerArea)
    local areaId = triggerArea:getTriggerAreaID()

    if areaId == 4 and math.randomInt(1, 100) <= 25 then
        player:startOptionalCutscene(10, { cs_option = 0, canSkip = true })

        return
    end

    super(player, triggerArea)
end)
