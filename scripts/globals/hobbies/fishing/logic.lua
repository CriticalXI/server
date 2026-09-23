-----------------------------------
-- Fishing Logic
-----------------------------------
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

-- The animations the core counts as fishing, so a cleanup never touches death or anything else
local function isFishingAnimation(animation)
    return (animation >= xi.animation.NEW_FISHING_START and animation <= xi.animation.NEW_FISHING_STOP) or animation == xi.animation.FISHING_START
end

-- Every fishing line is a self-addressed 0x036 carrying type 6, as retail sends them
local fishingMessageType = 6

local function sendFishingMessage(player, line)
    player:messageText(player, zones[player:getZoneID()].text.FISHING_MESSAGE_OFFSET + line, fishingMessageType)
end

-----------------------------------
-- Meters
-----------------------------------

-- Save the meters to char vars that expire at JST midnight
xi.fishing.updateMeters = function(player, meters)
    local resetDays    = math.ceil(meters.fatigue / math.floor(xi.settings.map.FISHING_FATIGUE_CAP * 4 / 5))
    local nextMidnight = JstMidnight()
    local lastMidnight = nextMidnight + 86400 * math.max(0, resetDays - 1)

    -- Player may increase fatigue without increasing daily points. Set Today var to track for fatigue resets
    player:setCharVar('[Fish]DailyPoints', meters.daily, nextMidnight)
    player:setCharVar('[Fish]Today', 1, nextMidnight)
    player:setCharVar('[Fish]Fatigue', meters.fatigue, lastMidnight)
end

-- Read the meters, dropping a day's fatigue if midnight has passed since the last write
xi.fishing.currentMeters = function(player)
    local meters =
    {
        daily   = player:getCharVar('[Fish]DailyPoints'),
        fatigue = player:getCharVar('[Fish]Fatigue'),
        today   = player:getCharVar('[Fish]Today'),
    }

    if meters.today ~= 1 then
        meters.fatigue = math.max(0, meters.fatigue - math.floor(xi.settings.map.FISHING_FATIGUE_CAP * 4 / 5))
    end

    return meters
end

-- The fatigue event a caught fish, item or monster costs
xi.fishing.catchFatigueEvent = function(cast)
    local catch = cast.catch

    -- Fish cost by legendary tier, then by size
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

    -- Items cost by fatigue class, countable unless the item's row says otherwise; monsters only when their row gives a class
    local class = nil
    if catch.type == xi.fishing.catchType.ITEM then
        local stats = xi.fishing.catchStats[catch.itemId]

        class = catch.record.fatigue or (stats and stats.fatigue) or xi.fishing.fatigueClass.COUNTABLE
    elseif catch.type == xi.fishing.catchType.MONSTER then
        local monster = xi.fishing.monsters[catch.mob:getName()]

        class = monster and monster.fatigue
    end

    if class == xi.fishing.fatigueClass.VALUABLE then
        return xi.fishing.fatigueEvent.VALUABLE_ITEM
    elseif class == xi.fishing.fatigueClass.JUNK then
        return xi.fishing.fatigueEvent.JUNK_ITEM
    elseif class == xi.fishing.fatigueClass.COUNTABLE then
        return xi.fishing.fatigueEvent.COUNTABLE_ITEM
    end

    return xi.fishing.fatigueEvent.EMPTY_CAST
end

-- Add an event's daily points and fatigue to the player's meters
xi.fishing.accrueFatigue = function(player, cast, event, overLevel)
    if not xi.settings.map.FISHING_FATIGUE_ENABLE then
        return
    end

    local cost    = xi.fishing.fatigueCosts[event]
    local daily   = cost.daily
    local fatigue = overLevel and cost.overLevel or cost.fatigue

    -- Legendary rods scale fatigue by their own percent, but not a loss to lack of skill
    local rod = xi.fishing.rodStats[cast.rodId]
    if
        rod and
        rod.fatigue and
        event ~= xi.fishing.fatigueEvent.LOW_SKILL
    then
        fatigue = math.floor(fatigue * rod.fatigue / 100)
    end

    -- A player with no job at FISHING_MIN_LEVEL takes 20 times the cost on both meters
    local lowLevel = true
    for job = xi.job.WAR, xi.job.RUN do
        if player:getJobLevel(job) >= xi.settings.map.FISHING_MIN_LEVEL then
            lowLevel = false
            break
        end
    end

    if lowLevel then
        daily   = daily * 20
        fatigue = fatigue * 20
    end

    if
        daily == 0 and
        fatigue == 0
    then
        return
    end

    local meters   = xi.fishing.currentMeters(player)
    meters.daily   = meters.daily + daily
    meters.fatigue = meters.fatigue + fatigue

    xi.fishing.updateMeters(player, meters)
