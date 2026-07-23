-----------------------------------
-- Area: Temenos (Central Temenos Basement)
--  Mob: Temenos Aern (MNK)
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
end

return entity
