-----------------------------------
-- Area: Apollyon CS
--  Mob: Lightsteel Quadav
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
        [1] = { xi.magic.spell.PROTECT_IV, mob,    true,  xi.action.type.ENHANCING_TARGET,  xi.effect.PROTECT, 0, 100 },
        [2] = { xi.magic.spell.SHELL_III,  mob,    true,  xi.action.type.ENHANCING_TARGET,  xi.effect.SHELL,   0, 100 },
        [3] = { xi.magic.spell.FLASH,      target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.FLASH,   0, 100 },
        [4] = { xi.magic.spell.BANISH_II,  target, false, xi.action.type.DAMAGE_TARGET,     nil,               0, 100 },
    }

    local party = mob:getParty()

    return xi.combat.behavior.chooseAction(mob, target, party, spellList)
end

return entity
