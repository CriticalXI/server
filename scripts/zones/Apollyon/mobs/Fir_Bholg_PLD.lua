-----------------------------------
-- Area: Apollyon SW
--  NPC: Fir Bholg (PLD)
-----------------------------------
mixins = { require('scripts/mixins/job_special') }
-----------------------------------
local ID = zones[xi.zone.APOLLYON]
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.PLAGUE)
    mob:addImmunity(xi.immunity.TERROR)
end

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)

    xi.mix.jobSpecial.config(mob, {
        specials =
        {
            { id = xi.mobSkill.INVINCIBLE_1, hpp = math.randomInt(50, 60) },
        },
    })
end

entity.onMobMobskillChoose = function(mob)
    local tpList =
    {
        xi.mobSkill.NETHERSPIKES_1,
        xi.mobSkill.CARNAL_NIGHTMARE_1,
        xi.mobSkill.AEGIS_SCHISM_1,
        xi.mobSkill.DANCING_CHAINS_1,
        xi.mobSkill.BARBED_CRESCENT_1,
        xi.mobSkill.FOXFIRE,
    }

    return tpList[math.random(1, #tpList)]
end

entity.onMobSpellChoose = function(mob, target, spellId)
    local spellList =
    {
        [1] = { xi.magic.spell.PROTECT_IV, mob,    false, xi.action.type.ENHANCING_TARGET,  xi.effect.PROTECT, 0, 100 },
        [2] = { xi.magic.spell.SHELL_III,  mob,    false, xi.action.type.ENHANCING_TARGET,  xi.effect.SHELL,   0, 100 },
        [3] = { xi.magic.spell.FLASH,      target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.FLASH,   0, 100 },
    }

    local groupTable = {}

    for offset = 0, 9 do
        local ally = GetMobByID(ID.mob.SW_FIR_BHOLG_OFFSET + offset)

        if
            ally and
            ally:getID() ~= mob:getID()
        then
            table.insert(groupTable, ally)
        end
    end

    return xi.combat.behavior.chooseAction(mob, target, groupTable, spellList)
end

return entity
