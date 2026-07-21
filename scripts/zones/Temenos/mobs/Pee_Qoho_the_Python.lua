-----------------------------------
-- Area: Temenos
--  Mob: Pee Qoho the Python
-----------------------------------
mixins = { require('scripts/mixins/job_special') }
-----------------------------------
---@type TMobEntity
local entity = {}

local callPetParams =
{
    dieWithOwner = true,
    superLink = true,
    inactiveTime = 3000,
    maxSpawns = 1,
}

entity.onMobInitialize = function(mob)
    xi.pet.setMobPet(mob, 1, 'Yagudos_Elemental')
    mob:setMobMod(xi.mobMod.ASTRAL_PET_OFFSET, 2)
end

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

    mob:timer(10000, function(mobArg)
        xi.mob.callPets(mobArg, mobArg:getID() + 1, callPetParams)
    end)
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

entity.onMobFight = function(mob, target)
    local pet = mob:getPet()

    if not pet then
        return
    end

    if pet:isSpawned() then
        return
    end

    if mob:getLocalVar('petSummonTime') > GetSystemTime() then
        return
    end

    xi.mob.callPets(mob, mob:getID() + 1, callPetParams)
end

return entity
