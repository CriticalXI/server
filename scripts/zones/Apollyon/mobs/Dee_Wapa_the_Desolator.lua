-----------------------------------
-- Area: Apollyon CS
--  Mob: Dee Wapa the Desolator
-----------------------------------
mixins = { require('scripts/mixins/job_special') }
-----------------------------------
---@type TMobEntity
local entity = {}

local supportOffsets1 = { 3, 4, 5 }
local supportOffsets2 = { 6, 7, 8 }

entity.onMobInitialize = function(mob)
    xi.pet.setMobPet(mob, 1, 'Yagudos_Elemental')
    mob:setMod(xi.mod.HPP, 300)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:addImmunity(xi.immunity.GRAVITY)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.SILENCE)
end

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
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

    if storedDelay == 140 then
        return
    end

    if
        timeInCombat >= 600 and
        storedDelay ~= 140
    then
        mob:setDelay(140)
        mob:setLocalVar('storedDelay', 140)
    elseif
        timeInCombat >= 300 and
        timeInCombat < 600 and
        storedDelay ~= 200
    then
        mob:setDelay(200)
        mob:setLocalVar('storedDelay', 200)
    end
end

return entity
