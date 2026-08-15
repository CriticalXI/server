-----------------------------------
-- Area: Apollyon NW, Floor 5
--  Mob: Kaiser Behemoth
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.GRAVITY)
    mob:addImmunity(xi.immunity.SILENCE)
    mob:addImmunity(xi.immunity.SLOW)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.PETRIFY)
    mob:addImmunity(xi.immunity.STUN)
end

entity.onMobSpawn = function(mob)
    mob:setMod(xi.mod.STORETP, 85)
    mob:setMod(xi.mod.UDMGMAGIC, -3000)
    mob:setMod(xi.mod.UDMGBREATH, -3000)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 200)
    mob:setMobMod(xi.mobMod.MAGIC_COOL, 42)
    mob:setMobMod(xi.mobMod.ALLI_HATE, 50)

    mob:setMaxMP(1000)
    mob:setMP(1000)
end

entity.onMobSpellChoose = function(mob, target, spellId)
    return xi.magic.spell.METEOR
end

entity.onSpellPrecast = function(mob, spell)
    if spell:getID() == 218 then
        spell:setAoE(xi.magic.aoe.RADIAL)
        spell:setRadius(30)
        spell:setAnimation(280)
        spell:setMPCost(1)
    end
end

return entity
