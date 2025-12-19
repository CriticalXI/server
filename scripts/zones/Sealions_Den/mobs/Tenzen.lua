-----------------------------------
-- Area: Sealion's Den
--  Mob: Tenzen
-----------------------------------
local ID = zones[xi.zone.SEALIONS_DEN]
mixins   = { require('scripts/mixins/job_special') }
-----------------------------------
---@type TMobEntity
local entity = {}

local forms =
{
    SHEATHED = 3,
    MELEE    = 4,
    BOW_LOW  = 5,
    BOW_HIGH = 6,
}

local bowPhases =
{
    NONE  = 0,
    START = 1,
    FAST  = 2,
    SLOW  = 3,
}

local formTable =
{
    [forms.SHEATHED] = { skill = 0,    standback = xi.behavior.NONE      },
    [forms.MELEE   ] = { skill = 0,    standback = xi.behavior.NONE      },
    [forms.BOW_LOW ] = { skill = 1400, standback = xi.behavior.STANDBACK },
    [forms.BOW_HIGH] = { skill = 1398, standback = xi.behavior.STANDBACK },
}

local bowSequence =
{
    [bowPhases.START] = { form = forms.BOW_LOW,  shotDelay = 4, minShots = 1, maxShots = 2,  nextPhase = 2 },
    [bowPhases.FAST ] = { form = forms.BOW_HIGH, shotDelay = 2, minShots = 5, maxShots = 10, nextPhase = 3 },
    [bowPhases.SLOW ] = { form = forms.BOW_LOW,  shotDelay = 4, minShots = 1, maxShots = 5,  nextPhase = 0 },
}

local normalMeikyo =
{
    [0] = { xi.mobSkill.AMATSU_YUKIARASHI },
    [1] = { xi.mobSkill.AMATSU_TSUKIOBORO },
    [2] = { xi.mobSkill.AMATSU_HANAIKUSA },
}

local enrageMeikyo =
{
    [0] = { xi.mobSkill.AMATSU_HANAIKUSA   },
    [1] = { xi.mobSkill.AMATSU_TORIMAI     },
    [2] = { xi.mobSkill.AMATSU_KAZAKIRI    },
    [3] = { xi.mobSkill.AMATSU_TSUKIKAGE   },
    [4] = { xi.mobSkill.COSMIC_ELUCIDATION },
}

local taruOffsets =
{
    [ID.mob.MAKKI_CHEBUKKI] = ID.text.MAKKI_CHEBUKKI_OFFSET,
    [ID.mob.KUKKI_CHEBUKKI] = ID.text.KUKKI_CHEBUKKI_OFFSET,
    [ID.mob.CHERUKIKI     ] = ID.text.CHERUKIKI_OFFSET,
}

local function setupForm(mob, newForm)
    mob:setAnimationSub(newForm)
    mob:setBehavior(formTable[newForm].standback)

    -- Pause for animation change before enabling auto attacks
    if newForm == forms.MELEE then
        mob:timer(1500, function(mobArg)
            mobArg:setAutoAttackEnabled(true)
            mobArg:setMobAbilityEnabled(true)
        end)
    end
end

-- Setup bow phase handling
local function setupBowPhase(mob, phase)
    local config      = bowSequence[phase]
    local currentTime = GetSystemTime()

    setupForm(mob, config.form)

    mob:setMobAbilityEnabled(false)

    mob:setLocalVar('[Tenzen]BowPhase', phase)
    mob:setLocalVar('[Tenzen]ShotTimer', currentTime + config.shotDelay)
    mob:setLocalVar('[Tenzen]ShotCount', 0)
    mob:setLocalVar('[Tenzen]ShotAmount', math.random(config.minShots, config.maxShots))
end

