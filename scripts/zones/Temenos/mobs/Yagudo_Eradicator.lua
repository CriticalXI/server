-----------------------------------
-- Area: Temenos
--  Mob: Yagudo Eradicator
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
        [ 1] = { xi.magic.spell.KATON_NI,    target, false, xi.action.type.DAMAGE_TARGET,        nil,                  0, 66  },
        [ 2] = { xi.magic.spell.HYOTON_NI,   target, false, xi.action.type.DAMAGE_TARGET,        nil,                  0, 66  },
        [ 3] = { xi.magic.spell.HUTON_NI,    target, false, xi.action.type.DAMAGE_TARGET,        nil,                  0, 66  },
        [ 4] = { xi.magic.spell.DOTON_NI,    target, false, xi.action.type.DAMAGE_TARGET,        nil,                  0, 66  },
        [ 5] = { xi.magic.spell.RAITON_NI,   target, false, xi.action.type.DAMAGE_TARGET,        nil,                  0, 66  },
        [ 6] = { xi.magic.spell.SUITON_NI,   target, false, xi.action.type.DAMAGE_TARGET,        nil,                  0, 66  },
        [ 7] = { xi.magic.spell.JUBAKU_NI,   target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.PARALYSIS,  2, 100 },
        [ 8] = { xi.magic.spell.DOKUMORI_NI, target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.POISON,     2, 100 },
        [ 9] = { xi.magic.spell.KURAYAMI_NI, target, false, xi.action.type.ENFEEBLING_TARGET,    xi.effect.BLINDNESS,  2, 100 },
        [10] = { xi.magic.spell.UTSUSEMI_NI, mob,    false, xi.action.type.ENHANCING_FORCE_SELF, xi.effect.COPY_IMAGE, 2, 100 },
    }

    return xi.combat.behavior.chooseAction(mob, target, nil, spellList)
end

return entity
