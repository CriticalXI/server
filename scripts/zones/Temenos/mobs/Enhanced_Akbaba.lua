-----------------------------------
-- Area: Temenos (Central Temenos 4th Floor)
--  Mob: Enhanced Akbaba
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 200)
end

return entity
