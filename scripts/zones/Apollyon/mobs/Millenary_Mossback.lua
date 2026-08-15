-----------------------------------
-- Area: Apollyon NW, Floor 3
--  Mob: Millenary Mossback
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.POISON)
    mob:addImmunity(xi.immunity.SLOW)
    mob:addImmunity(xi.immunity.PETRIFY)
end

entity.onMobSpawn = function(mob)
    mob:setMod(xi.mod.STORETP, 90)
    mob:setMod(xi.mod.DEFP, 20)
    mob:setMod(xi.mod.UDMGMAGIC, -5000)
    mob:setMod(xi.mod.UDMGBREATH, -5000)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 200)
end

return entity