end

-- Nothing bites once the daily cap or the fatigue cap is reached
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

-- Find the fishing area the player is currently in: the transport's route, then a shape, then the unshaped fallback.
local function findArea(player, zone)
    if not zone then
        return nil
    end

    -- A transport fishes the area named after its current route
    local route = nil
    if player:getZoneID() == xi.zone.MANACLIPPER then
        route = xi.manaclipper.currentRoute()
    elseif player:getZoneID() == xi.zone.PHANAUET_CHANNEL then
        route = xi.barge.currentRoute()
    end

    if
        route and
        zone.areas[route]
    then
        return route, zone.areas[route]
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
            sendFishingMessage(player, xi.fishingMessage.CANNOT_FISH_HERE)
        end

        return nil
    end

    if player:getAnimation() ~= xi.animation.NONE then
        player:messageSystem(xi.msg.system.CANNOT_USE_COMMAND_NOW)
        return nil
    end

    if not data.rods[player:getEquipID(xi.slot.RANGED)] then
        sendFishingMessage(player, xi.fishingMessage.NO_ROD)
        return nil
    end

    if not data.baits[player:getEquipID(xi.slot.AMMO)] then
        sendFishingMessage(player, xi.fishingMessage.NO_BAIT)
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

    -- Katsunaga counts every cast; the count reaches the database on the next persist sweep rather than a query per cast
    player:setVolatileCharVar('[Fish]Casts', player:getCharVar('[Fish]Casts') + 1)

    return cast.hookTime
end

-----------------------------------
-- Fish / Item Selection
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

-- Obtain fish entries from the pool that bite, each weighted by its level against the angler's skill
local function fishEntries(player, cast, area, data)
    local entries   = {}
    local preferred = xi.fishing.preferredCatches[cast.baitId] or {}
    local skill     = math.floor(player:getCharSkillLevel(xi.skill.FISHING) / 10) + player:getMod(xi.mod.FISH)

    for _, itemId in ipairs(area.pool) do
        local fish = data.fish[itemId]
        if confirmFishEntry(player, cast, itemId, fish) then
            local gap    = fish.skill - skill
            local weight = 42
            if gap > 3 then
                weight = math.max(7, math.floor(42 * math.pow(0.94, gap - 3)))
            elseif gap <= 0 then
                weight = math.min(400, math.floor(42 * math.pow(1.04, -gap)))
            end

            -- From skill 20 a fish that prefers the bait bites over the rest of the pool
            if
                skill >= 20 and
                utils.contains(itemId, preferred)
            then
                weight = weight * 2 -- Capture needed: the size of the preference
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

-- Junk bites at 6 an item, a ring, blade, pick or coral at 1
local function itemEntries(player, area, data)
    local entries = {}
    local bonus   = 0
    for _, itemId in ipairs(area.pool) do
        local item = data.fish[itemId]
        if confirmItemEntry(player, itemId, item) then
            local stats  = xi.fishing.catchStats[itemId]
            local weight = 6
            if stats and stats.fatigue == xi.fishing.fatigueClass.VALUABLE then
                weight = 1
            end

            table.insert(entries, { itemId, weight })
            if item.quest then
                bonus = bonus + 1000
            end
        end
    end

    return entries, bonus
end

-- Check if a monster can be fished up
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

-- Obtain the monsters that can be fished up in the area with the bait
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

-- Craft the weights for fish, items and monsters in the available pool to draw from
local function setupWeights(player, entries, itemBonus, monsterBonus)
    local weights = {}

    if bit.band(player:getZone():getTypeMask(), xi.zoneType.CITY) ~= 0 then
        weights[xi.fishing.catchType.MONSTER] = 0
        weights[xi.fishing.catchType.NOTHING] = 38
    else
        weights[xi.fishing.catchType.MONSTER] = 10
        weights[xi.fishing.catchType.NOTHING] = 26
    end

    weights[xi.fishing.catchType.FISH] = 0
    for _, entry in ipairs(entries[xi.fishing.catchType.FISH]) do
        weights[xi.fishing.catchType.FISH] = weights[xi.fishing.catchType.FISH] + entry[2]
    end

    weights[xi.fishing.catchType.ITEM] = itemBonus
    for _, entry in ipairs(entries[xi.fishing.catchType.ITEM]) do
        weights[xi.fishing.catchType.ITEM] = weights[xi.fishing.catchType.ITEM] + entry[2]
    end

    weights[xi.fishing.catchType.MONSTER] = weights[xi.fishing.catchType.MONSTER] + monsterBonus

    -- Pick the fish now so the rod can read its level
    local fishId = chooseWeightedEntry(entries[xi.fishing.catchType.FISH])

    -- The Moghancement: Fishing Item draws items about as often as fish
    if player:hasKeyItem(xi.keyItem.MOGHANCEMENT_FISHING_ITEMS) then
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
        weights[xi.fishing.catchType.NOTHING] = math.floor(weights[xi.fishing.catchType.NOTHING] / 3)
    end

    for _, catchType in ipairs(xi.fishing.entryBuckets) do
        if #entries[catchType] == 0 then
            weights[xi.fishing.catchType.NOTHING] = weights[xi.fishing.catchType.NOTHING] + math.floor(weights[catchType] / 2)
            weights[catchType]                    = 0
        end
    end

    return weights, fishId
