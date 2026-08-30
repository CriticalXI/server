-----------------------------------
-- Area: Apollyon CS
--  Mob: Grognard Mesmerizer
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
        [ 1] = { xi.magic.spell.STUN,         target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.STUN,      0, 100 },
        [ 2] = { xi.magic.spell.SLEEP,        target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.SLEEP_I,   1, 100 },
        [ 3] = { xi.magic.spell.SLEEP_II,     target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.SLEEP_I,   2, 100 },
        [ 4] = { xi.magic.spell.SLEEPGA,      target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.SLEEP_I,   1, 100 },
        [ 5] = { xi.magic.spell.SLEEPGA_II,   target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.SLEEP_I,   2, 100 },
        [ 6] = { xi.magic.spell.BLIND,        target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.BLINDNESS, 0, 100 },
        [ 7] = { xi.magic.spell.BIND,         target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.BIND,      0, 100 },
        [ 8] = { xi.magic.spell.POISONGA_II,  target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.POISON,    1, 100 },
        [ 9] = { xi.magic.spell.BIO_II,       target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.BIO,       2, 100 },
        [10] = { xi.magic.spell.FIRE_IV,      target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [11] = { xi.magic.spell.BLIZZARD_IV,  target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [12] = { xi.magic.spell.AERO_IV,      target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [13] = { xi.magic.spell.WATER_IV,     target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [14] = { xi.magic.spell.THUNDER_IV,   target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [15] = { xi.magic.spell.FIRAGA_III,   target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [16] = { xi.magic.spell.THUNDAGA_III, target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
    }

    return xi.combat.behavior.chooseAction(mob, target, nil, spellList)
end

return entity
