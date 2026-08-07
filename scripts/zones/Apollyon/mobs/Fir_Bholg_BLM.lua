-----------------------------------
-- Area: Apollyon SW
--  NPC: Fir Bholg (BLM)
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
    mob:setMobMod(xi.mobMod.NO_STANDBACK, 1)
    mob:setMod(xi.mod.MDEF, 100)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)

    xi.mix.jobSpecial.config(mob, {
        specials =
        {
            { id = xi.mobSkill.MANAFONT_1, hpp = math.randomInt(50, 60) },
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

entity.onMobSpellChoose = function(mob, target, spellId)
    local spellList =
    {
        [ 1] = { xi.magic.spell.FIRE_IV,      target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [ 2] = { xi.magic.spell.BLIZZARD_IV,  target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [ 3] = { xi.magic.spell.AERO_IV,      target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [ 4] = { xi.magic.spell.STONE_IV,     target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [ 5] = { xi.magic.spell.THUNDER_IV,   target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [ 6] = { xi.magic.spell.WATER_IV,     target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [ 7] = { xi.magic.spell.FIRAGA_III,   target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [ 8] = { xi.magic.spell.BLIZZAGA_III, target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [ 9] = { xi.magic.spell.AEROGA_III,   target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [10] = { xi.magic.spell.STONEGA_III,  target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [11] = { xi.magic.spell.THUNDAGA_III, target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [12] = { xi.magic.spell.WATERGA_III,  target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [13] = { xi.magic.spell.POISON_II,    target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.POISON,    0, 100 },
        [14] = { xi.magic.spell.BIO_III,      target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.BIO,       6, 100 },
        [15] = { xi.magic.spell.DRAIN,        target, false, xi.action.type.DRAIN_HP,          nil,                 0, 100 },
        [16] = { xi.magic.spell.ASPIR,        target, false, xi.action.type.DRAIN_MP,          nil,                 0, 100 },
        [17] = { xi.magic.spell.SLEEP,        target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.SLEEP_I,   1, 100 },
        [18] = { xi.magic.spell.BLIND,        target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.BLINDNESS, 0, 100 },
        [19] = { xi.magic.spell.BIND,         target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.BIND,      0, 100 },
        [20] = { xi.magic.spell.SLEEP_II,     target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.SLEEP_I,   2, 100 },
        [21] = { xi.magic.spell.DISPEL,       target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [22] = { xi.magic.spell.SLEEPGA,      target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.SLEEP_I,   1, 100 },
        [23] = { xi.magic.spell.SLEEPGA_II,   target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.SLEEP_I,   2, 100 },
    }

    return xi.combat.behavior.chooseAction(mob, target, nil, spellList)
end

return entity
