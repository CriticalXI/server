-----------------------------------
-- Area: Temenos
--  Mob: Yagudo's Elemental
-----------------------------------
require('scripts/globals/pets/summon')
-----------------------------------
---@type TMobEntity
local entity = {}

local possibleElementals =
{
    xi.pets.summon.type.FIRE_SPIRIT,
    xi.pets.summon.type.AIR_SPIRIT,
    xi.pets.summon.type.EARTH_SPIRIT,
}

entity.onMobSpawn = function(mob)
    xi.pets.summon.setupSummon(mob, possibleElementals)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
end

entity.onMobDeath = function(mob, player, optParams)
    if optParams.isKiller or optParams.noKiller then
        local master = mob:getMaster()

        if not master then
            return
        end

        master:setLocalVar('petSummonTime', GetSystemTime() + 30)
    end
end

return entity
