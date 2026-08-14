-----------------------------------
-- Re-applies known-correct message text IDs for the Temenos and Apollyon Limbus zones
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('limbus_text_ids')

m:addOverride('xi.server.onServerStart', function()
    super()

    local temenos = zones[xi.zone.TEMENOS]
    if temenos then
        temenos.text.ITEM_OBTAINED                 = 6390
        temenos.text.GIL_OBTAINED                  = 6391
        temenos.text.KEYITEM_OBTAINED              = 6393
        temenos.text.MEMBERS_LEVELS_ARE_RESTRICTED = 7023
        temenos.text.CHIP_TRADE_T                  = 7030
        temenos.text.CONQUEST_BASE                 = 7386
    end

    local apollyon = zones[xi.zone.APOLLYON]
    if apollyon then
        apollyon.text.ITEM_OBTAINED                 = 6390
        apollyon.text.GIL_OBTAINED                  = 6391
        apollyon.text.KEYITEM_OBTAINED              = 6393
        apollyon.text.MEMBERS_LEVELS_ARE_RESTRICTED = 7023
        apollyon.text.CONQUEST_BASE                 = 7377
    end
end)
