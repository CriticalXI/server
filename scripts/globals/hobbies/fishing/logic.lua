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
