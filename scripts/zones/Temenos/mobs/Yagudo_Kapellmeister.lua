-----------------------------------
-- Area: Temenos
--  Mob: Yagudo Kapellmeister
--  Job: Bard
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
        [1] = { xi.magic.spell.VICTORY_MARCH,     mob,    true,  xi.action.type.ENHANCING_TARGET,     xi.effect.MARCH,   0, 100 },
        [2] = { xi.magic.spell.VALOR_MINUET_IV,   mob,    false, xi.action.type.ENHANCING_FORCE_SELF, xi.effect.MINUET,  0, 100 },
        [3] = { xi.magic.spell.ARMYS_PAEON_V,     mob,    false, xi.action.type.ENHANCING_FORCE_SELF, xi.effect.PAEON,   5, 100 },
        [4] = { xi.magic.spell.KNIGHTS_MINNE_IV,  mob,    false, xi.action.type.ENHANCING_FORCE_SELF, xi.effect.MINNE,   0, 100 },
        [5] = { xi.magic.spell.MAGES_BALLAD_II,   mob,    false, xi.action.type.ENHANCING_FORCE_SELF, xi.effect.BALLAD,  2, 100 },
        [6] = { xi.magic.spell.BATTLEFIELD_ELEGY, target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.ELEGY,   1, 100 },
        [7] = { xi.magic.spell.FOE_REQUIEM_VI,    target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.REQUIEM, 6, 100 },
        [8] = { xi.magic.spell.DEXTROUS_ETUDE,    mob,    true,  xi.action.type.ENHANCING_TARGET,     xi.effect.ETUDE,   0, 100 },
        [9] = { xi.magic.spell.SWIFT_ETUDE,       mob,    true,  xi.action.type.ENHANCING_TARGET,     xi.effect.ETUDE,   0, 100 },
    }

    if
        target:hasStatusEffectByFlag(xi.effectFlag.DISPELABLE) and
        mob:isEngaged()
    then
        table.insert(spellList, #spellList + 1, { xi.magic.spell.MAGIC_FINALE, target, false, xi.action.type.NONE, nil, 0, 100 })
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
