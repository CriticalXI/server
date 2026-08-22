-----------------------------------
-- Area: Apollyon NW, Floor 4
--  Mob: Cynoprosopi
-----------------------------------
---@type TMobEntity
local entity = {}

local points =
{
    { x = -570.761, y = -0.077, z = 522.718 },
    { x = -557.464, y = -0.010, z = 532.079 },
    { x = -604.171, y =  0.000, z = 527.726 },
    { x = -612.802, y =  0.000, z = 554.650 },
    { x = -578.924, y =  0.000, z = 593.825 },
    { x = -572.767, y = -0.075, z = 529.470 },
    { x = -555.445, y =  0.000, z = 599.520 },
    { x = -585.530, y = -0.015, z = 591.889 },
    { x = -570.498, y = -0.218, z = 551.888 },
    { x = -610.567, y =  0.000, z = 563.445 },
    { x = -600.917, y =  0.000, z = 532.658 },
    { x = -585.872, y = -1.156, z = 546.421 },
    { x = -557.603, y =  0.000, z = 589.217 },
    { x = -557.340, y =  0.000, z = 638.387 },
    { x = -565.772, y =  0.079, z = 610.667 },
    { x = -558.003, y =  0.000, z = 609.510 },
}

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.PETRIFY)
end

entity.onMobSpawn = function(mob)
    mob:setMod(xi.mod.STORETP, 90)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 200)

    mob:setMod(xi.mod.ATTP, 0)
    mob:setMod(xi.mod.DEFP, 0)
    mob:setLocalVar('enrage', 0)
end

entity.onMobFight = function(mob, target)
    local enrage = math.min(math.floor(mob:getBattleTime() / 10), 30)

    if enrage == mob:getLocalVar('enrage') then
        return
    end

    mob:setLocalVar('enrage', enrage)
    mob:setMod(xi.mod.ATTP, math.floor(enrage * 100 / 30))
    mob:setMod(xi.mod.DEFP, math.floor(enrage * 50 / 30))
end

entity.onMobRoam = function(mob)
    if not mob:isFollowingPath() then
        xi.path.randomPath(mob, points, 10, 70)
    end
end

return entity
