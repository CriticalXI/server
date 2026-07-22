-----------------------------------
-- Area: Temenos (Central Temenos Basement)
--  Mob: Temenos Aern (PLD)
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
end

entity.onMobSpellChoose = function(mob, target, spellId)
    local spellList =
    {
        [1] = { xi.magic.spell.BANISH_II,  target, false, xi.action.type.DAMAGE_TARGET,     nil,               0, 100 },
        [2] = { xi.magic.spell.CURE_IV,    mob,    true,  xi.action.type.HEALING_TARGET,    33,                0, 100 },
        [3] = { xi.magic.spell.FLASH,      target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.FLASH,   0, 100 },
        [4] = { xi.magic.spell.PROTECT_IV, mob,    true,  xi.action.type.ENHANCING_TARGET,  xi.effect.PROTECT, 4, 100 },
        [5] = { xi.magic.spell.SHELL_IV,   mob,    true,  xi.action.type.ENHANCING_TARGET,  xi.effect.SHELL,   3, 100 },
    }

    -- Heal/buff nearby Aern room members.
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
