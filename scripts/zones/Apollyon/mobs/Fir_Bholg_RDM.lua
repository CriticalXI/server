-----------------------------------
-- Area: Apollyon SW
--  NPC: Fir Bholg (RDM)
-----------------------------------
mixins = { require('scripts/mixins/job_special') }
-----------------------------------
local ID = zones[xi.zone.APOLLYON]
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.PLAGUE)
    mob:addImmunity(xi.immunity.TERROR)
end

entity.onMobSpawn = function(mob)
    mob:setMod(xi.mod.MDEF, 212)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)

    xi.mix.jobSpecial.config(mob, {
        specials =
        {
            { id = xi.mobSkill.CHAINSPELL_1, hpp = math.randomInt(50, 60) },
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
        [ 1] = { xi.magic.spell.DIA_II,       target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.DIA,       3, 100 },
        [ 2] = { xi.magic.spell.DIAGA_II,     target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.DIA,       3, 100 },
        [ 3] = { xi.magic.spell.PROTECT_IV,   mob,    true,  xi.action.type.ENHANCING_TARGET,  xi.effect.PROTECT,   0, 100 },
        [ 4] = { xi.magic.spell.SHELL_IV,     mob,    true,  xi.action.type.ENHANCING_TARGET,  xi.effect.SHELL,     0, 100 },
        [ 5] = { xi.magic.spell.BLINK,        mob,    false, xi.action.type.ENHANCING_TARGET,  xi.effect.BLINK,     0, 100 },
        [ 6] = { xi.magic.spell.STONESKIN,    mob,    false, xi.action.type.ENHANCING_TARGET,  xi.effect.STONESKIN, 0, 100 },
        [ 7] = { xi.magic.spell.AQUAVEIL,     mob,    false, xi.action.type.ENHANCING_TARGET,  xi.effect.AQUAVEIL,  0, 100 },
        [ 8] = { xi.magic.spell.SLOW,         target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.SLOW,      3, 100 },
        [ 9] = { xi.magic.spell.HASTE,        mob,    true,  xi.action.type.ENHANCING_TARGET,  xi.effect.HASTE,     0, 100 },
        [10] = { xi.magic.spell.PARALYZE,     target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.PARALYSIS, 0, 100 },
        [11] = { xi.magic.spell.SILENCE,      target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.SILENCE,   0, 100 },
        [12] = { xi.magic.spell.ENWATER,      mob,    false, xi.action.type.ENHANCING_TARGET,  xi.effect.ENWATER,   0, 100 },
        [13] = { xi.magic.spell.FIRE_III,     target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [14] = { xi.magic.spell.BLIZZARD_III, target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [15] = { xi.magic.spell.AERO_III,     target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [16] = { xi.magic.spell.STONE_III,    target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [17] = { xi.magic.spell.THUNDER_III,  target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [18] = { xi.magic.spell.WATER_III,    target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [19] = { xi.magic.spell.GRAVITY,      target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.WEIGHT,    0, 100 },
        [20] = { xi.magic.spell.POISON_II,    target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.POISON,    0, 100 },
        [21] = { xi.magic.spell.BIO_III,      target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.BIO,       6, 100 },
        [22] = { xi.magic.spell.SLEEP,        target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.SLEEP_I,   1, 100 },
        [23] = { xi.magic.spell.SLEEP_II,     target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.SLEEP_I,   2, 100 },
    }

    local groupTable = {}

    for offset = 0, 9 do
        local ally = GetMobByID(ID.mob.SW_FIR_BHOLG_OFFSET + offset)

        if
            ally and
            ally:getID() ~= mob:getID()
        then
            table.insert(groupTable, ally)
        end
    end

    return xi.combat.behavior.chooseAction(mob, target, groupTable, spellList)
end

return entity
