-----------------------------------
-- Area: Apollyon NW, Floor 1
--  Mob: Pluto
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.PETRIFY)
end

entity.onMobSpawn = function(mob)
    mob:setMod(xi.mod.DOUBLE_ATTACK, 0)
    mob:setMod(xi.mod.STORETP, 90)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 200)
end

return entity
