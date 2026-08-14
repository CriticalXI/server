-----------------------------------
-- This module moves some NMs back to their original spawn positions and should be used in tandem with pxi_mob_spawn_points.sql
-- Most of these NMs were moved in the May 10, 2011 version update: https://forum.square-enix.com/ffxi/threads/7267
-- Khimaira was moved in the October 10, 2023 version update: https://forum.square-enix.com/ffxi/threads/61169
-- The sql module only covers boot and manual spawns, so this LUA module is needed to cover all bases
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('pxi_nm_spawn_points')

-----------------------------------
-- Sewer Syrup (Bostaunieux Oubliette)
-- Note: PHs already moved in pxi_mob_spawn_points.sql
-----------------------------------
local sewerSyrupSpawnPoints =
{
    { x = -24.1381, y = 0.9958, z = -340.2455 },
    { x = -25.3790, y = 1.0102, z = -336.3386 },
    { x = -26.2503, y = 1.0507, z = -339.8841 },
    { x = -26.3895, y = 1.0378, z = -347.2119 },
    { x = -19.1545, y = 1.0294, z = -344.6323 },
    { x = -17.8896, y = 0.9920, z = -336.5280 },
    { x = -22.5039, y = 1.0000, z = -340.0507 },
}

m:addOverride('xi.zones.Bostaunieux_Oubliette.mobs.Sewer_Syrup.onMobInitialize', function(mob)
    xi.zones.Bostaunieux_Oubliette.mobs.Sewer_Syrup.spawnPoints = sewerSyrupSpawnPoints
    super(mob)
end)

m:addOverride('xi.zones.Bostaunieux_Oubliette.mobs.Mousse.onMobDespawn', function(mob)
    xi.mob.phOnDespawn(mob, zones[xi.zone.BOSTAUNIEUX_OUBLIETTE].mob.SEWER_SYRUP, 10, 7200, { spawnPoints = sewerSyrupSpawnPoints }) -- 2 hour minimum
end)

-----------------------------------
-- Shii (Bostaunieux Oubliette)
-- Note: PHs already moved in pxi_mob_spawn_points.sql
-----------------------------------
local shiiSpawnPoints =
{
    { x = 26.5113, y = 0.0000, z = -145.5199 },
    { x = 22.5743, y = 0.0000, z = -145.9723 },
    { x = 14.6538, y = 0.0632, z = -146.1381 },
    { x = 12.2583, y = 0.0000, z = -139.0831 },
    { x = 13.9657, y = 0.0000, z = -133.2969 },
    { x = 21.5238, y = 0.0000, z = -132.2219 },
    { x = 27.8577, y = 0.0000, z = -134.5756 },
}

m:addOverride('xi.zones.Bostaunieux_Oubliette.mobs.Shii.onMobInitialize', function(mob)
    xi.zones.Bostaunieux_Oubliette.mobs.Shii.spawnPoints = shiiSpawnPoints
    super(mob)
end)

m:addOverride('xi.zones.Bostaunieux_Oubliette.mobs.Garm.onMobDespawn', function(mob)
    xi.mob.phOnDespawn(mob, zones[xi.zone.BOSTAUNIEUX_OUBLIETTE].mob.SHII, 5, 3600, { spawnPoints = shiiSpawnPoints }) -- 1 hour
end)

-----------------------------------
-- Khimaira (Caedarva Mire)
-- NOTE: His draw in fence is also updated in this module.
-----------------------------------
local khimairaSpawnPoints =
{
    { x = 840.1741, y =  0.2318, z = 354.0881 },
    { x = 833.1459, y = -0.3641, z = 358.4796 },
    { x = 847.2755, y = -0.4074, z = 355.4048 },
    { x = 847.4933, y = -0.5209, z = 364.5592 },
    { x = 841.9098, y = -0.1811, z = 365.3915 },
}

m:addOverride('xi.zones.Caedarva_Mire.mobs.Khimaira.onMobInitialize', function(mob)
    xi.zones.Caedarva_Mire.mobs.Khimaira.spawnPoints = khimairaSpawnPoints
    super(mob)
end)

