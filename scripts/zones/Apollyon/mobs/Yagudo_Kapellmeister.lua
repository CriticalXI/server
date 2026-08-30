-----------------------------------
-- Area: Apollyon CS
--  Mob: Yagudo Kapellmeister
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
        [1] = { xi.magic.spell.VALOR_MINUET_IV,   mob,    true,  xi.action.type.ENHANCING_TARGET,     xi.effect.MINUET,  0, 100 },
        [2] = { xi.magic.spell.KNIGHTS_MINNE_IV,  mob,    true,  xi.action.type.ENHANCING_TARGET,     xi.effect.MINNE,   0, 100 },
        [3] = { xi.magic.spell.VICTORY_MARCH,     mob,    true,  xi.action.type.ENHANCING_TARGET,     xi.effect.MARCH,   0, 100 },
        [4] = { xi.magic.spell.UNCANNY_ETUDE,     mob,    false, xi.action.type.ENHANCING_FORCE_SELF, xi.effect.ETUDE,   0, 100 },
        [5] = { xi.magic.spell.SWIFT_ETUDE,       mob,    false, xi.action.type.ENHANCING_FORCE_SELF, xi.effect.ETUDE,   0, 100 },
        [6] = { xi.magic.spell.FOE_REQUIEM_VII,   target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.REQUIEM, 6, 100 },
        [7] = { xi.magic.spell.BATTLEFIELD_ELEGY, target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.ELEGY,   0, 100 },
        [8] = { xi.magic.spell.HORDE_LULLABY,     target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.SLEEP_I, 1, 100 },
    }

    if
        mob:isEngaged() and
        target:hasStatusEffectByFlag(xi.effectFlag.DISPELABLE)
    then
        table.insert(spellList, { xi.magic.spell.MAGIC_FINALE, target, false, xi.action.type.NONE, nil, 0, 100 })
    end

    local party = mob:getParty()

    return xi.combat.behavior.chooseAction(mob, target, party, spellList)
end

return entity
