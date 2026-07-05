-----------------------------------
-- Area: Central Temenos 1st Floor
--  Mob: Enhanced Dragon
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 200)
end

return entity
