-----------------------------------
-- Area: Apollyon CS
--  Mob: Grognard Impaler
-----------------------------------
mixins = { require('scripts/mixins/job_special') }
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    xi.pet.setMobPet(mob, 1, 'Orcs_Wyvern')
    mob:setMod(xi.mod.HPP, 60)
    mob:addImmunity(xi.immunity.GRAVITY)
    mob:addImmunity(xi.immunity.BIND)
end

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
    xi.mix.jobSpecial.config(mob, {
        specials =
        {
            { id = xi.mobSkill.CALL_WYVERN_1, hpp = 100 },
        },
    })
end

return entity