end

-- Choose which pool to draw from, then choose a fish, item or monster from that pool
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

    return nil
end

xi.fishing.biteBuckets = function(player, cast, data)
    -- Generate available pools of items, monsters and fish
    local entries                = {}
    local fish                   = fishEntries(player, cast, cast.area, data)
    local items, itemBonus       = itemEntries(player, cast.area, data)
    local monsters, monsterBonus = monsterEntries(player, cast, cast.areaName)

    -- Populate entry list from the generated pools
    entries[xi.fishing.catchType.FISH   ] = fish
    entries[xi.fishing.catchType.ITEM   ] = items
    entries[xi.fishing.catchType.MONSTER] = monsters

    -- Calculate the weights for each catch type based on the entries and bonuses
    local weights, fishId = setupWeights(player, entries, itemBonus, monsterBonus)

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

    -- A monster whose row names a level always fights there, the rest roll one out of 100 on the hook
    if catch.type == xi.fishing.catchType.MONSTER then
        context.size = xi.fishingSize.LARGE

        local monster = xi.fishing.monsters[catch.mob:getName()]
        local level   = monster and monster.level
        local roll    = math.randomInt(1, 100)
        local sum     = 0

        for _, stats in ipairs(xi.fishing.monsterFightStats) do
            sum = sum + stats.chance
            if
                level == stats.level or
                (not level and roll <= sum)
            then
                context.level = stats.level
                context.stats = stats
                break
            end
        end
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

local function stamina(context, roll)
    -- Every catch starts from 1800 and gains 50 a level, the level taken in pairs
    local base = 18 + math.floor(context.level / 2)

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

-- The gauge the client fights against. 128 baseline stamina, value above or below results in either a drain or regen
local function regen(cast, context, catch, roll)
    local regenValue     = 128
    local levelDiff      = context.skill - context.level

    -- Calculate the recovery of the fish or monster's stamina
    local diffBreakPoint = catch.type == xi.fishing.catchType.MONSTER and 35 or 40
    local multiplier     = catch.type == xi.fishing.catchType.MONSTER and 0.2 or 0.55

    -- A legendary catch recovers a point whatever the gap, two on a super legendary
    if context.tier then
        return regenValue + (context.tier == xi.fishingLegendaryTier.SUPER and 2 or 1)
    end

    -- Return increased regen if the player is 30 or below the fish or monster's level
    if levelDiff <= -30 then
        local regenBoost = math.max(0, math.floor((-levelDiff - diffBreakPoint) * multiplier))

        return 2 + regenValue + regenBoost
    end

    -- Check for legendary rod drain or apply default
    local drainDiff = context.rod.drainStart or 14
    local drainMult = context.rod.drainSlope or 0.8

    if levelDiff >= drainDiff then
        -- The drain stops at the rod's own floor. A rod that names none holds a fish to 86 and anything sturdier to 98:
        -- retail floored a monster on Lu Shang's at 92, the same floor its fish take, over 29 hooks at 45 to 91 levels over
        local deepest = context.rod.drainFloor or (catch.type == xi.fishing.catchType.FISH and 86 or 98)

        regenValue = regenValue - math.min(math.floor((levelDiff - drainDiff) * drainMult), deepest)

        -- The stamina roll moves the drain a point per point off 100, so a heavy catch drains harder
        regenValue = regenValue - (roll - 100)
    end

    -- A legendary rod wears a monster down past whatever the curve gave
    if
        cast.rod.legendary and
        catch.type == xi.fishing.catchType.MONSTER
    then
        regenValue = regenValue - 3
    end

    return regenValue
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
        player:hasKeyItem(xi.keyItem.MOOCHING) and
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

