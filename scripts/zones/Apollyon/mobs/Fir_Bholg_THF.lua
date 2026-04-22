-----------------------------------
-- Area: Apollyon SW
--  NPC: Fir Bholg (THF)
-----------------------------------
mixins = { require('scripts/mixins/job_special') }
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.PLAGUE)
    mob:addImmunity(xi.immunity.TERROR)
end

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)

    xi.mix.jobSpecial.config(mob, {
        specials =
        {
            { id = xi.mobSkill.PERFECT_DODGE_1, hpp = math.randomInt(50, 60) },
        },
    })
end

entity.onMobMobskillChoose = function(mob)
    local tpList =
    {
        xi.mobSkill.NETHERSPIKES_1,
        xi.mobSkill.CARNAL_NIGHTMARE_1,
        xi.mobSkill.AEGIS_SCHISM_1,
        xi.mobSkill.DANCING_CHAINS_1,
        xi.mobSkill.BARBED_CRESCENT_1,
        xi.mobSkill.FOXFIRE,
    }

    return tpList[math.random(1, #tpList)]
end

return entity
