-----------------------------------
-- Area: Temenos
--  Mob: Abyssdweller Jhabdebb
-----------------------------------
mixins = { require('scripts/mixins/job_special') }
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 200)

    mob:setMod(xi.mod.DMG, -5000)
    mob:setMod(xi.mod.ATTP, 0)
    mob:setMod(xi.mod.UDMGPHYS, 0)
    mob:setMod(xi.mod.UDMGRANGE, 0)
    mob:setMod(xi.mod.UDMGMAGIC, 0)
    mob:setMod(xi.mod.UDMGBREATH, 0)

    mob:setMod(xi.mod.PARALYZE_RES_RANK, 4)
    mob:setMod(xi.mod.BIND_RES_RANK, 4)
    mob:setMod(xi.mod.SILENCE_RES_RANK, 4)
    mob:setMod(xi.mod.SLOW_RES_RANK, 4)
    mob:setMod(xi.mod.POISON_RES_RANK, 4)
    mob:setMod(xi.mod.LIGHT_SLEEP_RES_RANK, 4)
    mob:setMod(xi.mod.DARK_SLEEP_RES_RANK, 4)
    mob:setMod(xi.mod.BLIND_RES_RANK, 4)
end

entity.onMobSpellChoose = function(mob, target, spellId)
    local spellList =
    {
        [1] = { xi.magic.spell.BANISH_II,  target, false, xi.action.type.DAMAGE_TARGET,     nil,               0, 100 },
        [2] = { xi.magic.spell.CURE_IV,    mob,    true,  xi.action.type.HEALING_TARGET,    33,                0, 100 },
        [3] = { xi.magic.spell.FLASH,      target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.FLASH,   0, 100 },
        [4] = { xi.magic.spell.PROTECT_IV, mob,    true,  xi.action.type.ENHANCING_TARGET,  xi.effect.PROTECT, 4, 100 },
        [5] = { xi.magic.spell.SHELL_III,  mob,    true,  xi.action.type.ENHANCING_TARGET,  xi.effect.SHELL,   3, 100 },
    }

    local bossParty = {}

    for _, member in ipairs(mob:getParty()) do
        if
            member and
            member:getID() ~= mob:getID() and
            member:isAlive() and
            member:checkDistance(mob) < 20
        then
            table.insert(bossParty, member)
        end
    end

    return xi.combat.behavior.chooseAction(mob, target, bossParty, spellList)
end

entity.onMobEngage = function(mob, target)
    for _, member in ipairs(mob:getParty()) do
        if
            member and
            member:getID() ~= mob:getID()
        then
            member:updateEnmity(target)
        end
    end
end

return entity
