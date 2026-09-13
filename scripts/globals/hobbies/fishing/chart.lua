-----------------------------------
-- Fishing Charts
--
-- The Pirate's Chart and Brigand's Chart quests fish their own area in place of the one the cast opened on. The Brigand's
-- Chart brings up its pugil or a Jade Etui, the one chest fishing lands.
-----------------------------------
require('scripts/globals/hobbies/fishing/data')
-----------------------------------
xi = xi or {}
xi.fishing = xi.fishing or {}
xi.fishing.chart = xi.fishing.chart or {}
-----------------------------------

-- A chest fights as a light large object.
xi.fishing.chart.chestFightStats =
{
    arrowDamage   = 320,
    arrowDelay    =  10,
    moveFrequency =  15,
    rank          =   1,
}

-- The Brigand's Chart pool: the pugil when it can be fished up and the first chest no one owns
local function brigandsChartEntries(player, cast)
    local monsters = {}
    local pugilId  = zones[xi.zone.BUBURIMU_PENINSULA].mob.PUFFER_PUGIL_BRIGAND
    local record   = cast.zone.monsters[pugilId]
    if
        record and
        xi.fishing.confirmMonsterEntry(player, record, GetMobByID(pugilId))
    then
        table.insert(monsters, { pugilId, 100 })
    end

    local chests = {}
    for _, npcId in pairs(zones[xi.zone.BUBURIMU_PENINSULA].npc.JADE_ETUI_TABLE) do
        local chest = GetNPCByID(npcId)
        if
            chest and
            chest:getLocalVar('owner') == 0
        then
            table.insert(chests, { npcId, 100 })
            break
        end
    end

    return monsters, chests
end

-- The area a chart quest in progress fishes, nil outside one
xi.fishing.chart.activeArea = function(player)
    if player:getLocalVar('pChartActive') == 1 then
        return 'pirates_chart_quest'
    elseif player:getLocalVar('bChartActive') == 1 then
        return 'brigands_chart_quest'
    end

    return nil
end

-- The bucket weights of a chart cast: the Pirate's Chart lands only its items, the Brigand's its pugil or a chest
xi.fishing.chart.weights = function(player, cast, chartArea, entries)
    local weights =
    {
        [xi.fishing.catchType.NOTHING] = 0,
        [xi.fishing.catchType.FISH   ] = 0,
        [xi.fishing.catchType.ITEM   ] = 0,
        [xi.fishing.catchType.MONSTER] = 0,
        [xi.fishing.catchType.CHEST  ] = 0,
    }

    if chartArea == 'pirates_chart_quest' then
        weights[xi.fishing.catchType.ITEM] = 100

        return weights
    end

    local pugils, chests = brigandsChartEntries(player, cast)

    entries[xi.fishing.catchType.MONSTER] = pugils
    entries[xi.fishing.catchType.CHEST  ] = chests
    weights[xi.fishing.catchType.MONSTER] = #pugils > 0 and 25 or 0
    weights[xi.fishing.catchType.CHEST  ] = #chests > 0 and 75 or 0

    return weights
end

-- Sets the chest down behind the angler as theirs; false when it is gone from under the line
xi.fishing.chart.catchChest = function(player, cast)
    local chest = cast.catch.npc
    if not chest then
        return false
    end

    local radians = player:getRotPos() * math.pi / 128

    player:setAnimation(xi.animation.NEW_FISHING_CAUGHT)
    player:messageName(zones[player:getZoneID()].text.FISHING_MESSAGE_OFFSET + xi.fishingMessage.CATCH_CHEST, player, nil, nil, nil, nil, nil, true)

    chest:setPos(player:getXPos() - 2 * math.cos(radians), player:getYPos(), player:getZPos() + 2 * math.sin(radians), player:getRotPos())
    chest:setStatus(xi.status.NORMAL)
    chest:setLocalVar('owner', player:getID())

    return true
end