m:addOverride('xi.zones.Caedarva_Mire.mobs.Khimaira.onMobDespawn', function(mob)
    xi.zones.Caedarva_Mire.mobs.Khimaira.spawnPoints = khimairaSpawnPoints
    super(mob)
end)

m:addOverride('xi.zones.Caedarva_Mire.mobs.Khimaira.onMobFight', function(mob, target)
    local targetPos = target:getPos()
    local drawInPositions =
    {
        { 840.1741,  0.2318, 354.0881, targetPos.rot },
        { 833.1459, -0.3641, 358.4796, targetPos.rot },
        { 847.2755, -0.4074, 355.4048, targetPos.rot },
        { 847.4933, -0.5209, 364.5592, targetPos.rot },
        { 841.9098, -0.1811, 365.3915, targetPos.rot },
    }
    -- This draws a fence around z 384-393. If you cross the line, you get drawn in. This corresponds with the bowl he spawns in.
    local drawInTable =
    {
        conditions =
        {
            target:getZPos() > 384,
        },
        position = utils.randomEntry(drawInPositions),
        wait = 3,
    }
    for _, condition in ipairs(drawInTable.conditions) do
        if condition then
            mob:setMobMod(xi.mobMod.NO_MOVE, 1)
            utils.drawIn(target, drawInTable)
            break
        else
            mob:setMobMod(xi.mobMod.NO_MOVE, 0)
        end
    end
end)

-----------------------------------
-- Ancient Goobbue (The Boyahda Tree)
-- Note: He is a timed spawn.
-----------------------------------
local ancientGoobbueSpawnPoints =
{
    { x = -230.0585, y = 9.8375, z = -271.3131 },
    { x = -240.5190, y = 9.9033, z = -269.3860 },
    { x = -251.1645, y = 9.8264, z = -273.0870 },
    { x = -249.1251, y = 9.8717, z = -284.5343 },
    { x = -241.4092, y = 9.8794, z = -290.8444 },
    { x = -232.4506, y = 9.8694, z = -285.8061 },
    { x = -222.0314, y = 8.7140, z = -280.2849 },
}

m:addOverride('xi.zones.The_Boyahda_Tree.mobs.Ancient_Goobbue.onMobInitialize', function(mob)
    xi.zones.The_Boyahda_Tree.mobs.Ancient_Goobbue.spawnPoints = ancientGoobbueSpawnPoints
    super(mob)
end)

m:addOverride('xi.zones.The_Boyahda_Tree.mobs.Ancient_Goobbue.onMobDespawn', function(mob)
    xi.zones.The_Boyahda_Tree.mobs.Ancient_Goobbue.spawnPoints = ancientGoobbueSpawnPoints
    super(mob)
end)

-----------------------------------
-- Pelican (Kuftal Tunnel)
-- Note: Greater Cockatrice (PH) hands Pelican his spawn list, so the whole call is redone.
-----------------------------------
local pelicanSpawnPoints =
{
    { x = 39.3958, y = 30.0000, z = -200.9464 },
    { x = 47.8120, y = 30.0000, z = -195.4370 },
    { x = 31.2640, y = 30.0000, z = -207.9180 },
    { x = 45.5730, y = 30.0000, z = -209.6850 },
    { x = 32.9410, y = 30.0000, z = -193.5220 },
}

m:addOverride('xi.zones.Kuftal_Tunnel.mobs.Greater_Cockatrice.onMobDespawn', function(mob)
    xi.mob.phOnDespawn(mob, zones[xi.zone.KUFTAL_TUNNEL].mob.PELICAN, 10, 14400, { spawnPoints = pelicanSpawnPoints }) -- 4 hours
end)

-----------------------------------
-- Baobhan Sith (Gustav Tunnel)
-- Note: Erlik (PH) hands Baobhan Sith his spawn list, so the whole call is redone.
-----------------------------------
local baobhanSithSpawnPoints =
{
    { x = 121.9407, y =  1.0000, z = 173.2505 },
    { x = 110.3229, y =  0.3521, z = 169.1011 },
    { x = 116.1587, y =  0.2441, z = 185.6421 },
    { x = 132.3923, y = -1.6022, z = 177.9078 },
    { x = 121.1585, y =  0.4480, z = 190.0931 },
    { x = 111.1113, y =  0.0000, z = 187.9258 },
    { x = 102.0386, y = -0.1752, z = 181.2676 },
    { x =  99.0245, y =  0.3059, z = 194.0290 },
    { x =  92.5937, y =  0.8131, z = 198.5043 },
}

