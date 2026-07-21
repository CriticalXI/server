-----------------------------------
-- Area: Temenos
--  Mob: Star Ruby Quadav
-----------------------------------
mixins = { require('scripts/mixins/job_special') }
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
end

entity.onMobSpellChoose = function(mob, target, spellId)
    local spellList =
    {
        [ 1] = { xi.magic.spell.STONE_III,   target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
        [ 2] = { xi.magic.spell.WATER_III,   target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
        [ 3] = { xi.magic.spell.AERO_III,    target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
        [ 4] = { xi.magic.spell.FIRE_II,     target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
        [ 5] = { xi.magic.spell.BLIZZARD_II, target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
        [ 6] = { xi.magic.spell.THUNDER_II,  target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
        [ 7] = { xi.magic.spell.CURE_IV,     mob,    true,  xi.action.type.HEALING_TARGET,       33,                  0, 100 },
        [ 8] = { xi.magic.spell.BIO_II,      target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.BIO,       2, 100 },
        [ 9] = { xi.magic.spell.BIND,        target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.BIND,      0, 100 },
        [10] = { xi.magic.spell.BLIND,       target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.BLINDNESS, 1, 100 },
        [11] = { xi.magic.spell.SILENCE,     target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.SILENCE,   0, 100 },
        [12] = { xi.magic.spell.PARALYZE,    target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.PARALYSIS, 1, 100 },
        [13] = { xi.magic.spell.SLOW,        target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.SLOW,      1, 100 },
        [14] = { xi.magic.spell.DIA_II,      target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.DIA,       2, 100 },
        [15] = { xi.magic.spell.DIAGA_II,    target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.DIA,       2, 100 },
        [16] = { xi.magic.spell.POISON_II,   target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.POISON,    2, 100 },
        [17] = { xi.magic.spell.GRAVITY,     target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.WEIGHT,    0, 100 },
        [18] = { xi.magic.spell.PROTECT_IV,  mob,    true,  xi.action.type.ENHANCING_TARGET,     xi.effect.PROTECT,   4, 100 },
        [19] = { xi.magic.spell.SHELL_IV,    mob,    true,  xi.action.type.ENHANCING_TARGET,     xi.effect.SHELL,     4, 100 },
        [20] = { xi.magic.spell.HASTE,       mob,    true,  xi.action.type.ENHANCING_TARGET,     xi.effect.HASTE,     0, 100 },
        [21] = { xi.magic.spell.REGEN,       mob,    true,  xi.action.type.ENHANCING_TARGET,     xi.effect.REGEN,     1, 100 },
        [22] = { xi.magic.spell.STONESKIN,   mob,    false, xi.action.type.ENHANCING_FORCE_SELF, xi.effect.STONESKIN, 0, 100 },
        [23] = { xi.magic.spell.AQUAVEIL,    mob,    false, xi.action.type.ENHANCING_FORCE_SELF, xi.effect.AQUAVEIL,  0, 100 },
        [24] = { xi.magic.spell.BLINK,       mob,    false, xi.action.type.ENHANCING_FORCE_SELF, xi.effect.BLINK,     0, 100 },
        [25] = { xi.magic.spell.ENWATER,     mob,    false, xi.action.type.ENHANCING_FORCE_SELF, xi.effect.ENWATER,   1, 100 },
    }

    if
        target:hasStatusEffectByFlag(xi.effectFlag.DISPELABLE) and
        mob:isEngaged()
    then
        table.insert(spellList, #spellList + 1, { xi.magic.spell.DISPEL, target, false, xi.action.type.NONE, nil, 0, 100 })
    end

    local mobParty = {}

    for _, member in ipairs(mob:getParty()) do
        if
            member and
            member:getID() ~= mob:getID() and
            member:isAlive() and
            member:checkDistance(mob) < 20
        then
            table.insert(mobParty, member)
        end
    end

    return xi.combat.behavior.chooseAction(mob, target, mobParty, spellList)
end

return entity