-- The chance a fish is lost to lack of skill
local function lowSkillChance(context, catch)
    if catch.type ~= xi.fishing.catchType.FISH then
        return 0
    end

    local gap = context.level - context.skill

    if context.stats.lowSkill then
        return gap >= context.stats.lowSkill.gap and context.stats.lowSkill.chance or 0
    end

    if
        gap >= 20 and
        context.size == xi.fishingSize.LARGE
    then
        return math.min(100, 80 + math.floor((gap - 20) * 0.8))
    end

    -- Apply chance to reel in fish based on skill gap
    if gap >= 50 then
        return 95
    elseif gap >= 45 then
        return 70
    elseif gap >= 25 then
        return 5
    end

    return 0
end

-- The rod break, lack-of-skill, line snap and size loss chances the fight is rolled against at the bite
local function calculateLoss(cast, context, catch)
    local stats   = context.stats
    local chances =
    {
        lowSkill   = lowSkillChance(context, catch),
        lineSnap   = 0,
        rodBreak   = 0,
        sizeLoss   = 0,
        falseAlarm = 0
    }

    -- Calculate the catch's weight vs the rod's strength. Failure increases at 3% per point over.
    -- TODO: Current hypothesis is that each fish has a unique weight, along with a unique strenght for each rod not passed in packets
    -- Proper implementation requires further captures to prove out this formula more precisely
    local weight = stats.weight or (18 + math.floor(context.level / 2))
    local over   = weight - (context.rod.strength or 0) - math.floor(context.skill / 4)
    if
        context.rod.strength and
        over > 0
    then
        chances.rodBreak = math.min(100, math.max(0, (over - 16) * 3))
        chances.lineSnap = math.min(100, over * 3)
    end

    -- A catch with its own snap rate cuts the line at least that often
    chances.lineSnap = math.max(chances.lineSnap, stats.lineSnap or 0)

    -- Lu Shang's breaks on the legendaries its list names at the list's rate
    if
        (cast.rodId == xi.item.LU_SHANGS_FISHING_ROD or cast.rodId == xi.item.LU_SHANGS_FISHING_ROD_P1) and
        xi.fishing.luShangBreaks[catch.itemId]
    then
        chances.rodBreak = xi.fishing.luShangBreaks[catch.itemId]
    end

    -- Check if the rod has a penalty against this fish size
    if
        context.rod.penalty == context.size and
        catch.type ~= xi.fishing.catchType.MONSTER
    then
        chances.sizeLoss = stats.sizeLoss or math.min(90, math.floor(context.level * 1.8))
        chances.lostAs   = context.size == xi.fishingSize.LARGE and xi.fishing.failure.LOST_BIG or xi.fishing.failure.LOST_SMALL
    end

    -- A catch just above the angler can read bad or terrible and still land. Retail did so on 3 percent of hooks one level
    -- over, climbing to 9 by eleven; the flat rate here stands in for that climb.
    -- Capture needed: the climb, and the terrible half, which no reeled hook in the corpus ever shows.
    local levelsAboveAngler = context.level - context.skill
    if
        levelsAboveAngler >= 1 and
        levelsAboveAngler <= 11
    then
        chances.falseAlarm = 4
    end

    return chances
end

local function rollOutcome(chances)
    if math.randomInt(1, 100) <= chances.rodBreak then
        return xi.fishing.result.ROD_BREAK
    end

    if math.randomInt(1, 100) <= chances.lowSkill then
        return xi.fishing.result.LOW_SKILL
    end

    if math.randomInt(1, 100) <= chances.lineSnap then
        return xi.fishing.result.LINE_BREAK
    end

    if math.randomInt(1, 100) <= chances.sizeLoss then
        return xi.fishing.result.LOST
    end

    return xi.fishing.result.CAUGHT
end

-- The hook feeling the angler is given for the outcome the fight has already rolled
local function feeling(context, bigFish, result, chances)
    if bigFish and bigFish.epic then
        return xi.fishing.feeling.EPIC
    end

    local snapChance = context.stats.lineSnap or 0
    local reading    = xi.fishing.feeling.GOOD

    if
    snapChance >= 45 or
    result == xi.fishing.result.ROD_BREAK
    then
        reading = xi.fishing.feeling.TERRIBLE

    elseif result == xi.fishing.result.LINE_BREAK then
        reading = xi.fishing.feeling.BAD

    elseif chances.falseAlarm > 0 then
        if math.randomInt(1, 100) <= chances.falseAlarm then
            reading = xi.fishing.feeling.BAD
        elseif math.randomInt(1, 100) <= chances.falseAlarm then
            reading = xi.fishing.feeling.TERRIBLE
        end
    end

    -- Feeling returns a comment about skill feelings at 12 or over level diff, with a random chance between 8 and 11
    local levelDiff = context.level - context.skill
    if
        levelDiff >= 12 or
        (levelDiff >= 8 and math.randomInt(1, 100) <= 50)
    then
        if reading == xi.fishing.feeling.BAD then
            return xi.fishing.feeling.NO_SKILL_SURE

        elseif reading == xi.fishing.feeling.TERRIBLE then
            return xi.fishing.feeling.NO_SKILL_POSITIVE
        end

        return xi.fishing.feeling.NO_SKILL
    end

    return reading
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

    -- Never past 70
    return math.randomInt(1, 100) <= utils.clamp(chance, 0, 70)
