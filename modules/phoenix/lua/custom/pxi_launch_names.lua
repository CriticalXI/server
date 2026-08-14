-----------------------------------
-- Names the launch month mobs in the starter zones otherwise they would be "NPC" in the client.
-- Their IDs sit past the client DAT name table.
-- renameEntity sends the name in the entity update packet instead.
-- Remove together with pxi_launch_starter_zones.sql
-- phoenix/lua/custom/pxi_launch_names.lua
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('pxi_launch_names')

-- The first 75 ids are group 200, the next 75 are group 201.
local eventMobNames =
{
    West_Ronfaure     = { 'Wild Rabbit',     'Tunnel Worm' },
    East_Ronfaure     = { 'Wild Rabbit',     'Tunnel Worm' },
    North_Gustaberg   = { 'Huge Hornet',     'Tunnel Worm' },
    South_Gustaberg   = { 'Huge Hornet',     'Tunnel Worm' },
    West_Sarutabaruta = { 'Tiny Mandragora', 'Bumblebee'   },
    East_Sarutabaruta = { 'Tiny Mandragora', 'Bumblebee'   },
}

for zoneName, names in pairs(eventMobNames) do
    m:addOverride(string.format('xi.zones.%s.Zone.onInitialize', zoneName), function(zone)
        super(zone)

        -- The event mobs occupy offsets 874-1023.
        local firstId = 0x1000000 + zone:getID() * 0x1000 + 874
        for i = 0, 149 do
            local mob = GetMobByID(firstId + i)
            if mob then
                mob:renameEntity(i < 75 and names[1] or names[2], true)
            end
        end
    end)
end
