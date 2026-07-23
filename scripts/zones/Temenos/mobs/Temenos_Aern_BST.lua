-----------------------------------
-- Area: Temenos (Central Temenos Basement)
--  Mob: Temenos Aern (BST)
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    xi.pet.setMobPet(mob, -1, 'Aerns_Euvhi')
    xi.pet.setMobPet(mob, 1, 'Aerns_Euvhi')
end

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
end

return entity