end

local function intuition(context, keen)
    -- 10, and 2 more for every ten points of skill
    local value = 10 + 2 * math.floor(context.skill / 10)
    local moon  = getVanadielMoonCycle()
    local hour  = VanadielHour()

    -- A new or full moon adds 10, and 10 more on two hooks in five, a quarter moon adds 5 or 10 at even odds
    if
        moon == xi.moonCycle.NEW_MOON or
        moon == xi.moonCycle.FULL_MOON
    then
        value = value + 10
        if math.randomInt(1, 100) <= 40 then
            value = value + 10
        end
    elseif
        moon == xi.moonCycle.FIRST_QUARTER or
        moon == xi.moonCycle.THIRD_QUARTER
    then
        value = value + 5
        if math.randomInt(1, 100) <= 50 then
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
    local bigFish     = bigFishStats(context, catch)
    local chances     = calculateLoss(cast, context, catch)
    local result      = rollOutcome(chances)
    local sense       = feeling(context, bigFish, result, chances)
    local keen        = keenSense(context, catch, sense)
    local damage      = attack(context)
    local largeBite   = context.size == xi.fishingSize.LARGE and 1 or 0

    if keen then
        sense = xi.fishing.feeling.KEEN
    end

    return
    {
        stamina        = stamina(context, staminaRoll),
        regen          = regen(cast, context, catch, staminaRoll),
        move_frequency = arrowValue(player, context, context.stats.moveFrequency, context.rod.smallMove, context.rod.largeMove),
        arrow_damage   = damage,
        arrow_delay    = arrowValue(player, context, context.stats.arrowDelay, context.rod.smallDelay, context.rod.largeDelay),
        arrow_regen    = heal(context, damage, keen),
        time           = fightTime(player, cast, context),
        angler_sense   = largeBite + (keen and 2 or 0),
        intuition      = intuition(context, keen),
        feeling        = sense,
        result         = result,
        chances        = chances,
        bigFish        = bigFish,
        roll           = staminaRoll,
    }
end

xi.fishing.hookCatch = function(player, cast, catch)
    -- A monster that isn't loaded or is already in the world cancels the cast
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

    -- Mark the monster hooked so no one else can fish it up while it is on the line
    if catch.type == xi.fishing.catchType.MONSTER then
        catch.mob:setLocalVar('hooked', 1)
    end

    -- The hook line by class
    local hookLine = xi.fishingMessage.HOOKED_ITEM
    local large    = catch.type ~= xi.fishing.catchType.ITEM

    if catch.type == xi.fishing.catchType.MONSTER then
        hookLine = xi.fishingMessage.HOOKED_MONSTER
    elseif catch.type == xi.fishing.catchType.FISH then
        large    = catch.record.size == xi.fishingSize.LARGE
        hookLine = large and xi.fishingMessage.HOOKED_LARGE_FISH or xi.fishingMessage.HOOKED_SMALL_FISH
    end

    sendFishingMessage(player, hookLine)

    -- A keen angler's sense names the fish in place of the feeling
    if fight.feeling == xi.fishing.feeling.KEEN then
        player:messageSpecial(zones[player:getZoneID()].text.FISHING_MESSAGE_OFFSET + xi.fishingMessage.KEEN_ANGLERS_SENSE, catch.itemId)
    else
        sendFishingMessage(player, xi.fishing.feelingMessages[fight.feeling])
    end

    -- The bite scheduler pulls hard for a large fish or monster and lightly for the rest
    player:entityAnimationPacket(large and xi.animationString.FISHING_BITE_LARGE or xi.animationString.FISHING_BITE_SMALL)
    player:setAnimation(xi.animation.NEW_FISHING_FISH)

    return fight
end

-----------------------------------
-- Outcomes
-----------------------------------

-- Convert the value the client reports at the end of the minigame into a result
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

