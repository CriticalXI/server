-----------------------------------
-- Fishing Logic
-----------------------------------
require('scripts/globals/hobbies/fishing/chart')
require('scripts/globals/hobbies/fishing/data')
-----------------------------------
xi = xi or {}
xi.fishing = xi.fishing or {}
-----------------------------------

xi.fishing.casts = {}

---@return TFishingData
xi.fishing.getData = function()
    if not xi.fishing.data then
        xi.fishing.data = GetFishingData()
    end

    return xi.fishing.data
end

-----------------------------------
-- Meters
--
-- Daily fish cap is controlled by two server settings: xi.settings.map.FISHING_DAILY_CAP and xi.settings.map.FISHING_FATIGUE_CAP.
-- Disable fatigue entirely with xi.settings.map.FISHING_FATIGUE_ENABLE.
-----------------------------------

xi.fishing.updateMeters = function(player, meters)
    -- Total midnights worth of fatigue to reset
    local resetDays = math.ceil(meters.fatigue / 16000)

    -- The pool sheds 16000 at each midnight, so this is the one it runs out on
    local nextMidnight = JstMidnight()
    local lastMidnight = nextMidnight + 86400 * math.max(0, resetDays - 1)

    -- Player may increase fatigue without increasing daily points. Set Today var to track for fatigue resets
    player:setCharVar('[Fish]DailyPoints', meters.daily, nextMidnight)
    player:setCharVar('[Fish]Today', 1, nextMidnight)
    player:setCharVar('[Fish]Fatigue', meters.fatigue, lastMidnight)
end

-- The event a fatigue class costs as
local function classFatigueEvent(class)
    if class == xi.fishing.fatigueClass.VALUABLE then
        return xi.fishing.fatigueEvent.VALUABLE_ITEM
    elseif class == xi.fishing.fatigueClass.JUNK then
        return xi.fishing.fatigueEvent.JUNK_ITEM
    end

    return xi.fishing.fatigueEvent.COUNTABLE_ITEM
end

xi.fishing.currentMeters = function(player)
    local daily   = player:getCharVar('[Fish]DailyPoints')
    local fatigue = player:getCharVar('[Fish]Fatigue')
    local today   = player:getCharVar('[Fish]Today')
    local meters  = { daily = daily, fatigue = fatigue, today = today }

    -- Current day, return current values
    if today == 1 then
        return meters
    end

    -- New day, reduce fatigue by up to 80% of total maximum fatigue
    meters.fatigue = math.max(0, meters.fatigue - 16000)

    return meters
end

xi.fishing.catchFatigueEvent = function(cast)
    local catch = cast.catch

    -- A fish costs by its legendary tier, else by its size
    if catch.type == xi.fishing.catchType.FISH then
        if catch.record.legendary == xi.fishingLegendaryTier.SUPER then
            return xi.fishing.fatigueEvent.SUPER_LEGENDARY
        elseif catch.record.legendary == xi.fishingLegendaryTier.BASIC then
            return xi.fishing.fatigueEvent.BASIC_LEGENDARY
        elseif catch.record.size == xi.fishingSize.LARGE then
            return xi.fishing.fatigueEvent.LARGE_FISH
        end

        return xi.fishing.fatigueEvent.SMALL_FISH
    end

    -- An item costs by its fatigue class, countable unless its row says otherwise
    if catch.type == xi.fishing.catchType.ITEM then
        local stats = xi.fishing.catchStats[catch.itemId]

        return classFatigueEvent(catch.record.fatigue or (stats and stats.fatigue))
    end

    -- A monster costs only where the notes name it
    if catch.type == xi.fishing.catchType.MONSTER then
        local monster = xi.fishing.monsters[catch.mob:getName()]
        if
            monster and
            monster.fatigue
        then
            return classFatigueEvent(monster.fatigue)
        end
    end

    return xi.fishing.fatigueEvent.EMPTY_CAST
end

xi.fishing.accrueFatigue = function(player, cast, event, overLevel)
    if not xi.settings.map.FISHING_FATIGUE_ENABLE then
        return
    end

    local cost    = xi.fishing.fatigueCosts[event]
    local daily   = cost.daily
    local fatigue = overLevel and cost.overLevel or cost.fatigue

    -- A legendary rod tires the angler by its own percent
    local rod = xi.fishing.rodStats[cast.rodId]
    if
        rod and
        rod.fatigue
    then
        fatigue = math.floor(fatigue * rod.fatigue / 100)
    end

    -- Check if player has any job at or above FISHING_MIN_LEVEL, if not, apply a penalty to fatigue
    local lowLevel = true
    for job = xi.job.WAR, xi.job.RUN do
        if player:getJobLevel(job) >= xi.settings.map.FISHING_MIN_LEVEL then
            lowLevel = false
            break
        end
    end

    if lowLevel then
        fatigue = fatigue * 20
    end

    local meters   = xi.fishing.currentMeters(player)
    meters.daily   = math.min(xi.settings.map.FISHING_DAILY_CAP, meters.daily + daily)
    meters.fatigue = math.min(xi.settings.map.FISHING_FATIGUE_CAP, meters.fatigue + fatigue)

    xi.fishing.updateMeters(player, meters)
end

-- Check meters, reject catching anything if either cap is reached
xi.fishing.mayBite = function(player)
    if not xi.settings.map.FISHING_FATIGUE_ENABLE then
        return true
    end

    local meters = xi.fishing.currentMeters(player)

    return meters.daily < xi.settings.map.FISHING_DAILY_CAP and meters.fatigue < xi.settings.map.FISHING_FATIGUE_CAP
end

-----------------------------------
-- Fishing Start
-----------------------------------

-- Check if the player is standing in a shaped fishing area.
local function confirmArea(player, area)
    if
        area.cylinder and
        player:isInsideCylinder(area.cylinder.x, area.cylinder.z, area.cylinder.radius)
    then
        return true
    end

    if
        area.poly and
        player:isInsidePoly(area.poly)
    then
        return true
    end

    return false
end

-- The leg a transport is on, named as its fishing areas are; nil anywhere else.
local function transportLeg(zoneId)
    if zoneId == xi.zone.MANACLIPPER then
        return xi.manaclipper.currentRoute()
    elseif zoneId == xi.zone.PHANAUET_CHANNEL then
        return xi.barge.currentRoute()
    end

    return nil
end

-- Find the fishing area the player is currently in: the transport's leg, then a shape, then the unshaped fallback.
local function findArea(player, zone)
    if not zone then
        return nil
    end

    -- A transport fishes the area named after the leg it is on
    local leg = transportLeg(player:getZoneID())
    if
        leg and
        zone.areas[leg]
    then
        return leg, zone.areas[leg]
    end

    local names = {}
    for name in pairs(zone.areas) do
        table.insert(names, name)
    end

    table.sort(names)

    local fallback = nil
    for _, name in ipairs(names) do
        local area = zone.areas[name]

        if
            not area.cylinder and
            not area.poly
        then
            if not fallback or name == 'whole_zone' then
                fallback = name
            end
        elseif confirmArea(player, area) then
            return name, area
        end
    end

    if fallback then
        return fallback, zone.areas[fallback]
    end

    return nil
