-----------------------------------
-- Area: Apollyon CS
--  Mob: Yagudo's Avatar
-----------------------------------
mixins = { require('scripts/mixins/families/avatar') }
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
end

return entity