local function wsSequence(mob)
    local step       = mob:getLocalVar('[Tenzen]MeikyoStep')
    local enrage     = mob:getLocalVar('[Tenzen]Enrage')
    local skillchain = enrage == 1 and enrageMeikyo or normalMeikyo
    local maxSteps   = enrage == 1 and 4 or 2

    if step <= maxSteps then
        mob:setTP(1000)
        mob:useMobAbility(skillchain[step][1])
        mob:setLocalVar('[Tenzen]MeikyoStep', step + 1)
    else
        mob:setAutoAttackEnabled(true)
        mob:setMobAbilityEnabled(true)
        mob:setLocalVar('[Tenzen]MeikyoActive', 0)
        mob:setLocalVar('[Tenzen]MeikyoStep', 0)
    end
end

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:addImmunity(xi.immunity.TERROR)
end

entity.onMobSpawn = function(mob)
    mob:setMod(xi.mod.DEF, 350)
    mob:setMod(xi.mod.REGAIN, 30)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
    mob:setMobMod(xi.mobMod.SIGHT_RANGE, 10)
    mob:setUnkillable(true)

    -- Setup melee form.
    setupForm(mob, forms.MELEE)

    -- Reset local vars.
    mob:resetLocalVars()

    xi.mix.jobSpecial.config(mob,
        {
            specials =
            {
                { id = xi.jsa.MEIKYO_SHISUI, hpp = math.random(30, 80) },
            },
        })
end

entity.onMobEngage = function(mob, target)
    mob:showText(mob, ID.text.TENZEN_MSG_OFFSET) -- Engage message

    local currentTime = GetSystemTime()
    mob:setLocalVar('[Tenzen]ShiftTimer', currentTime + 40)
    mob:setLocalVar('[Tenzen]RiceBallTimer', currentTime + math.random(90, 120))

    -- Update Taru helpers enmity.
    local mobId = mob:getID()
    for taruId = mobId + 1, mobId + 3 do
        GetMobByID(taruId):updateEnmity(target)
    end
end