end

-- Time passed to client for how long to wait for a bite
local function hookTime(player)
    local wait = 13
    local moon = getVanadielMoonCycle()
    local hour = VanadielHour()

    if
        moon == xi.moonCycle.NEW_MOON or
        moon == xi.moonCycle.FULL_MOON
    then
        wait = wait - 4
    end

    if
        hour == 5 or
        hour == 17
    then
        wait = wait - 1
    end

    if player:hasEquipped(xi.item.FISHERS_ROPE) then
        wait = wait - 1
    end

    return math.max(7, wait)
end

local function checkEntry(player, data)
    -- Trying to cast drops invisible
    player:delStatusEffectsByFlag(xi.effectFlag.INVISIBLE)

    local base           = zones[player:getZoneID()].text.FISHING_MESSAGE_OFFSET
    local areaName, area = findArea(player, data.zones[player:getZoneID()])

    -- A zone with no fishing text has no line for the cast it refuses
    if not area then
        if base then
            player:messageText(player, base + xi.fishingMessage.CANNOT_FISH_HERE)
        end

        return nil
    end

    if player:getAnimation() ~= xi.animation.NONE then
        player:messageText(player, base + xi.fishingMessage.CANNOT_FISH_MOMENT)
        player:messageSystem(xi.msg.system.CANNOT_USE_COMMAND_NOW)
        return nil
    end

    if not data.rods[player:getEquipID(xi.slot.RANGED)] then
        player:messageText(player, base + xi.fishingMessage.NO_ROD)
        return nil
    end

    if not data.baits[player:getEquipID(xi.slot.AMMO)] then
        player:messageText(player, base + xi.fishingMessage.NO_BAIT)
        return nil
    end

    return areaName, area
end

-- Build the cast and store it in the live casts table
local function castLine(player, data, areaName, area)
    local rodId  = player:getEquipID(xi.slot.RANGED)
    local baitId = player:getEquipID(xi.slot.AMMO)
    local cast   =
    {
        zone     = data.zones[player:getZoneID()],
        areaName = areaName,
        area     = area,
        rodId    = rodId,
        rod      = data.rods[rodId],
        baitId   = baitId,
        bait     = data.baits[baitId],
        hookTime = hookTime(player),
    }

    cast.stage     = xi.fishing.stage.CAST
    cast.startedAt = GetSystemTime()
    xi.fishing.casts[player:getID()] = cast

    player:setAnimation(xi.animation.NEW_FISHING_START)
    player:setCharVar('[Fish]LastCastTime', cast.startedAt)

    -- Katsunaga counts every cast; the count reaches the database with the next persist sweep rather than a query per cast
    player:setVolatileCharVar('[Fish]Casts', player:getCharVar('[Fish]Casts') + 1)

    return cast.hookTime
end

-----------------------------------
-- Fish / Monster / Item / Chest Selection
-----------------------------------

local function confirmFishEntry(player, cast, itemId, fish)
    -- Fish must not be an item
    if fish.item then
        return false
    end

    -- Fish must be attracted to the bait
    if not cast.bait.affinity[itemId] then
        return false
    end

    -- Check if player has a key item related to the fish
    if fish.keyItem and not player:hasKeyItem(fish.keyItem) then
        return false
    end

    -- If the fish requires a quest, check if player is properly on it
    if
        fish.quest and
        player:getQuestStatus(fish.quest.log, fish.quest.id) ~= xi.questStatus.QUEST_ACCEPTED
    then
        return false
    end

    return true
end

-- Obtain fish entries from the pool that bite, at a flat weight each.
-- TODO: Retail captures to prove out weights of the fish entries per area.
local function fishEntries(player, cast, area, data)
    local entries   = {}
    local preferred = xi.fishing.preferredCatches[cast.baitId] or {}
    local skill     = math.floor(player:getCharSkillLevel(xi.skill.FISHING) / 10) + player:getMod(xi.mod.FISH)

    for _, itemId in ipairs(area.pool) do
        if confirmFishEntry(player, cast, itemId, data.fish[itemId]) then
            local weight = 100

            -- From skill 20 a fish that prefers the bait bites over the rest of the pool
            if
                skill >= 20 and
                utils.contains(itemId, preferred)
            then
                weight = 200 -- Capture needed: the size of the preference
            end

            table.insert(entries, { itemId, weight })
        end
    end

    return entries
end

local function confirmItemEntry(player, itemId, item)
    -- Item must be a fish item
    if not item.item then
        return false
    end

    -- Check if player has a key item related to the item
    if item.keyItem and not player:hasKeyItem(item.keyItem) then
        return false
    end

    -- If the item requires a quest, check if player is properly on it
    if
        item.quest and
        player:getQuestStatus(item.quest.log, item.quest.id) ~= xi.questStatus.QUEST_ACCEPTED
    then
        return false
    end

    return true
end

local function itemEntries(player, area, data)
    local entries = {}
    local bonus   = 0
    for _, itemId in ipairs(area.pool) do
        local item = data.fish[itemId]
        if confirmItemEntry(player, itemId, item) then
            table.insert(entries, { itemId, 100 })
            if item.quest then
                bonus = bonus + 1000
            end
        end
    end

    return entries, bonus
end

xi.fishing.confirmMonsterEntry = function(player, record, monster)
    if not monster then
        return false
    end

    -- Monster must not be spawned
    if monster:isSpawned() then
        return false
    end

    -- Monster must not be already on a player's reel
    if monster:getLocalVar('hooked') ~= 0 then
        return false
    end

    -- Monster must have served its cooldown since it last left the world
    if monster:getLocalVar('respawnAt') > GetSystemTime() then
        return false
    end

    -- If the monster requires a quest, check if player is properly on it
    if
        record.quest and
        player:getQuestStatus(record.quest.log, record.quest.id) ~= xi.questStatus.QUEST_ACCEPTED
    then
        return false
    end

    return true
end

local function monsterEntries(player, cast, areaName)
    local entries = {}
    local bonus   = 0
    for spawnId, record in pairs(cast.zone.monsters) do
        if
            (not record.area or record.area == areaName) and
            (not record.bait or record.bait[cast.baitId]) and
            xi.fishing.confirmMonsterEntry(player, record, GetMobByID(spawnId))
        then
            table.insert(entries, { spawnId, 100 })
            if record.quest then
                bonus = bonus + 1000
            end
        end
    end

    return entries, bonus
end

local function legendaryRodBonus(skill, fish, rodId)
    local rod = xi.fishing.rodStats[rodId]
    if
        not rod or
        not rod.pullStart
    then
        return 0
    end

    if skill <= fish.skill + 7 then
        return 0
    end

    local gap         = skill - fish.skill
    local sizeDivisor = fish.size == xi.fishingSize.LARGE and 2 or 1

    return rod.pullStart + math.floor(gap * (1 + math.floor(gap / rod.pullDivisor)) / sizeDivisor)
end

