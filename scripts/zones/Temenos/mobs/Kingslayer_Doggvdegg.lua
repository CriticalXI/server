-----------------------------------
-- Area: Temenos (Central Temenos 4th Floor)
--  Mob: Kingslayer Doggvdegg
-----------------------------------
mixins = { require('scripts/mixins/job_special') }
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 200)

    mob:setMod(xi.mod.REGAIN, 150)

    mob:setMod(xi.mod.PARALYZE_RES_RANK, 4)
    mob:setMod(xi.mod.BIND_RES_RANK, 4)
    mob:setMod(xi.mod.SILENCE_RES_RANK, 4)
    mob:setMod(xi.mod.SLOW_RES_RANK, 4)
    mob:setMod(xi.mod.POISON_RES_RANK, 4)
    mob:setMod(xi.mod.LIGHT_SLEEP_RES_RANK, 4)
    mob:setMod(xi.mod.DARK_SLEEP_RES_RANK, 4)
    mob:setMod(xi.mod.BLIND_RES_RANK, 4)
end

return entity
