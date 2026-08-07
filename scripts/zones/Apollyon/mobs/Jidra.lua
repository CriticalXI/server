-----------------------------------
-- Area: Apollyon SW
--  Mob: Jidra
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.PLAGUE)
    mob:addImmunity(xi.immunity.TERROR)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:setMod(xi.mod.UDMGBREATH, -2500)
end

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.ROAM_DISTANCE, 0)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
end

entity.onMobMobskillChoose = function(mob)
    local tpList =
    {
        xi.mobSkill.DRILL_BRANCH,
        xi.mobSkill.PINECONE_BOMB,
        xi.mobSkill.LEAFSTORM,
        xi.mobSkill.ENTANGLE,
    }

    return tpList[math.random(1, #tpList)]
end

return entity