-- Select an entry from a weighted list of values
-- Used to select which pool to draw from, and subsequently which item/fish to draw from that pool
local function chooseWeightedEntry(entries)
    local total = 0
    for _, entry in ipairs(entries) do
        total = total + entry[2]
    end

    if total == 0 then
        return nil
    end

    local roll = math.randomInt(1, total)
    local sum  = 0
    for _, entry in ipairs(entries) do
        sum = sum + entry[2]
        if roll <= sum then
            return entry[1]
        end
    end

    return nil
end

-----------------------------------
-- Bite roll
-----------------------------------

-- TODO: Capture to confirm this logic
local function weatherFactor(player)
    local weather = player:getWeather()
    if weather == xi.weather.RAIN then
        return 1.1
    elseif weather == xi.weather.SQUALL then
        return 1.2
    end

    return 1
end

-- Craft the weights for fish / items / monster in the available pool to draw from
-- TODO: Prove out the effect of the moon on the weights of each bucket
local function setupWeights(player, cast, data, entries, itemBonus, monsterBonus)
    local phase   = xi.fishing.moonCurves[getVanadielMoonCycle()]
    local weights = {}

    -- The moon's weight on each bucket by phase: a cosine clamped to 0 to 1, and a step for monsters
    local fishMoon    = utils.clamp(0.5 * math.cos(0.90 * phase + math.pi) + 0.5, 0, 1)
    local itemMoon    = utils.clamp(0.5 * math.cos(1.75 * phase + 3.30) + 0.5, 0, 1)
    local monsterMoon = 1 - math.floor(phase / 7)
    local nothingMoon = utils.clamp(0.5 * math.cos(0.90 * phase) + 0.5, 0, 1)

    if bit.band(player:getZone():getTypeMask(), xi.zoneType.CITY) ~= 0 then
        weights[xi.fishing.catchType.FISH   ] = math.floor(15 * fishMoon)
        weights[xi.fishing.catchType.ITEM   ] = 25 + math.floor(20 * itemMoon)
        weights[xi.fishing.catchType.MONSTER] = 0
        weights[xi.fishing.catchType.NOTHING] = 30 + math.floor(15 * nothingMoon)
    else
        weights[xi.fishing.catchType.FISH   ] = math.floor(25 * fishMoon)
        weights[xi.fishing.catchType.ITEM   ] = 10 + math.floor(15 * itemMoon)
        weights[xi.fishing.catchType.MONSTER] = 15 + math.floor(15 * monsterMoon)
        weights[xi.fishing.catchType.NOTHING] = 15 + math.floor(20 * nothingMoon)
    end

    weights[xi.fishing.catchType.CHEST  ] = 0
    weights[xi.fishing.catchType.ITEM   ] = weights[xi.fishing.catchType.ITEM   ] + itemBonus
    weights[xi.fishing.catchType.MONSTER] = weights[xi.fishing.catchType.MONSTER] + monsterBonus

    -- Any fish that can bite fills the bucket to its 120 cap; the moon moves it only when none can, and then half of it goes to no
    -- catch below. The weather scales it either way.
    if #entries[xi.fishing.catchType.FISH] > 0 then
        weights[xi.fishing.catchType.FISH] = 120
    end

    weights[xi.fishing.catchType.FISH] = math.floor(weights[xi.fishing.catchType.FISH] * weatherFactor(player))

    -- The fish that would bite is drawn now, since a legendary rod's pull on it raises the fish bucket before the bucket is picked.
    local fishId = chooseWeightedEntry(entries[xi.fishing.catchType.FISH])
    if fishId then
        local skill = math.floor(player:getCharSkillLevel(xi.skill.FISHING) / 10) + player:getMod(xi.mod.FISH)
        local bonus = legendaryRodBonus(skill, data.fish[fishId], cast.rodId)

        weights[xi.fishing.catchType.FISH] = weights[xi.fishing.catchType.FISH] + bonus
    end

    -- The Moghancement: Fishing Item draws items about as often as fish
    if player:hasKeyItem(xi.ki.MOGHANCEMENT_FISHING_ITEMS) then
        weights[xi.fishing.catchType.ITEM] = math.max(weights[xi.fishing.catchType.ITEM], weights[xi.fishing.catchType.FISH])
    end

    if
        player:hasEquipped(xi.item.FISHERMANS_APRON) or
        player:hasEquipped(xi.item.FISHERMANS_SMOCK)
    then
        local cut = math.floor(weights[xi.fishing.catchType.ITEM] / 4)

        weights[xi.fishing.catchType.ITEM   ] = weights[xi.fishing.catchType.ITEM   ] - cut
        weights[xi.fishing.catchType.NOTHING] = weights[xi.fishing.catchType.NOTHING] + cut
    end

    local hour = VanadielHour()
    if
        hour == 5 or
        hour == 17
    then
        weights[xi.fishing.catchType.NOTHING] = math.floor(weights[xi.fishing.catchType.NOTHING] / 2)
    end

    for _, catchType in ipairs(xi.fishing.entryBuckets) do
        if #entries[catchType] == 0 then
            weights[xi.fishing.catchType.NOTHING] = weights[xi.fishing.catchType.NOTHING] + math.floor(weights[catchType] / 2)
            weights[catchType]                    = 0
        end
    end

    return weights, fishId
end

-- Choose which pool to draw from, then choose an item/fish/monster/chest from that pool
local function chooseOutcome(cast, data, buckets)
    local bucketList = {}
    for catchType, weight in pairs(buckets.weights) do
        table.insert(bucketList, { catchType, weight })
    end

    -- Choose which bucket to draw from
    local catchType = chooseWeightedEntry(bucketList)

    -- Choose an entry from the selected bucket and return the result
    if catchType == xi.fishing.catchType.FISH then
        local fishId = buckets.fishId
        if not fishId then
            return nil
        end

        local fish  = data.fish[fishId]
        local count = 1
        if
            (fish.maxHook or 1) > 1 and
            (cast.bait.maxHook or 1) > 1
        then
            count = math.randomInt(1, cast.bait.maxHook)
        end

        return { type = catchType, itemId = fishId, record = fish, count = count }
    end

    if catchType == xi.fishing.catchType.ITEM then
        local itemId = chooseWeightedEntry(buckets.entries[catchType])
        if not itemId then
            return nil
        end

        return { type = catchType, itemId = itemId, record = data.fish[itemId] }
    end

    if catchType == xi.fishing.catchType.MONSTER then
        local spawnId = chooseWeightedEntry(buckets.entries[catchType])
        if not spawnId then
            return nil
        end

        return { type = catchType, spawnId = spawnId, mob = GetMobByID(spawnId), record = cast.zone.monsters[spawnId] }
    end

    if catchType == xi.fishing.catchType.CHEST then
        local npcId = chooseWeightedEntry(buckets.entries[catchType])
        if not npcId then
            return nil
        end

        return { type = catchType, npcId = npcId, npc = GetNPCByID(npcId) }
    end

    return nil
end

