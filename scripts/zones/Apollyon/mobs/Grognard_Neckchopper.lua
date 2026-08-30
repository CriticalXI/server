-----------------------------------
-- Area: Apollyon CS
--  Mob: Grognard Neckchopper
-----------------------------------
mixins = { require('scripts/mixins/job_special') }
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:setMod(xi.mod.HPP, 60)
    mob:addImmunity(xi.immunity.GRAVITY)
    mob:addImmunity(xi.immunity.BIND)
end

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
end

entity.onMobSpellChoose = function(mob, target, spellId)
    local spellList =
    {
        [ 1] = { xi.magic.spell.STUN,        target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.STUN,     0, 100 },
        [ 2] = { xi.magic.spell.POISON,      target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.POISON,   1, 100 },
        [ 3] = { xi.magic.spell.ABSORB_STR,  target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.STR_DOWN, 0, 100 },
        [ 4] = { xi.magic.spell.ABSORB_DEX,  target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.DEX_DOWN, 0, 100 },
        [ 5] = { xi.magic.spell.ABSORB_VIT,  target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.VIT_DOWN, 0, 100 },
        [ 6] = { xi.magic.spell.ABSORB_AGI,  target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.AGI_DOWN, 0, 100 },
        [ 7] = { xi.magic.spell.ABSORB_INT,  target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.INT_DOWN, 0, 100 },
        [ 8] = { xi.magic.spell.ABSORB_MND,  target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.MND_DOWN, 0, 100 },
        [ 9] = { xi.magic.spell.ABSORB_CHR,  target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.CHR_DOWN, 0, 100 },
        [10] = { xi.magic.spell.ABSORB_TP,   target, false, xi.action.type.DAMAGE_TARGET,     nil,                0, 100 },
        [11] = { xi.magic.spell.DRAIN,       target, false, xi.action.type.DRAIN_HP,          nil,                0, 100 },
        [12] = { xi.magic.spell.ASPIR,       target, false, xi.action.type.DRAIN_MP,          nil,                0, 100 },
        [13] = { xi.magic.spell.FIRE_II,     target, false, xi.action.type.DAMAGE_TARGET,     nil,                0, 100 },
        [14] = { xi.magic.spell.BLIZZARD_II, target, false, xi.action.type.DAMAGE_TARGET,     nil,                0, 100 },
        [15] = { xi.magic.spell.AERO_II,     target, false, xi.action.type.DAMAGE_TARGET,     nil,                0, 100 },
        [16] = { xi.magic.spell.STONE_III,   target, false, xi.action.type.DAMAGE_TARGET,     nil,                0, 100 },
        [17] = { xi.magic.spell.THUNDER_II,  target, false, xi.action.type.DAMAGE_TARGET,     nil,                0, 100 },
        [18] = { xi.magic.spell.WATER_II,    target, false, xi.action.type.DAMAGE_TARGET,     nil,                0, 100 },
    }

    return xi.combat.behavior.chooseAction(mob, target, nil, spellList)
end

return entity
