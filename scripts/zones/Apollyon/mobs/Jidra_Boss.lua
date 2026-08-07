-----------------------------------
-- Area: Apollyon SW
--  Mob: Jidra (Boss)
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.PLAGUE)
    mob:addImmunity(xi.immunity.TERROR)
    mob:addImmunity(xi.immunity.BIND)
    mob:setMod(xi.mod.UDMGBREATH, -2500)
end

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.ROAM_DISTANCE, 0)
    mob:setMod(xi.mod.DEF, 750)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 200)
end

entity.onMobMobskillChoose = function(mob)
    local tpList =
    {
        xi.mobSkill.DRILL_BRANCH_NM,
        xi.mobSkill.PINECONE_BOMB_NM,
        xi.mobSkill.LEAFSTORM_DISPEL,
        xi.mobSkill.ENTANGLE_POISON,
    }

    return tpList[math.random(1, #tpList)]
end

return entity