xi.fishing.biteBuckets = function(player, cast, data)
    -- A chart quest in progress fishes its own area in place of the one the cast opened on
    local chartArea = xi.fishing.chart.activeArea(player)
    local area      = chartArea and cast.zone.areas[chartArea] or cast.area

    -- Generate available pools of items, monsters, and fish
    local entries                         = {}
    local fish                            = fishEntries(player, cast, area, data)
    local items, itemBonus                = itemEntries(player, area, data)
    local monsters, monsterBonus          = monsterEntries(player, cast, cast.areaName)

    -- Populate entry list from the generated pools
    entries[xi.fishing.catchType.CHEST  ] = {}
    entries[xi.fishing.catchType.FISH   ] = fish
    entries[xi.fishing.catchType.ITEM   ] = items
    entries[xi.fishing.catchType.MONSTER] = monsters

    -- Calculate the weights for each catch type based on the entries and bonuses
    local weights = nil
    local fishId  = nil
    if chartArea then
        weights = xi.fishing.chart.weights(player, cast, chartArea, entries)
    else
        weights, fishId = setupWeights(player, cast, data, entries, itemBonus, monsterBonus)
    end

    -- Can anything bite? If no catch bucket carries weight, force a certain empty cast so the roll cannot land an empty bucket.
    local canBite = false
    for catchType, weight in pairs(weights) do
        if
            catchType ~= xi.fishing.catchType.NOTHING and
            weight > 0
        then
            canBite = true
            break
        end
    end

    if not canBite then
        weights[xi.fishing.catchType.NOTHING] = 1000
    end

    return { weights = weights, entries = entries, fishId = fishId }
end

xi.fishing.rollBite = function(player, cast, data)
    -- A spent daily budget or a full fatigue pool ends the roll before it starts, fish, items and monsters alike.
    if not xi.fishing.mayBite(player) then
        return nil
    end

    return chooseOutcome(cast, data, xi.fishing.biteBuckets(player, cast, data))
end

-----------------------------------
-- Minigame
-----------------------------------