-- Whether the fight uses up the bait; the removal follows the result line, as retail orders them
local function baitIsLost(player, cast, result)
    -- Catching an item keeps the bait
    if
        result == xi.fishing.result.CAUGHT and
        cast.catch.type == xi.fishing.catchType.ITEM
    then
        return false
    end

    if not player:getEquippedItem(xi.slot.AMMO) then
        return false
    end

    -- Lures are only lost with the line
    local lineGone = result == xi.fishing.result.LINE_BREAK or result == xi.fishing.result.ROD_BREAK
    if
        cast.bait.type == xi.fishingBaitType.LURE and
        not lineGone
    then
        return false
    end

    return true
end

-- Play the animation and message for a failed catch
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
    -- An item that breaks the rod says whether it was too big or too heavy
    elseif
        result == xi.fishing.result.ROD_BREAK and
        cast.catch.type == xi.fishing.catchType.ITEM
    then
        line = cast.catch.record.size == xi.fishingSize.LARGE and xi.fishingMessage.ROD_BREAK_TOO_BIG or xi.fishingMessage.ROD_BREAK_TOO_HEAVY
    end

    player:setAnimation(animation)
    sendFishingMessage(player, line)

    -- Swap a broken rod for its broken version
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

-- Give the player the fish, returns false if the inventory is full
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

    -- Big fish carry their size and weight
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

    -- The catch line goes out ahead of the item packets, as retail orders them
    if count > 1 then
        player:messageName(base + xi.fishingMessage.CATCH_MULTI, player, catch.itemId, count, nil, nil, nil, true)
    elseif bigFish then
        local heavy = cast.fight.roll >= 103 and 7 or 5

        player:messageName(base + xi.fishingMessage.CATCH, player, catch.itemId, bigFish.weight, heavy, math.floor(cast.fight.stamina * 0.12), nil, true)
    else
        player:messageName(base + xi.fishingMessage.CATCH, player, catch.itemId, count, nil, nil, nil, true)
    end

    player:addItem(item)

    return true
end

-- Give the player the item, returns false if the inventory is full
local function catchItem(player, cast)
    local base = zones[player:getZoneID()].text.FISHING_MESSAGE_OFFSET

    player:setAnimation(xi.animation.NEW_FISHING_CAUGHT)

    if player:getFreeSlotsCount() == 0 then
        player:messageName(base + xi.fishingMessage.CATCH_INVENTORY_FULL, player, cast.catch.itemId, 1, nil, nil, nil, true)
        return false
    end

    player:messageName(base + xi.fishingMessage.CATCH, player, cast.catch.itemId, 1, nil, nil, nil, true)
    player:addItem({ id = cast.catch.itemId, silent = true })

    return true
end

-- A monster serves its cooldown from the moment it leaves the line, landed or not
local function startCooldown(mob)
    local monster = xi.fishing.monsters[mob:getName()]

    if monster and monster.cooldown then
        mob:setLocalVar('respawnAt', GetSystemTime() + monster.cooldown)
    end
end

-- A monster on the line goes back to the pool when the cast ends without landing it, and still serves its cooldown
local function releaseHookedMonster(cast)
    if
        cast.stage ~= xi.fishing.stage.FIGHTING or
        cast.catch.type ~= xi.fishing.catchType.MONSTER or
        not cast.catch.mob
    then
        return
    end

    cast.catch.mob:setLocalVar('hooked', 0)
    startCooldown(cast.catch.mob)
end

-- A landed monster's cooldown runs from the despawn instead, so the listener restamps it and goes
local function stampCooldown(mobArg)
    startCooldown(mobArg)
    mobArg:removeListener('FISHING_COOLDOWN')
end

-- Spawn the monster next to the player, returns false if it is gone or already up
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

    -- The cooldown starts when the monster despawns
    local monster = xi.fishing.monsters[mob:getName()]
    if
        monster and
        monster.cooldown
    then
        mob:addListener('DESPAWN', 'FISHING_COOLDOWN', stampCooldown)
    end

    -- Sneak keeps the monster from attacking, except quest monsters and those that track by scent
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

-- Work out the result of the minigame: the fight rolled it at the bite, and a claim collects it
local function decideResult(cast, reported, echo)
    local result = classify(reported)

    cast.claimed = result == xi.fishing.result.CAUGHT
    if not cast.claimed then
        return result
    end

    -- The catch is lost if the intuition echo is wrong or the claim comes within 2 seconds of the bite
    if
        echo ~= cast.fight.intuition or
        GetSystemTime() < cast.hookedAt + 2
    then
        return xi.fishing.result.LOST
    end

    if cast.fight.result == xi.fishing.result.LOST then
        cast.lossReason = cast.fight.chances.lostAs
    end

    return cast.fight.result
