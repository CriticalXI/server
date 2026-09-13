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

-- Find the fishing area the player is currently in: a shape, then the unshaped fallback.
local function findArea(player, zone)
    if not zone then
        return nil
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

-- Junk bites at 6
local function itemEntries(player, area, data)
    local entries = {}
    local bonus   = 0
    for _, itemId in ipairs(area.pool) do
        local item = data.fish[itemId]
        if confirmItemEntry(player, itemId, item) then
            table.insert(entries, { itemId, 6 })
            if item.quest then
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

-- Craft the weights for fish and items in the available pool to draw from
local function setupWeights(player, entries, itemBonus)
    local weights = {}

    if bit.band(player:getZone():getTypeMask(), xi.zoneType.CITY) ~= 0 then
        weights[xi.fishing.catchType.NOTHING] = 38
    else
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

-- Choose which pool to draw from, then choose a fish or item from that pool
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

    return nil
end

xi.fishing.biteBuckets = function(player, cast, data)
    -- Generate available pools of items and fish
    local entries          = {}
    local fish             = fishEntries(player, cast, cast.area, data)
    local items, itemBonus = itemEntries(player, cast.area, data)

    -- Populate entry list from the generated pools
    entries[xi.fishing.catchType.FISH] = fish
    entries[xi.fishing.catchType.ITEM] = items

    -- Calculate the weights for each catch type based on the entries and bonuses
    local weights, fishId = setupWeights(player, entries, itemBonus)

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
    return chooseOutcome(cast, data, xi.fishing.biteBuckets(player, cast, data))
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

-- The animation is cleared here and nowhere in the core, and the next cast is refused until it is.
xi.fishing.onInterrupt = function(player)
    local cast = xi.fishing.casts[player:getID()]
    if not cast then
        return
    end

    player:setAnimation(xi.animation.NONE)
    xi.fishing.casts[player:getID()] = nil
end