-- What the fight is built from: the angler's skill and rod against the catch's level, size, legendary tier and stats.
local function fightContext(player, cast, catch)
    local rod = xi.fishing.rodStats[cast.rodId]
    if not rod then
        return nil
    end

    local context =
    {
        skill = math.floor(player:getCharSkillLevel(xi.skill.FISHING) / 10) + player:getMod(xi.mod.FISH),
        count = catch.count or 1,
        rod   = rod,
    }

    if catch.type == xi.fishing.catchType.MONSTER then
        context.level = catch.mob:getMainLvl()
        context.size  = xi.fishingSize.LARGE
        context.stats = xi.fishing.monsterFightStats[#xi.fishing.monsterFightStats]

        for _, stats in ipairs(xi.fishing.monsterFightStats) do
            if context.level <= stats.level then
                context.stats = stats
                break
            end
        end
    elseif catch.type == xi.fishing.catchType.CHEST then
        context.level = 1
        context.size  = xi.fishingSize.LARGE
        context.stats = xi.fishing.chart.chestFightStats
    else
        local stats = xi.fishing.catchStats[catch.itemId]
        if not stats then
            return nil
        end

        context.level = catch.record.skill
        context.size  = catch.record.size
        context.tier  = catch.record.legendary
        context.stats = stats
    end

    return context
end

local function stamina(context, catch, roll)
    -- A chest has no level, so it fights as a level -14 catch and starts at 1100
    local level = -14
    if catch.type ~= xi.fishing.catchType.CHEST then
        level = context.level
    end

    -- Every catch starts from 1800 and gains 50 a level, the level taken in pairs
    local base = 18 + math.floor(level / 2)

    -- A sabiki rig hooks up to three fish, each one past the first adding a tenth of the base
    base = base + math.floor(base * (context.count - 1) / 10)

    -- The roll spreads the stamina five percent either side of the base
    return base * roll
end

-- An arrow value the client reads from 1 to 15: the delay between arrows and how often the catch moves both take this shape.
local function arrowValue(player, context, base, smallBonus, largeBonus)
    -- A sabiki rig raises the catch's base a tenth per fish past the first, as it does the stamina
    local value = base + math.floor(base * (context.count - 1) / 10)

    -- The rod adds its bonus for the size of the catch
    if context.size == xi.fishingSize.SMALL then
        value = value + smallBonus
    else
        value = value + largeBonus
    end

    if player:getMod(xi.mod.PENGUIN_RING_EFFECT) > 0 then
        value = value + 2
    end

    return utils.clamp(value, 1, 15)
end

-- The stamina one arrow takes off the catch.
local function attack(context)
    -- The rod's attack percent, raised by its legendary bonus on a legendary catch
    local percent = context.rod.attack
    if context.tier then
        percent = percent + (context.rod.legendaryAttack or 0)
    end

    -- The catch's damage at attack 100, scaled by the rod's percent in the steps of 20 the client counts damage in
    return math.floor(context.stats.arrowDamage * percent / 2000) * 20
end

-- The stamina the catch heals back, sent as arrow_regen.
local function heal(context, damage, keen)
    -- The rod's recovery percent, raised by its legendary bonus on a legendary catch
    local percent = context.rod.recovery
    if context.tier then
        percent = percent + (context.rod.legendaryRecovery or 0)
    end

    -- The damage's steps of 20 at the rod's percent, in the steps of 10 the client counts healing in
    local value = math.floor(damage / 20 * percent / 100) * 10

    -- A keen angler's sense cuts the heal to seven tenths, in whole numbers because 0.7 is not exact
    if keen then
        value = math.floor(value * 7 / 10)
    end

    return value
end

-- The gauge the client fights against, sent at 128: under it the catch drains stamina, over it stamina comes back.
local function regen(cast, context, catch, roll)
    if catch.type == xi.fishing.catchType.CHEST then
        return 128 - math.floor((context.skill - 1) / 5)
    end

    -- A legendary catch holds a point over the bias whatever the gap, two on a super
    if context.tier then
        return 128 + (context.tier == xi.fishingLegendaryTier.SUPER and 2 or 1)
    end

    local gap = context.skill - context.level

    -- Under a fish by 28 or more the gauge rises 2, and 2 more every 12 levels beyond that
    if
        catch.type == xi.fishing.catchType.FISH and
        gap <= -28
    then
        return 128 + 2 + 2 * math.floor((-gap - 28) / 12)
    end

    local value = 128

    -- A legendary rod holds the gauge further over the catch and drains it on its own slope
    local start = context.rod.drainStart or 12
    local slope = context.rod.drainSlope or 1.3

    -- Over the catch by the rod's start the gauge drains at the rod's slope, no deeper than 86 on a fish or 98 on anything else
    if gap >= start then
        local floorAt = catch.type == xi.fishing.catchType.FISH and 86 or 98

        value = value - math.min(math.floor((gap - start) * slope), floorAt)

        -- The stamina roll moves the drain a point per point off 100, so a heavy catch drains harder
        value = value - (roll - 100)
    end

    -- A legendary rod holds a monster 3 under the bias
    if
        cast.rod.legendary and
        catch.type == xi.fishing.catchType.MONSTER
    then
        value = value - 3
    end

    return value
end

local function fightTime(player, cast, context)
    local time = cast.rod.time

    if context.rod.penalty == context.size then
        time = time - 10
    end

    if
        context.tier and
        cast.rod.legendary
    then
        time = time + (cast.rod.legendaryTime or 0)
    end

    time = time + (context.stats.timeBonus or 0)

    if
        player:hasKeyItem(xi.ki.MOOCHING) and
        (cast.baitId == xi.item.DRILL_CALAMARY or cast.baitId == xi.item.DWARF_PUGIL)
    then
        time = time + 30
    end

    if player:getMod(xi.mod.ALBATROSS_RING_EFFECT) > 0 then
        time = time + 30
    end

    return time
end

-- TODO: Capture needed to prove out when a fish reports an epic catch
local function bigFishStats(context, catch)
    local length = catch.record and catch.record.length
    if
        catch.type ~= xi.fishing.catchType.FISH or
        not length or
        length[2] <= 1
    then
        return nil
    end

    local ratio = (465 + math.randomInt(0, 50)) / 100
    local size  = math.floor((math.randomInt(length[1], length[2]) + math.randomInt(length[1], length[2])) / 2)

    return
    {
        length = size,
        weight = math.floor(size * ratio),
        epic   = context.tier and size > (length[1] + length[2]) / 2,
    }
end

-- The lose, snap and break chances a claim is rolled against, each with the failure it reports.
local function breakChances(cast, context, catch)
    local rod       = context.rod
    local legendary = cast.rod.legendary
    local chances   = { lose = 0, lineSnap = 0, rodBreak = 0 }

    -- A rod penalised against the catch's size loses it at the fish's own rate, or near twice its level where none is known
    local wrongSize = 0
    if rod.penalty == context.size then
        wrongSize = context.stats.sizeLoss or math.min(90, math.floor(context.level * 1.8))
    end

    -- Only a fish is lost to lack of skill: 0.8 a level past a grace of 7 over the angler, up to 25
    local lowSkill = 0
    if
        catch.type == xi.fishing.catchType.FISH and
        context.skill + 7 < context.level
    then
        lowSkill = math.min(25, math.floor((context.level - context.skill - 7) * 0.8))
    end

    -- The larger loss is the one the claim carries
    if wrongSize > lowSkill then
        chances.lose       = wrongSize
        chances.loseReason = context.size == xi.fishingSize.LARGE and xi.fishing.failure.LOST_BIG or xi.fishing.failure.LOST_SMALL
    elseif lowSkill > 0 then
        chances.lose       = lowSkill
        chances.loseReason = xi.fishing.failure.LOW_SKILL
    end

    local nearLevel = context.skill + 10 > context.level and 2 or 0

    -- The line holds an ordinary catch 6 ranks over the rod and snaps at 8.5 a rank past that
    local snapDurability = rod.maxRank + nearLevel + 6
    local snapSlope      = 8.5

    -- A legendary catch snaps from the first rank over at 17 a rank; a legendary rod holds it a rank more, a plain rod 3 less
    if context.tier then
        snapDurability = rod.maxRank + nearLevel + (legendary and 1 or -3)
        snapSlope      = 17
    end

    -- A catch that cuts any line carries its own rate, whatever the rod
    if context.stats.lineSnap then
        chances.lineSnap = context.stats.lineSnap
    elseif context.stats.rank > snapDurability then
        chances.lineSnap = math.min(55, math.floor((context.stats.rank - snapDurability) * snapSlope))
    end

    -- Only a rod with a broken form can break
    if cast.rod.breaksTo then
        local breakDurability = rod.maxRank + nearLevel
        local breakPenalty    = 0

        -- A legendary rod holds a large catch a rank more
        if
            legendary and
            context.size == xi.fishingSize.LARGE
        then
            breakDurability = breakDurability + 1
        end

        if not legendary then
            if context.tier then
                breakPenalty = 5
            elseif context.size > cast.rod.size then
                breakPenalty = 2
            end
        end

        if context.stats.rank > breakDurability then
            chances.rodBreak = math.min(55, math.floor((context.stats.rank - breakDurability + breakPenalty) * 1.3))
        end
    end

    return chances
end

local function feeling(context, chances, bigFish)
    -- A large fish measuring past its midpoint is epic before anything else
    if bigFish and bigFish.epic then
        return xi.fishing.feeling.EPIC
    end

    local gap = context.level - context.skill

    -- A catch 12 or more levels over always doubts the angler's skill, and half the hooks 8 to 11 over do
    if
        gap >= 12 or
        (gap >= 8 and math.randomInt(1, 100) <= 50)
    then
        -- The doubt is worded one way in three: 39 percent positive, 11 fairly sure, the rest not knowing, whatever the gap
        local roll = math.randomInt(1, 100)

        if roll <= 39 then
            return xi.fishing.feeling.NO_SKILL_POSITIVE
        elseif roll <= 50 then
            return xi.fishing.feeling.NO_SKILL_SURE
        end

        return xi.fishing.feeling.NO_SKILL
    end

    -- A snap or break chance of 45 or more feels terrible
    if
        chances.lineSnap >= 45 or
        chances.rodBreak >= 45
    then
        return xi.fishing.feeling.TERRIBLE
    end

    -- One hook in 25 up to 11 levels over feels bad on any rod
    if
        gap >= 1 and
        gap <= 11 and
        math.randomInt(1, 100) <= 4
    then
        return xi.fishing.feeling.BAD
    end

    return xi.fishing.feeling.GOOD
end

-- TODO: Capture needed to prove out keen sense rate
local function keenSense(context, catch, sense)
    -- Only a fish that already feels good can give it
    if
        sense ~= xi.fishing.feeling.GOOD or
        catch.type ~= xi.fishing.catchType.FISH
    then
        return false
    end

    -- The rod's keen bonus counts as skill, and the fish must be within 4 levels of that
    local skill = context.skill + (context.rod.keenBonus or 0)
    if context.level - 4 > skill then
        return false
    end

    -- 5 percent at the edge and 2 more per level of skill past it
    local chance = 5 + math.max(skill - math.max(0, context.level - 4), 0) * 2

    -- The waning crescent adds 20
    local moon = getVanadielMoonCycle()
    if
        moon == xi.moonCycle.GREATER_WANING_CRESCENT or
        moon == xi.moonCycle.LESSER_WANING_CRESCENT
    then
        chance = chance + 20
    end

    -- Never past 70
    return math.randomInt(1, 100) <= utils.clamp(chance, 0, 70)
end

local function intuition(context, keen)
    -- 10, and 2 more for every ten points of skill
    local value = 10 + 2 * math.floor(context.skill / 10)
    local moon  = getVanadielMoonCycle()
    local hour  = VanadielHour()

    -- A new or full moon adds 10, and 10 more on one hook in four; a quarter moon adds 10 on one in four and 5 on half
    if
        moon == xi.moonCycle.NEW_MOON or
        moon == xi.moonCycle.FULL_MOON
    then
        value = value + 10
        if math.randomInt(1, 100) <= 25 then
            value = value + 10
        end
    elseif
        moon == xi.moonCycle.FIRST_QUARTER or
        moon == xi.moonCycle.THIRD_QUARTER
    then
        local quarter = math.randomInt(1, 100)
        if quarter <= 25 then
            value = value + 10
        elseif quarter <= 75 then
            value = value + 5
        end
    end

    -- Dawn and dusk add 1 to 3
    if
        hour == 5 or
        hour == 17
    then
        value = value + math.randomInt(1, 3)
    end

    -- A keen sense adds 50
    if keen then
        value = value + 50
    end

    return value
end

local function buildFight(player, cast, catch)
    local context  = fightContext(player, cast, catch)
    if not context then
        return nil
    end

    local staminaRoll = math.randomInt(95, 105)
    local chances     = breakChances(cast, context, catch)
    local bigFish     = bigFishStats(context, catch)
    local sense       = feeling(context, chances, bigFish)
    local keen        = keenSense(context, catch, sense)
    local damage      = attack(context)
    local largeBite   = context.size == xi.fishingSize.LARGE and 1 or 0

    if keen then
        sense = xi.fishing.feeling.KEEN
    end

    return
    {
        stamina        = stamina(context, catch, staminaRoll),
        regen          = regen(cast, context, catch, staminaRoll),
        move_frequency = arrowValue(player, context, context.stats.moveFrequency, context.rod.smallMove, context.rod.largeMove),
        arrow_damage   = damage,
        arrow_delay    = arrowValue(player, context, context.stats.arrowDelay, context.rod.smallDelay, context.rod.largeDelay),
        arrow_regen    = heal(context, damage, keen),
        time           = fightTime(player, cast, context),
        angler_sense   = largeBite + (keen and 2 or 0),
        intuition      = intuition(context, keen),
        feeling        = sense,
        chances        = chances,
        bigFish        = bigFish,
        roll           = staminaRoll,
    }
end

xi.fishing.hookCatch = function(player, cast, catch)
    -- A monster not loaded, alive or visible cancels the cast
    if
        catch.type == xi.fishing.catchType.MONSTER and
        (not catch.mob or catch.mob:isAlive() or catch.mob:getStatus() ~= xi.status.DISAPPEAR)
    then
        return nil
    end

    local fight = buildFight(player, cast, catch)
    if not fight then
        return nil
    end

    -- The monster is marked hooked only once the fight is real, so no one else can fish it up while it is on the line
    if catch.type == xi.fishing.catchType.MONSTER then
        catch.mob:setLocalVar('hooked', 1)
    end

    -- The hook line by class, a chest hooked as an item
    local hookLine = xi.fishingMessage.HOOKED_ITEM
    local large    = catch.type ~= xi.fishing.catchType.ITEM

    if catch.type == xi.fishing.catchType.MONSTER then
        hookLine = xi.fishingMessage.HOOKED_MONSTER
    elseif catch.type == xi.fishing.catchType.FISH then
        large    = catch.record.size == xi.fishingSize.LARGE
        hookLine = large and xi.fishingMessage.HOOKED_LARGE_FISH or xi.fishingMessage.HOOKED_SMALL_FISH
    end

    local base = zones[player:getZoneID()].text.FISHING_MESSAGE_OFFSET

    player:messageText(player, base + hookLine)

    -- A keen angler's sense names the fish in place of the feeling
    if fight.feeling == xi.fishing.feeling.KEEN then
        player:messageSpecial(base + xi.fishingMessage.KEEN_ANGLERS_SENSE, catch.itemId)
    else
        player:messageText(player, base + xi.fishing.feelingMessages[fight.feeling])
    end

    -- The bite scheduler pulls hard for a large fish, monster or chest and lightly for the rest
    player:entityAnimationPacket(large and xi.animationString.FISHING_BITE_LARGE or xi.animationString.FISHING_BITE_SMALL)
    player:setAnimation(xi.animation.NEW_FISHING_FISH)

    return fight
end

-----------------------------------
-- Outcomes
-----------------------------------

local function classify(reported)
    if reported <= 4 then
        return xi.fishing.result.CAUGHT
    elseif reported <= 20 then
        return xi.fishing.result.LOW_SKILL
    elseif reported <= 100 then
        return xi.fishing.result.LINE_BREAK
    elseif reported <= 256 then
        return xi.fishing.result.GAVE_UP
    end

    return xi.fishing.result.LOST
end

local function rollResult(cast)
    local chances = cast.fight.chances

    if math.randomInt(1, 100) <= chances.lose then
        if chances.loseReason == xi.fishing.failure.LOW_SKILL then
            return xi.fishing.result.LOW_SKILL
        end

        cast.lossReason = chances.loseReason

        return xi.fishing.result.LOST
    end

    if math.randomInt(1, 100) <= chances.lineSnap then
        return xi.fishing.result.LINE_BREAK
    end

    if math.randomInt(1, 100) <= chances.rodBreak then
        return xi.fishing.result.ROD_BREAK
    end

    return xi.fishing.result.CAUGHT
end

local function consumeBait(player, cast, result)
    if
        result == xi.fishing.result.CAUGHT and
        cast.catch.type == xi.fishing.catchType.ITEM
    then
        return false
    end

    if not player:getEquippedItem(xi.slot.AMMO) then
        return false
    end

    local lineGone = result == xi.fishing.result.LINE_BREAK or result == xi.fishing.result.ROD_BREAK
    if
        cast.bait.type == xi.fishingBaitType.LURE and
        not lineGone
    then
        return false
    end

    player:removeAmmo(1)

    return true
end

-- A hooked monster goes back to the pool.
local function unhookMonster(cast)
    if
        cast.catch.type == xi.fishing.catchType.MONSTER and
        cast.catch.mob
    then
        cast.catch.mob:setLocalVar('hooked', 0)
    end
end

local function failCatch(player, cast, result, baitTaken)
    local effect    = xi.fishing.results[result]
    local animation = effect.animation
    local line      = effect.message

    if
        result == xi.fishing.result.LOW_SKILL and
        not cast.claimed
    then
        animation = xi.animation.NEW_FISHING_LINE_BREAK
    elseif result == xi.fishing.result.LOST then
        line = xi.fishing.lostMessages[cast.lossReason] or line
    elseif
        result == xi.fishing.result.GAVE_UP and
        baitTaken
    then
        line = xi.fishingMessage.GIVE_UP_BAIT_LOSS
    end

    player:setAnimation(animation)
    player:messageText(player, zones[player:getZoneID()].text.FISHING_MESSAGE_OFFSET + line)

    if
        result == xi.fishing.result.ROD_BREAK and
        cast.rod.breaksTo
    then
        player:unequipItem(xi.slot.RANGED)
        if player:delItem(cast.rodId, 1) then
            player:addItem({ id = cast.rod.breaksTo, silent = true })
        end
    end
end

local function catchFish(player, cast)
    local catch   = cast.catch
    local bigFish = cast.fight.bigFish
    local count   = catch.count or 1
    local base    = zones[player:getZoneID()].text.FISHING_MESSAGE_OFFSET

    player:setAnimation(xi.animation.NEW_FISHING_CAUGHT)

    if player:getFreeSlotsCount() == 0 then
        player:messageName(base + xi.fishingMessage.CATCH_INVENTORY_FULL, player, catch.itemId, count, nil, nil, nil, true)
        return false
    end

    local item = { id = catch.itemId, quantity = count, silent = true }
    if bigFish then
        item.exdata = { size = bigFish.length, weight = bigFish.weight }

        -- Katsunaga names the longest and the heaviest fish ever landed, so a big fish past either record takes it
        if bigFish.length > player:getCharVar('[Fish]Longest') then
            player:setVolatileCharVar('[Fish]Longest', bigFish.length)
            player:setVolatileCharVar('[Fish]LongestFish', catch.itemId)
        end

        if bigFish.weight > player:getCharVar('[Fish]Heaviest') then
            player:setVolatileCharVar('[Fish]Heaviest', bigFish.weight)
            player:setVolatileCharVar('[Fish]HeaviestFish', catch.itemId)
        end
    end

    player:addItem(item)

    if count > 1 then
        player:messageName(base + xi.fishingMessage.CATCH_MULTI, player, catch.itemId, count, nil, nil, nil, true)
    elseif bigFish then
        local heavy = cast.fight.roll >= 103 and 7 or 5

        player:messageName(base + xi.fishingMessage.CATCH, player, catch.itemId, bigFish.weight, heavy, math.floor(cast.fight.stamina * 0.12), nil, true)
    else
        player:messageName(base + xi.fishingMessage.CATCH, player, catch.itemId, count, nil, nil, nil, true)
    end

    return true
end

local function catchItem(player, cast)
    local base = zones[player:getZoneID()].text.FISHING_MESSAGE_OFFSET

    player:setAnimation(xi.animation.NEW_FISHING_CAUGHT)

    if player:getFreeSlotsCount() == 0 then
        player:messageName(base + xi.fishingMessage.CATCH_INVENTORY_FULL, player, cast.catch.itemId, 1, nil, nil, nil, true)
        return false
    end

    player:addItem({ id = cast.catch.itemId, silent = true })
    player:messageName(base + xi.fishingMessage.CATCH, player, cast.catch.itemId, 1, nil, nil, nil, true)

    return true
end

-- Stamps a fished-up monster with its cooldown as it leaves the world, alive or dead, and lets the listener go with its one use
local function stampCooldown(mobArg)
    mobArg:setLocalVar('respawnAt', GetSystemTime() + xi.fishing.monsters[mobArg:getName()].cooldown)
    mobArg:removeListener('FISHING_COOLDOWN')
end

local function catchMonster(player, cast)
    local mob    = cast.catch.mob
    local record = cast.catch.record

    if
        not mob or
        mob:isAlive()
    then
        failCatch(player, cast, xi.fishing.result.LOST, false)
        return false
    end

    local radians = player:getRotPos() * math.pi / 128
    local x       = player:getXPos() - 2 * math.cos(radians)
    local z       = player:getZPos() + 2 * math.sin(radians)

    player:setAnimation(xi.animation.NEW_FISHING_MONSTER)
    player:messageName(zones[player:getZoneID()].text.FISHING_MESSAGE_OFFSET + xi.fishingMessage.MONSTER, player, nil, nil, nil, nil, nil, true)

    mob:setSpawn(x, player:getYPos() - 0.5, z, utils.getWorldRotation({ x = x, z = z }, { x = player:getXPos(), z = player:getZPos() }))
    mob:spawn(180)
    mob:setMobMod(xi.mobMod.CHARMABLE, 0)
    mob:setMobMod(xi.mobMod.IDLE_DESPAWN, 180)
    mob:setLocalVar('hooked', 0)

    -- The cooldown runs from the despawn, so it is stamped there
    local monster = xi.fishing.monsters[mob:getName()]
    if
        monster and
        monster.cooldown
    then
        mob:addListener('DESPAWN', 'FISHING_COOLDOWN', stampCooldown)
    end

    if
        record.quest or
        bit.band(mob:getMobMod(xi.mobMod.DETECTION), xi.detects.SCENT) ~= 0 or
        not player:hasStatusEffect(xi.effect.SNEAK)
    then
        mob:engage(player:getTargID())
        mob:updateClaim(player)
    end

    return true
end

local function fatigueEventFor(result, cast)
    if result == xi.fishing.result.CAUGHT then
        return xi.fishing.catchFatigueEvent(cast)
    end

    if result == xi.fishing.result.GAVE_UP then
        return xi.fishing.fatigueEvent.RELEASE
    end

    return nil
end

local function decideResult(cast, reported, echo)
    local result = classify(reported)

    cast.claimed = result == xi.fishing.result.CAUGHT
    if not cast.claimed then
        return result
    end

    -- A claim with the wrong echo, or inside two seconds of the bite, was no fight at all
    if
        echo ~= cast.fight.intuition or
        GetSystemTime() < cast.hookedAt + 2
    then
        return xi.fishing.result.LOST
    end

    return rollResult(cast)
end

-- Hands a caught thing to its class; false when it cannot be taken.
local function landCatch(player, cast)
    if cast.catch.type == xi.fishing.catchType.FISH then
        return catchFish(player, cast)
    elseif cast.catch.type == xi.fishing.catchType.ITEM then
        return catchItem(player, cast)
    elseif cast.catch.type == xi.fishing.catchType.MONSTER then
        return catchMonster(player, cast)
    end

    -- A chest gone from under the line is lost
    if not xi.fishing.chart.catchChest(player, cast) then
        failCatch(player, cast, xi.fishing.result.LOST, false)
        return false
    end

    return true
end

local function interruptFight(player, cast)
    if cast.stage ~= xi.fishing.stage.FIGHTING then
        return
    end

    unhookMonster(cast)
    consumeBait(player, cast, xi.fishing.result.GAVE_UP)
end

-- Answers CHECK_HOOK with the fight for the core to send as 0x115, or nil on an empty cast.
local function checkHook(player, cast)
    -- The client asks about a second before its timer ends; a check earlier than two seconds before is an empty cast without a roll
    local catch = nil
    if GetSystemTime() >= cast.startedAt + cast.hookTime - 2 then
        catch = xi.fishing.rollBite(player, cast, xi.fishing.getData())
    end

    -- Nothing bit, or the monster drawn could not be hooked after all: an empty cast either way
    local fight = catch and xi.fishing.hookCatch(player, cast, catch)
    if not fight then
        player:messageText(player, zones[player:getZoneID()].text.FISHING_MESSAGE_OFFSET + xi.fishingMessage.NO_CATCH)
        player:setAnimation(xi.animation.NEW_FISHING_STOP)
        cast.stage = xi.fishing.stage.EMPTY

        -- A fish or item with no fight row is a catalog hole, reported once the cast is closed so the angler is not left waiting
        if
            catch and
            catch.itemId and
            not xi.fishing.catchStats[catch.itemId]
        then
            printf('[warning] fishing: no fight row for ITEM %i', catch.itemId)
        end

        return nil
    end

    -- Katsunaga counts every hit, whatever took the hook and however the fight ends
    player:setVolatileCharVar('[Fish]Hits', player:getCharVar('[Fish]Hits') + 1)

    -- The client shows the bite when its own timer ends, about a second after it asks
    cast.catch    = catch
    cast.fight    = fight
    cast.stage    = xi.fishing.stage.FIGHTING
    cast.hookedAt = cast.startedAt + cast.hookTime

    return fight
end

xi.fishing.resolveCatch = function(player, cast, reported, echo)
    local result = decideResult(cast, reported, echo)
    local failed = result ~= xi.fishing.result.CAUGHT

    -- A catch that cannot be taken is lost after all, the catch handler having said so
    if
        not failed and
        not landCatch(player, cast)
    then
        result = xi.fishing.result.LOST
    end

    if result ~= xi.fishing.result.CAUGHT then
        unhookMonster(cast)
    end

    local baitTaken = consumeBait(player, cast, result)

    if failed then
        failCatch(player, cast, result, baitTaken)
    end

    local event = fatigueEventFor(result, cast)
    if event then
        -- Over-level is a catalog catch 17 or more levels above the angler's skill, gear counted; a monster has no level
        local overLevel = false
        if
            cast.catch.record and
            cast.catch.record.skill
        then
            local skill = math.floor(player:getCharSkillLevel(xi.skill.FISHING) / 10) + player:getMod(xi.mod.FISH)
            overLevel   = cast.catch.record.skill - skill >= 17
        end

        xi.fishing.accrueFatigue(player, cast, event, overLevel)
    end

    return result
end

-----------------------------------
-- Skill-ups
-----------------------------------

local function skillUpChance(player, gap, level)
    if gap < 1 then
        return 0
    end

    local chance = 0
    for _, row in ipairs(xi.fishing.skillUpChances) do
        if gap <= row.gap then
            chance = row.chance
            break
        end
    end

    -- The angler's own skill damps the rate: the corpus holds one gap band at 36 percent at skill 0 and 10 at 98
    chance = math.floor(chance * (108 - math.floor(level * 4 / 5)) / 100)

    chance = math.floor(chance * xi.settings.map.FISHING_SKILL_MULTIPLIER)

    -- The Fisherman's Feast raises the rate by its percent, rounded to the nearest point
    chance = math.floor(chance * (100 + player:getMod(xi.mod.FISHING_SKILL_GAIN)) / 100 + 0.5)

    return chance
end

local function raiseSkill(player, amount)
    local current = player:getCharSkillLevel(xi.skill.FISHING)
    local cap     = (player:getSkillRank(xi.skill.FISHING) + 1) * 100
    local raised  = math.min(current + amount, cap)
    if raised <= current then
        return
    end

    player:setSkillLevel(xi.skill.FISHING, raised)
    player:messageBasic(xi.msg.basic.SKILL_RISES, xi.skill.FISHING, raised - current)

    if math.floor(raised / 10) > math.floor(current / 10) then
        player:messageBasic(xi.msg.basic.SKILL_REACHES_LEVEL, xi.skill.FISHING, math.floor(raised / 10))
    end
end

xi.fishing.rollSkillUp = function(player, cast)
    if
        not cast.catch or
        cast.catch.type ~= xi.fishing.catchType.FISH or
        not cast.result
    then
        return
    end

    if xi.fishing.results[cast.result].skillUp == xi.fishing.skillUpWeight.NONE then
        return
    end

    -- A failure the client reported never rolls; one the server rolled on a claim does while the setting keeps it
    if
        cast.result ~= xi.fishing.result.CAUGHT and
        (not cast.claimed or not xi.settings.map.FISHING_SKILLUP_ON_FAILURE)
    then
        return
    end

    -- A catch lost to its size earns skill at the rate a landed one does; a loss with no size behind it earns none
    if
        cast.result == xi.fishing.result.LOST and
        cast.lossReason ~= xi.fishing.failure.LOST_SMALL and
        cast.lossReason ~= xi.fishing.failure.LOST_BIG
    then
        return
    end

    local level  = math.floor(player:getCharSkillLevel(xi.skill.FISHING) / 10)
    local gap    = cast.catch.record.skill - level
    local chance = skillUpChance(player, gap, level)
    if chance == 0 then
        return
    end

    -- Pelican Ring adds a second roll for skillup checks
    for _ = 1, 1 + player:getMod(xi.mod.PELICAN_RING_EFFECT) do
        if math.randomInt(1, 100) <= chance then
            local amount = 1
            if
                gap >= 28 and
                math.randomInt(1, 2) == 1
            then
                amount = 2
            end

            raiseSkill(player, amount)
        end
    end
end

-----------------------------------
-- Entry points
-----------------------------------

-- Returns the hook time in seconds when a cast opened, for the 0x037 timer byte. Nil refuses the cast and the core ends the fishing event.
xi.fishing.onStart = function(player)
    local data           = xi.fishing.getData()
    local areaName, area = checkEntry(player, data)
    if not area then
        return nil
    end

    return castLine(player, data, areaName, area)
end

-- Answers the client's fishing packet by mode. Returns the fight to send on CHECK_HOOK, nothing otherwise.
xi.fishing.onAction = function(player, mode, para, para2)
    local cast = xi.fishing.casts[player:getID()]
    if not cast then
        return nil
    end

    -- RELEASE is the end-of-cast acknowledgement, valid from any stage: a fight still open is given up, then the skill-up roll,
    -- the animation cleared and the cast closed
    if mode == xi.fishing.mode.RELEASE then
        interruptFight(player, cast)
        xi.fishing.rollSkillUp(player, cast)
        player:setAnimation(xi.animation.NONE)
        xi.fishing.casts[player:getID()] = nil

        return nil
    end

    -- CHECK_HOOK is answered while the line is out and the other modes during the fight; out of order they are ignored
    if
        mode == xi.fishing.mode.CHECK_HOOK and
        cast.stage == xi.fishing.stage.CAST
    then
        return checkHook(player, cast)
    end

    if cast.stage ~= xi.fishing.stage.FIGHTING then
        return nil
    end

    -- END_MINIGAME carries the stamina the client reports and its echo of the fight's intuition value
    if mode == xi.fishing.mode.END_MINIGAME then
        cast.result = xi.fishing.resolveCatch(player, cast, para, para2)
        cast.stage  = xi.fishing.stage.RESOLVED
    elseif mode == xi.fishing.mode.POTENTIAL_TIMEOUT then
        -- POTENTIAL_TIMEOUT carries the seconds left and only warns; the fight goes on
        player:messageText(player, zones[player:getZoneID()].text.FISHING_MESSAGE_OFFSET + xi.fishingMessage.WARNING)
    end

    return nil
end

-- The animation is cleared here and nowhere in the core, and the next cast is refused until it is.
xi.fishing.onInterrupt = function(player)
    local cast = xi.fishing.casts[player:getID()]
    if not cast then
        return
    end

    interruptFight(player, cast)
    player:setAnimation(xi.animation.NONE)
    xi.fishing.casts[player:getID()] = nil
end