m:addOverride('xi.zones.Gustav_Tunnel.mobs.Erlik.onMobDespawn', function(mob)
    xi.mob.phOnDespawn(mob, zones[xi.zone.GUSTAV_TUNNEL].mob.BAOBHAN_SITH, 5, 14400, { spawnPoints = baobhanSithSpawnPoints }) -- 4 hours
end)

-----------------------------------
-- Serket (Garlaige Citadel)
-- Note: Prior to being moved, Serket had a huge spawn radius. Serket's draw in is based on itself and doesn't need to be updated.
-----------------------------------
local serketSpawnPoints =
{
    { x = -262.0567, y = 19.7364, z = 281.5403 },
    { x = -176.6411, y = 19.5731, z = 319.9763 },
    { x = -369.3212, y = 19.0597, z = 250.5473 },
    { x = -303.9854, y = 19.7148, z = 258.7263 },
    { x = -216.7376, y = 19.1926, z = 272.7190 },
    { x = -352.0170, y = 19.1387, z = 289.9632 },
    { x = -363.6601, y = 19.0000, z = 278.4101 },
    { x = -366.2028, y = 19.3497, z = 259.5342 },
    { x = -361.0228, y = 19.2500, z = 244.9236 },
    { x = -356.5399, y = 19.1240, z = 232.1587 },
    { x = -341.8288, y = 19.5213, z = 235.4723 },
    { x = -325.3873, y = 19.1934, z = 236.7135 },
    { x = -315.3685, y = 19.3326, z = 249.8351 },
    { x = -301.5880, y = 19.8030, z = 260.8293 },
    { x = -287.8314, y = 19.6485, z = 262.4905 },
    { x = -296.8612, y = 19.5471, z = 236.3212 },
    { x = -274.3760, y = 19.2178, z = 237.2773 },
    { x = -251.9883, y = 19.4882, z = 237.7501 },
    { x = -238.1273, y = 19.2085, z = 243.7206 },
    { x = -235.6724, y = 19.5540, z = 260.8499 },
    { x = -240.2007, y = 19.1300, z = 276.9028 },
    { x = -225.2411, y = 19.4889, z = 282.3336 },
    { x = -208.3721, y = 19.2943, z = 276.4395 },
    { x = -196.7664, y = 19.1856, z = 283.7114 },
    { x = -195.9038, y = 19.5386, z = 297.6283 },
    { x = -186.5911, y = 19.6677, z = 311.1746 },
    { x = -169.3569, y = 19.3122, z = 316.2286 },
    { x = -156.2027, y = 18.9878, z = 322.1319 },
    { x = -167.3434, y = 19.1697, z = 329.2849 },
    { x = -182.7207, y = 19.4418, z = 324.9876 },
    { x = -200.5676, y = 19.0000, z = 322.2583 },
    { x = -213.4526, y = 18.2991, z = 301.8708 },
    { x = -232.2847, y = 18.8526, z = 293.9346 },
    { x = -250.2108, y = 19.0059, z = 289.8921 },
    { x = -263.0582, y = 19.6105, z = 278.2142 },
    { x = -275.1308, y = 19.1560, z = 284.6945 },
    { x = -292.7928, y = 19.4143, z = 284.3071 },
    { x = -315.4903, y = 19.1263, z = 284.1316 },
    { x = -334.5092, y = 19.5062, z = 282.6543 },
    { x = -356.5667, y = 19.1721, z = 282.5102 },
}

m:addOverride('xi.zones.Garlaige_Citadel.mobs.Serket.onMobInitialize', function(mob)
    xi.zones.Garlaige_Citadel.mobs.Serket.spawnPoints = serketSpawnPoints
    super(mob)
end)

m:addOverride('xi.zones.Garlaige_Citadel.mobs.Serket.onMobDespawn', function(mob)
    xi.zones.Garlaige_Citadel.mobs.Serket.spawnPoints = serketSpawnPoints
    super(mob)
end)
