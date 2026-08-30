-----------------------------------
-- Area: Apollyon CS
--  Mob: Yagudo Archpriest
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
        [ 1] = { xi.magic.spell.PROTECT_IV,   mob,    true,  xi.action.type.ENHANCING_TARGET,     xi.effect.PROTECT,   0, 100 },
        [ 2] = { xi.magic.spell.SHELL_IV,     mob,    true,  xi.action.type.ENHANCING_TARGET,     xi.effect.SHELL,     0, 100 },
        [ 3] = { xi.magic.spell.HASTE,        mob,    true,  xi.action.type.ENHANCING_TARGET,     xi.effect.HASTE,     0, 100 },
        [ 4] = { xi.magic.spell.BLINK,        mob,    false, xi.action.type.ENHANCING_FORCE_SELF, xi.effect.BLINK,     0, 100 },
        [ 5] = { xi.magic.spell.STONESKIN,    mob,    false, xi.action.type.ENHANCING_FORCE_SELF, xi.effect.STONESKIN, 0, 100 },
        [ 6] = { xi.magic.spell.AQUAVEIL,     mob,    false, xi.action.type.ENHANCING_FORCE_SELF, xi.effect.AQUAVEIL,  0, 100 },
        [ 7] = { xi.magic.spell.CURAGA_IV,    mob,    true,  xi.action.type.HEALING_FORCE_SELF,   50,                  0, 100 },
        [ 8] = { xi.magic.spell.SILENCE,      target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.SILENCE,   0, 100 },
        [ 9] = { xi.magic.spell.SLOW,         target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.SLOW,      1, 100 },
        [10] = { xi.magic.spell.PARALYZE,     target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.PARALYSIS, 1, 100 },
        [11] = { xi.magic.spell.DIA_II,       target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.DIA,       2, 100 },
        [12] = { xi.magic.spell.DIAGA_II,     target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.DIA,       2, 100 },
        [13] = { xi.magic.spell.HOLY,         target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
        [14] = { xi.magic.spell.BANISH_III,   target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
        [15] = { xi.magic.spell.BANISHGA_III, target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
    }

    local party = mob:getParty()

    return xi.combat.behavior.chooseAction(mob, target, party, spellList)
end

return entity
