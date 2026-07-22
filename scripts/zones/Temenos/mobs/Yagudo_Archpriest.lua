-----------------------------------
-- Area: Temenos
--  Mob: Yagudo Archpriest
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
        [ 1] = { xi.magic.spell.BANISHGA_III, target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
        [ 2] = { xi.magic.spell.HOLY,         target, false, xi.action.type.DAMAGE_TARGET,        nil,                 0, 100 },
        [ 3] = { xi.magic.spell.CURE_V,       mob,    true,  xi.action.type.HEALING_TARGET,       66,                  0, 100 },
        [ 4] = { xi.magic.spell.CURAGA_IV,    mob,    true,  xi.action.type.HEALING_TARGET,       33,                  0, 100 },
        [ 5] = { xi.magic.spell.BLINDNA,      mob,    true,  xi.action.type.HEALING_EFFECT,       xi.effect.BLINDNESS, 0, 100 },
        [ 6] = { xi.magic.spell.PARALYNA,     mob,    true,  xi.action.type.HEALING_EFFECT,       xi.effect.PARALYSIS, 0, 100 },
        [ 7] = { xi.magic.spell.POISONA,      mob,    true,  xi.action.type.HEALING_EFFECT,       xi.effect.POISON,    0, 100 },
        [ 8] = { xi.magic.spell.SILENA,       mob,    true,  xi.action.type.HEALING_EFFECT,       xi.effect.SILENCE,   0, 100 },
        [ 9] = { xi.magic.spell.VIRUNA,       mob,    true,  xi.action.type.HEALING_EFFECT,       xi.effect.DISEASE,   0, 100 },
        [10] = { xi.magic.spell.VIRUNA,       mob,    true,  xi.action.type.HEALING_EFFECT,       xi.effect.PLAGUE,    0, 100 },
        [11] = { xi.magic.spell.FLASH,        target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.FLASH,     0, 100 },
        [12] = { xi.magic.spell.SILENCE,      target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.SILENCE,   0, 100 },
        [13] = { xi.magic.spell.PARALYZE,     target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.PARALYSIS, 1, 100 },
        [14] = { xi.magic.spell.SLOW,         target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.SLOW,      1, 100 },
        [15] = { xi.magic.spell.DIA_II,       target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.DIA,       2, 100 },
        [16] = { xi.magic.spell.PROTECT_IV,   mob,    true,  xi.action.type.ENHANCING_TARGET,     xi.effect.PROTECT,   4, 100 },
        [17] = { xi.magic.spell.SHELL_IV,     mob,    true,  xi.action.type.ENHANCING_TARGET,     xi.effect.SHELL,     3, 100 },
        [18] = { xi.magic.spell.HASTE,        mob,    true,  xi.action.type.ENHANCING_TARGET,     xi.effect.HASTE,     0, 100 },
        [19] = { xi.magic.spell.STONESKIN,    mob,    false, xi.action.type.ENHANCING_FORCE_SELF, xi.effect.STONESKIN, 4, 100 },
        [20] = { xi.magic.spell.AQUAVEIL,     mob,    false, xi.action.type.ENHANCING_FORCE_SELF, xi.effect.AQUAVEIL,  4, 100 },
        [21] = { xi.magic.spell.BLINK,        mob,    false, xi.action.type.ENHANCING_FORCE_SELF, xi.effect.BLINK,     3, 100 },
    }

    -- Heal/buff nearby Yagudo family members.
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
