-----------------------------------
-- Area: Temenos Eastern Tower
--  Mob: Dark Elemental
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.SILENCE)
    mob:addImmunity(xi.immunity.BLIND)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:setMobMod(xi.mobMod.ADD_EFFECT, 1)
end

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
    mob:setMagicCastingEnabled(false)
end

entity.onMobEngage = function(mob, target)
    mob:setMagicCastingEnabled(true)
end

entity.onMobSpellChoose = function(mob, target, spellId)
    local spellList =
    {
        [1]  = { xi.magic.spell.BIO_III,    target, false, xi.action.type.ENFEEBLING_TARGET,     xi.effect.BIO,      0, 100 },
        [2]  = { xi.magic.spell.DRAIN,      target, false, xi.action.type.DRAIN_HP,              nil,                0, 100 },
        [3]  = { xi.magic.spell.ASPIR,      target, false, xi.action.type.DRAIN_MP,              nil,                0, 100 },
        [4]  = { xi.magic.spell.STUN,       target, false, xi.action.type.ENFEEBLING_TARGET,     xi.effect.STUN,     0, 100 },
        [5]  = { xi.magic.spell.ABSORB_INT, target, false, xi.action.type.ENFEEBLING_TARGET,     xi.effect.INT_DOWN, 0, 100 },
        [6]  = { xi.magic.spell.ABSORB_MND, target, false, xi.action.type.ENFEEBLING_TARGET,     xi.effect.MND_DOWN, 0, 100 },
        [7]  = { xi.magic.spell.SLEEPGA,    target, false, xi.action.type.ENFEEBLING_FORCE_SELF, xi.effect.SLEEP_I,  0, 100 },
        [8]  = { xi.magic.spell.SLEEPGA_II, target, false, xi.action.type.ENFEEBLING_FORCE_SELF, xi.effect.SLEEP_I,  0, 100 },
    }

    if
        target:hasStatusEffectByFlag(xi.effectFlag.DISPELABLE) and
        mob:isEngaged()
    then
        table.insert(spellList, #spellList + 1, { xi.magic.spell.DISPEL, target, false, xi.action.type.NONE, nil, 0, 100 })
    end

    return xi.combat.behavior.chooseAction(mob, target, nil, spellList)
end

entity.onAdditionalEffect = function(mob, target, damage)
    local pTable =
    {
        chance   = 25,
        effectId = xi.effect.CURSE_I,
        power    = 50,
        duration = 300,
    }

    return xi.combat.action.executeAddEffectEnfeeblement(mob, target, pTable)
end

entity.onMobDisengage = function(mob)
    mob:setMagicCastingEnabled(false)
end

return entity