entity.onMobMobskillChoose = function(mob, target)
    local form = mob:getAnimationSub()

    if form == forms.MELEE then
        local tpList =
        {
            xi.mobSkill.AMATSU_HANAIKUSA,
            xi.mobSkill.AMATSU_TSUKIKAGE,
            xi.mobSkill.AMATSU_TORIMAI,
            xi.mobSkill.AMATSU_KAZAKIRI,
            xi.mobSkill.AMATSU_YUKIARASHI,
            xi.mobSkill.AMATSU_TSUKIOBORO,
        }

        return tpList[math.random(1, #tpList)]
    elseif form == forms.BOW_HIGH or form == forms.BOW_LOW then
        return xi.mobSkill.OISOYA
    end
end

entity.onMobWeaponSkill = function(target, mob, skill)
    local skillId = skill:getID()

    -- Track last time Tenzen did a mobskill. Dont Meikyo Shisui immediately after.
    mob:setLocalVar('[Tenzen]LastWeaponskill', GetSystemTime() + 5)

    -- Increment shot count for bow attacks.
    if
        skillId == xi.mobSkill.RANGED_ATTACK_TENZEN_1 or
        skillId == xi.mobSkill.RANGED_ATTACK_TENZEN_2
    then
        mob:setLocalVar('[Tenzen]ShotCount', mob:getLocalVar('[Tenzen]ShotCount') + 1)
    end

    -- Setup weaponskill chain.
    if skillId == xi.mobSkill.MEIKYO_SHISUI_1 then
        mob:setAutoAttackEnabled(false)
        mob:setMobAbilityEnabled(false)

        mob:setLocalVar('[Tenzen]MeikyoActive', 1)
        mob:setLocalVar('[Tenzen]MeikyoStep', 0)
        mob:setLocalVar('[Tenzen]ShiftTimer', GetSystemTime() + math.random(25, 70))
        setupForm(mob, forms.MELEE)
        wsSequence(mob)

        return

    -- Lose battle.
    elseif skillId == xi.mobSkill.COSMIC_ELUCIDATION then
        mob:timer(2000, function(mobArg)
            mobArg:setAnimationSub(3)
            mobArg:showText(mobArg, ID.text.TENZEN_MSG_OFFSET + 1)
            mobArg:getBattlefield():lose()
        end)

        return
    end

    -- Continue weaponskill chain.
    if mob:getLocalVar('[Tenzen]MeikyoActive') == 1 then
        wsSequence(mob)
    end
end

entity.onMobFight = function(mob, target)
    local mobHPP = mob:getHPP()

    -- Win battle.
    if mobHPP <= 15 then
        mob:setAnimationSub(forms.SHEATHED)
        mob:showText(mob, ID.text.TENZEN_MSG_OFFSET + 2)

        local mobId = mob:getID()
        for taruId = mobId + 1, mobId + 3 do
            local taruMob = GetMobByID(taruId)
            local offset  = taruOffsets[taruId]
            if taruMob then
                taruMob:showText(taruMob, offset + 5)
            end
        end

        mob:timer(2000, function(mobArg)
            mobArg:getBattlefield():win()
        end)

        return
    end

    -- Enhance regain.
    if mobHPP <= 35 then
        mob:setMod(xi.mod.REGAIN, 70)
    end

    -- If mob is busy or otherwise unable to perform actions.
    if xi.combat.behavior.isEntityBusy(mob) then
        return
    end

    -- 5 min since engage, start enrage weaponskill chain
    if
        mob:getBattleTime() >= 300 and
        mob:getLocalVar('[Tenzen]Enrage') == 0 and
        mob:getLocalVar('[Tenzen]LastWeaponskill') < GetSystemTime()
    then
        mob:setLocalVar('[Tenzen]Enrage', 1)
        mob:useMobAbility(xi.mobSkill.MEIKYO_SHISUI_1)

        return
    end

    local currentTime = GetSystemTime()
    local form        = mob:getAnimationSub()

    -- Melee form: wait for shift timer then begin bow sequence.
    if form == forms.MELEE then
        -- Rice ball
        local riceballTimer = mob:getLocalVar('[Tenzen]RiceBallTimer')
        if
            riceballTimer > 0 and
            currentTime >= riceballTimer
        then
            mob:useMobAbility(xi.mobSkill.RICEBALL_TENZEN)
            mob:setLocalVar('[Tenzen]RiceBallTimer', 0)
            mob:messageText(mob, ID.text.TENZEN_MSG_OFFSET + 3, false)

            return
        end

        if currentTime >= mob:getLocalVar('[Tenzen]ShiftTimer') then
            mob:setAutoAttackEnabled(false)
            setupBowPhase(mob, bowPhases.START)
        end

        return
    end

    -- Bow forms: fire shots and handle transitions.
    if form == forms.BOW_LOW or form == forms.BOW_HIGH then
        local phase      = mob:getLocalVar('[Tenzen]BowPhase')
        local shotCount  = mob:getLocalVar('[Tenzen]ShotCount')
        local shotAmount = mob:getLocalVar('[Tenzen]ShotAmount')
        local shotTimer  = mob:getLocalVar('[Tenzen]ShotTimer')

        -- Fire shot if timer elapsed and shots remaining.
        if shotCount < shotAmount and currentTime >= shotTimer then
            mob:setLocalVar('[Tenzen]ShotTimer', currentTime + bowSequence[phase].shotDelay)
            mob:useMobAbility(formTable[form].skill)

            return
        end

        -- All shots fired, transition to next phase.
        if shotCount >= shotAmount then
            local phaseConfig = bowSequence[phase]

            -- Return to melee
            if not phaseConfig or phaseConfig.nextPhase == 0 then
                mob:setLocalVar('[Tenzen]ShiftTimer', currentTime + math.random(25, 70))
                mob:setLocalVar('[Tenzen]ShotCount', 0)
                mob:setLocalVar('[Tenzen]BowPhase', 0)
                setupForm(mob, forms.MELEE)

                return
            end

            -- Transition to next bow phase.
            -- Early skill enable during transition to allow Oisoya.
            mob:setMobAbilityEnabled(true)
            mob:timer(1500, function(mobArg)
                setupBowPhase(mobArg, phaseConfig.nextPhase)
            end)
        end
    end
end

return entity
