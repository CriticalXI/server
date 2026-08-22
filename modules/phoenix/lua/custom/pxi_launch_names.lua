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

-- Stop starter mobs from granting items if killer gets no exp
local starterMobs =
{
    West_Ronfaure     = { 'Wild_Rabbit',     'Tunnel_Worm' },
    East_Ronfaure     = { 'Wild_Rabbit',     'Tunnel_Worm' },
    North_Gustaberg   = { 'Huge_Hornet',     'Tunnel_Worm' },
    South_Gustaberg   = { 'Huge_Hornet',     'Tunnel_Worm' },
    West_Sarutabaruta = { 'Tiny_Mandragora', 'Bumblebee'   },
    East_Sarutabaruta = { 'Tiny_Mandragora', 'Bumblebee'   },
}

for zoneName, mobNames in pairs(starterMobs) do
    for _, mobName in ipairs(mobNames) do
        m:addOverride(string.format('xi.zones.%s.mobs.%s.onMobDeath', zoneName, mobName), function(mob, player, optParams)
            super(mob, player, optParams)

            -- Only run for killer
            if not optParams.isKiller then
                return
            end

            -- No drops if killer does not get xp
            if not player:checkKillCredit(mob) then
                mob:setMobMod(xi.mobMod.NO_DROPS, 1)
            end
        end)
    end
end