end

-- A fight that is cut short counts as giving up
local function interruptFight(player, cast)
    if cast.stage ~= xi.fishing.stage.FIGHTING then
        return
    end

    releaseHookedMonster(cast)

    if baitIsLost(player, cast, xi.fishing.result.GAVE_UP) then
        player:removeAmmo(1)
    end
end

-- A quest can force the catch through the interaction framework: an item id, or a mob entity for a monster
local function forcedCatch(player, cast, data)
    local forced = InteractionGlobal.onFishingHook(player, cast.areaName)

    if type(forced) == 'number' then
        local record = data.fish[forced]
        if not record then
            return nil
        end

        local catchType = xi.fishing.catchType.FISH
        if record.item then
            catchType = xi.fishing.catchType.ITEM
        end

        return { type = catchType, itemId = forced, record = record, count = 1 }
    end

    if type(forced) == 'userdata' then
        local spawnId = forced:getID()

        return { type = xi.fishing.catchType.MONSTER, spawnId = spawnId, mob = forced, record = cast.zone.monsters[spawnId] or {} }
    end

    return nil
end

-- Roll for a bite and return the fight to send to the client, or nil if nothing bites
local function checkHook(player, cast)
    -- The client checks about a second before its timer ends, anything earlier is an empty cast
    local catch = nil
    if GetSystemTime() >= cast.startedAt + cast.hookTime - 2 then
        local data = xi.fishing.getData()

        catch = forcedCatch(player, cast, data) or xi.fishing.rollBite(player, cast, data)
    end

    -- Nothing bit or the catch has no fight stats
    local fight = catch and xi.fishing.hookCatch(player, cast, catch)
    if not fight then
        sendFishingMessage(player, xi.fishingMessage.NO_CATCH)
        player:setAnimation(xi.animation.NEW_FISHING_STOP)
        cast.stage = xi.fishing.stage.EMPTY

        -- Warn about catches missing from catchStats
        if
            catch and
            catch.itemId and
            not xi.fishing.catchStats[catch.itemId]
        then
            printf('[warning] fishing: no fight row for item %i', catch.itemId)
        end

        return nil
    end

    -- Katsunaga counts every hit, whatever took the hook and however the fight ends
    player:setVolatileCharVar('[Fish]Hits', player:getCharVar('[Fish]Hits') + 1)

    -- The bite lands when the client's timer ends, about a second after the check
    cast.catch    = catch
    cast.fight    = fight
    cast.stage    = xi.fishing.stage.FIGHTING
    cast.hookedAt = cast.startedAt + cast.hookTime

    return fight
end

-- Land the catch or show the failure, then use up the bait
xi.fishing.resolveCatch = function(player, cast, reported, echo)
    local result = decideResult(cast, reported, echo)
    local failed = result ~= xi.fishing.result.CAUGHT

    -- Give the player the catch, a catch that can't be added to the inventory is lost
    if not failed then
        local landed = false
        if cast.catch.type == xi.fishing.catchType.FISH then
            landed = catchFish(player, cast)
        elseif cast.catch.type == xi.fishing.catchType.MONSTER then
            landed = catchMonster(player, cast)
        else
            landed = catchItem(player, cast)
        end

        if not landed then
            result = xi.fishing.result.LOST
        end
    end

    -- A monster that wasn't caught goes back to the pool on its cooldown
    if result ~= xi.fishing.result.CAUGHT then
        releaseHookedMonster(cast)
    end

    local baitTaken = baitIsLost(player, cast, result)

    if failed then
        failCatch(player, cast, result, baitTaken)
    end

    if baitTaken then
        player:removeAmmo(1)
    end

    -- A catch costs by its fatigue event
    local event = nil
    if not failed then
        event = xi.fishing.catchFatigueEvent(cast)
    elseif result == xi.fishing.result.GAVE_UP then
        event = xi.fishing.fatigueEvent.RELEASE
    elseif result == xi.fishing.result.LOW_SKILL then
        event = xi.fishing.fatigueEvent.LOW_SKILL
    end

    if event then
        -- Over level is a catch 17 or more levels above the player's skill, gear included
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

-- Chance out of 100 to raise the skill on a fish the given number of levels over the player
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

    -- Higher skill lowers the chance
    chance = math.floor(chance * (108 - math.floor(level * 4 / 5)) / 100)

    chance = math.floor(chance * xi.settings.map.FISHING_SKILL_MULTIPLIER)

    -- The Fisherman's Feast raises the chance by its percent, rounded to the nearest point
    chance = math.floor(chance * (100 + player:getMod(xi.mod.FISHING_SKILL_GAIN)) / 100 + 0.5)

    return chance
