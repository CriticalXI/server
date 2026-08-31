-----------------------------------
-- Area: Apollyon CS
--  Mob: Na'Qba Chirurgeon
-----------------------------------
mixins = { require('scripts/mixins/job_special') }
-----------------------------------
---@type TMobEntity
local entity = {}

local supportOffsets1 = { 1, 2, 3 }
local supportOffsets2 = { 4, 5, 6 }

entity.onMobInitialize = function(mob)
    mob:setMod(xi.mod.HPP, 300)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:addImmunity(xi.immunity.GRAVITY)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.SILENCE)
end

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
    -- setDelay persists across respawns; restore the pool value
    mob:setDelay(240)
    mob:setLocalVar('storedDelay', 240)
end

entity.onMobEngage = function(mob, target)
    local content = xi.battlefield.contents[xi.battlefield.id.CS_APOLLYON]
    content.handleBossAutoAggro(mob, target)
end

entity.onMobFight = function(mob, target)
    local timeInCombat = mob:getBattleTime()
    local storedDelay = mob:getLocalVar('storedDelay')
    local content = xi.battlefield.contents[xi.battlefield.id.CS_APOLLYON]

    content.handleBossCombatTick(mob, supportOffsets1, supportOffsets2)

    if storedDelay == 120 then
        return
    end

    if
        timeInCombat >= 600 and
        storedDelay ~= 120
    then
        mob:setDelay(120)
        mob:setLocalVar('storedDelay', 120)
    elseif
        timeInCombat >= 300 and
        timeInCombat < 600 and
        storedDelay ~= 180
    then
        mob:setDelay(180)
        mob:setLocalVar('storedDelay', 180)
    end
end

entity.onMobSpellChoose = function(mob, target, spellId)
    local spellList =
    {
        [1] = { xi.magic.spell.FLASH,        target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.FLASH, 0, 100 },
        [2] = { xi.magic.spell.DIAGA_II,     target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.DIA,   2, 100 },
        [3] = { xi.magic.spell.BANISHGA_III, target, false, xi.action.type.DAMAGE_TARGET,     nil,             0, 100 },
    }

    return xi.combat.behavior.chooseAction(mob, target, nil, spellList)
end

return entity