end

-- Raise fishing skill by tenths up to the guild rank cap and send the skill messages
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

-- Roll for a skill-up when the cast is released
xi.fishing.rollSkillUp = function(player, cast)
    -- Only a fish can raise the skill
    if
        not cast.catch or
        cast.catch.type ~= xi.fishing.catchType.FISH
    then
        return
    end

    if cast.result ~= xi.fishing.result.CAUGHT then
        local sizeLoss  = cast.result == xi.fishing.result.LOST and cast.lossReason ~= nil
        local gearBreak = cast.result == xi.fishing.result.ROD_BREAK or cast.result == xi.fishing.result.LINE_BREAK

        if
            not cast.claimed or
            not xi.settings.map.FISHING_SKILLUP_ON_FAILURE or
            (not sizeLoss and not gearBreak)
        then
            return
        end
    end

    local level  = math.floor(player:getCharSkillLevel(xi.skill.FISHING) / 10)
    local gap    = cast.catch.record.skill - level
    local chance = skillUpChance(player, gap, level)
    if chance == 0 then
        return
    end

    -- The Pelican Ring adds a second roll
    for _ = 1, 1 + player:getMod(xi.mod.PELICAN_RING_EFFECT) do
        if math.randomInt(1, 100) <= chance then
            -- From 28 levels over, half the skill-ups give two tenths
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

-- Handle the client's fishing packet by mode, only CHECK_HOOK returns the fight
xi.fishing.onAction = function(player, mode, para, para2)
    local cast = xi.fishing.casts[player:getID()]

    -- A dead angler keeps the death animation and the cast simply ends, as retail answers their packets with nothing
    if player:isDead() then
        if cast then
            releaseHookedMonster(cast)
            xi.fishing.casts[player:getID()] = nil
        end

        return nil
    end

    -- A fishing animation with no cast behind it (the cast state was lost) is still walked to idle so the client is not left waiting
    if not cast then
        if isFishingAnimation(player:getAnimation()) then
            if mode == xi.fishing.mode.RELEASE then
                player:setAnimation(xi.animation.NONE)
            else
                player:setAnimation(xi.animation.NEW_FISHING_STOP)
            end
        end

        return nil
    end

    -- RELEASE ends the cast from any stage, giving up a fight still in progress and rolling for a skill-up
    if mode == xi.fishing.mode.RELEASE then
        interruptFight(player, cast)
        xi.fishing.rollSkillUp(player, cast)
        if isFishingAnimation(player:getAnimation()) then
            player:setAnimation(xi.animation.NONE)
        end

        xi.fishing.casts[player:getID()] = nil

        return nil
    end

    -- CHECK_HOOK is only valid while the line is out
    if
        mode == xi.fishing.mode.CHECK_HOOK and
        cast.stage == xi.fishing.stage.CAST
    then
        return checkHook(player, cast)
    end

    -- END_MINIGAME at 201 while the line is out cancels the cast and reels in empty
    if
        mode == xi.fishing.mode.END_MINIGAME and
        para == 201 and
        cast.stage == xi.fishing.stage.CAST
    then
        sendFishingMessage(player, xi.fishingMessage.NO_CATCH)
        player:setAnimation(xi.animation.NEW_FISHING_STOP)
        cast.stage = xi.fishing.stage.EMPTY

        return nil
    end

    -- The other modes are only valid during the fight
    if cast.stage ~= xi.fishing.stage.FIGHTING then
        return nil
    end

    -- END_MINIGAME sends the client's result and its echo of the fight's intuition
    if mode == xi.fishing.mode.END_MINIGAME then
        cast.result = xi.fishing.resolveCatch(player, cast, para, para2)
        cast.stage  = xi.fishing.stage.RESOLVED
    elseif mode == xi.fishing.mode.POTENTIAL_TIMEOUT then
        -- POTENTIAL_TIMEOUT only warns the player and the fight continues
        sendFishingMessage(player, xi.fishingMessage.WARNING)
    end

    return nil
end

-- The animation is cleared here and nowhere in the core, and the next cast is refused until it is.
xi.fishing.onInterrupt = function(player)
    local cast = xi.fishing.casts[player:getID()]

    if player:isDead() then
        if cast then
            releaseHookedMonster(cast)
            xi.fishing.casts[player:getID()] = nil
        end

        return
    end

    if cast then
        interruptFight(player, cast)
        xi.fishing.casts[player:getID()] = nil
    end

    if isFishingAnimation(player:getAnimation()) then
        player:setAnimation(xi.animation.NONE)
    end
end
