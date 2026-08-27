-----------------------------------
-- Pernicious Presents: Twinkling Treant world event
-- Treants spawn in 12 outdoor zones. Outpost teleportation is disabled until every treant is defeated.
--
-- Participation: talk to a Moogle in an event zone for a menu to select whether or not to get level capped
-----------------------------------
require('modules/module_utils')
require('scripts/globals/conquest')
-----------------------------------
local m = Module:new('pernicious_presents_event')

xi.treantEvent = {}

xi.treantEvent.zones =
{
    [xi.zone.WEST_RONFAURE] =
    {
        zone    = 'West Ronfaure',
        cap     = 20,
        level   = 25,
        hp      = 1000000,
        treant  = { x = -205.957, y = -29.763, z = -78.954, rot = 140 },
        moogles =
        {
            { x = -159.469, y = -60.000, z = 287.445, rot = 95 },
            { x = -444.657, y = -19.717, z = -229.431, rot = 249 },
        },
    },

    [xi.zone.EAST_RONFAURE] =
    {
        zone    = 'East Ronfaure',
        cap     = 20,
        level   = 25,
        hp      = 1000000,
        treant  = { x = 233.153, y = -39.673, z = -36.117, rot = 50 },
        moogles =
        {
            { x = 90.215, y = -59.628, z = 244.967, rot = 32 },
        },
    },

    [xi.zone.NORTH_GUSTABERG] =
    {
        zone    = 'North Gustaberg',
        cap     = 20,
        level   = 25,
        hp      = 1000000,
        treant  = { x = 126.169, y = -0.398, z = 275.801, rot = 158 },
        moogles =
        {
            { x = 650.115, y = 0.791, z = 313.710, rot = 190 },
        },
    },

    [xi.zone.SOUTH_GUSTABERG] =
    {
        zone    = 'South Gustaberg',
        cap     = 20,
        level   = 25,
        hp      = 1000000,
        treant  = { x = 648.038, y = -0.097, z = -629.929, rot = 145 },
        moogles =
        {
            { x = 569.953, y = 0.750, z = -313.742, rot = 59 },
            { x = 269.926, y = 0.786, z = -193.579, rot = 66 },
        },
    },

    [xi.zone.WEST_SARUTABARUTA] =
    {
        zone    = 'West Sarutabaruta',
        cap     = 20,
        level   = 25,
        hp      = 1000000,
        treant  = { x = 161.778, y = -40.296, z = 351.301, rot = 165 },
        moogles =
        {
            { x = 328.826, y = -5.102, z = -24.946, rot = 193 },
            { x = 146.534, y = -1.215, z = -310.803, rot = 125 },
            { x = -13.744, y = -13.239, z = 304.462, rot = 133 },
        },
    },

    [xi.zone.EAST_SARUTABARUTA] =
    {
        zone    = 'East Sarutabaruta',
        cap     = 20,
        level   = 25,
        hp      = 1000000,
        treant  = { x = -82.263, y = -12.000, z = 239.083, rot = 27 },
        moogles =
        {
            { x = -107.710, y = -4.617, z = -514.857, rot = 32 },
        },
    },

    [xi.zone.JUGNER_FOREST] =
    {
        zone    = 'Jugner Forest',
        cap     = 30,
        level   = 35,
        hp      = 2000000,
        treant  = { x = 44.825, y = 0.040, z = 319.385, rot = 81 },
        moogles =
        {
            { x = 71.307, y = 0.371, z = -6.767, rot = 194 },
        },
    },

    [xi.zone.PASHHOW_MARSHLANDS] =
    {
        zone    = 'Pashhow Marshlands',
        cap     = 30,
        level   = 35,
        hp      = 2000000,
        treant  = { x = 28.153, y = 25.000, z = 269.762, rot = 229 },
        moogles =
        {
            { x = 459.875, y = 23.900, z = 416.001, rot = 230 },
        },
    },

    [xi.zone.MERIPHATAUD_MOUNTAINS] =
    {
        zone    = 'Meriphataud Mountains',
        cap     = 30,
        level   = 35,
        hp      = 2000000,
        treant  = { x = -73.930, y = 7.981, z = -48.123, rot = 36 },
        moogles =
        {
            { x = -284.334, y = 16.016, z = 404.335, rot = 121 },
        },
    },

    [xi.zone.BEAUCEDINE_GLACIER] =
    {
        zone    = 'Beaucedine Glacier',
        cap     = 50,
        level   = 55,
        hp      = 3500000,
        treant  = { x = 117.315, y = -40.000, z = 43.556, rot = 131 },
        moogles =
        {
            { x = -25.714, y = -59.376, z = -119.901, rot = 241 },
        },
    },

    [xi.zone.EASTERN_ALTEPA_DESERT] =
    {
        zone    = 'Eastern Altepa Desert',
        cap     = 50,
        level   = 55,
        hp      = 3500000,
        treant  = { x = 51.956, y = -7.638, z = -92.371, rot = 14 },
        moogles =
        {
            { x = -268.815, y = 8.372, z = -244.628, rot = 192 },
            { x = -67.786, y = 3.949, z = 215.968, rot = 189 },
        },
    },

    [xi.zone.YUHTUNGA_JUNGLE] =
    {
        zone    = 'Yuhtunga Jungle',
        cap     = 50,
        level   = 55,
        hp      = 3500000,
        treant  = { x = -602.209, y = 0.000, z = -38.758, rot = 10 },
        moogles =
        {
            { x = -249.483, y = 0.373, z = -397.918, rot = 185 },
            { x = -232.701, y = 0.000, z = 517.715, rot = 60 },
        },
    },
}

xi.treantEvent.cityTeleporters =
{
    [xi.zone.NORTHERN_SAN_DORIA] = 17723597, -- Jeanvirgaud
    [xi.zone.BASTOK_MINES      ] = 17735859, -- Conrad
    [xi.zone.PORT_WINDURST     ] = 17760439, -- Rottata
}

xi.treantEvent.countRemaining = function()
    local remaining = 0

    for zoneId, _ in pairs(xi.treantEvent.zones) do
        if GetServerVariable('[TreantEvent]Dead_' .. zoneId) == 0 then
            remaining = remaining + 1
        end
    end

    return remaining
end

xi.treantEvent.setTeleporterStatus = function(zoneId, status)
    local npcId = xi.treantEvent.cityTeleporters[zoneId]

    if
        not npcId or
        not GetZone(zoneId)
    then
        return
    end

    local npc = GetNPCByID(npcId)
    if npc then
        npc:setStatus(status)
    end
end

xi.treantEvent.spawnMoogles = function(zone, zoneId, entry)
    for i, pos in ipairs(entry.moogles) do
        local npc = zone:insertDynamicEntity({
            objtype    = xi.objType.NPC,
            name       = string.format('Treant_Moogle_%i', i),
            packetName = 'Festive Moogle',
            look       = 82,
            x          = pos.x,
            y          = pos.y,
            z          = pos.z,
            rotation   = pos.rot,
            releaseIdOnDisappear = true,

            onTrigger = function(player, npc)
                npc:facePlayer(player, true)

                local restriction = player:getStatusEffect(xi.effect.LEVEL_RESTRICTION)

                if
                    restriction and
                    restriction:getPower() ~= entry.cap
                then
                    player:printToPlayer('You are already bound by another engagement, kupo. Settle that business first!', xi.msg.channel.SAY, npc:getPacketName())
                    return
                end

                if restriction then
                    local pet = player:getPet()
                    if pet then
                        pet:delStatusEffect(xi.effect.LEVEL_RESTRICTION)
                    end

                    player:delStatusEffect(xi.effect.LEVEL_RESTRICTION)
                    player:printToPlayer('Your participation is withdrawn, kupo. Come back if you change your mind!', xi.msg.channel.SAY, npc:getPacketName())

                    return
                end

                local speaker = npc:getPacketName()

                player:printToPlayer('Hello hello, kupo! I can help you join in the fight to defeat the pernicious Twinkling Treants!', xi.msg.channel.SAY, speaker)

                player:customMenu({
                    title   = string.format('Join the fight at level %i?', entry.cap),
                    options =
                    {
                        {
                            'Yes, kupo!',
                            function(playerArg)
                                if GetServerVariable('[TreantEvent]Dead_' .. zoneId) ~= 0 then
                                    playerArg:printToPlayer('The Twinkling Treant here has already fallen, kupo!', xi.msg.channel.SAY, speaker)
                                    return
                                end

                                playerArg:addStatusEffect(xi.effect.LEVEL_RESTRICTION, {
                                    power    = entry.cap,
                                    subPower = 1, -- exp for other kills uses real level
                                    origin   = playerArg,
                                    flag     = xi.effectFlag.ON_ZONE + xi.effectFlag.CONFRONTATION,
                                })

                                -- pets summoned after the grant inherit the effect,
                                -- an existing pet needs it added directly
                                local pet = playerArg:getPet()
                                if pet then
                                    pet:addStatusEffect(xi.effect.LEVEL_RESTRICTION, {
                                        power  = entry.cap,
                                        origin = pet,
                                        flag   = xi.effectFlag.CONFRONTATION,
                                    })
                                end

                                playerArg:printToPlayer(string.format('You now hold the right to face the Twinkling Treant, kupo! Your level is restricted to %i until you speak with me again or leave the zone.', entry.cap), xi.msg.channel.SAY, speaker)
                            end,
                        },
                        {
                            'Not yet.',
                            function(playerArg)
                                playerArg:printToPlayer('Come back when you are ready, kupo!', xi.msg.channel.SAY, speaker)
                            end,
                        },
                    },
                })
            end,
        })

        if npc then
            zone:setLocalVar('[TreantEvent]MoogleId' .. i, npc:getID())
        end
    end
end

xi.treantEvent.spawnTreant = function(zone, zoneId, entry)
    local mob = zone:insertDynamicEntity({
        objtype     = xi.objType.MOB,
        name        = 'Twinkling_Treant',
        packetName  = 'TwinklingTreant',
        x           = entry.treant.x,
        y           = entry.treant.y,
        z           = entry.treant.z,
        rotation    = entry.treant.rot,
        groupId     = 200,
        groupZoneId = 100,
        minLevel    = entry.level,
        maxLevel    = entry.level,
        releaseIdOnDisappear  = true,
        specialSpawnAnimation = true,

        onMobSpawn = function(mob)
            mob:setMaxHP(entry.hp)

            local savedHP = GetServerVariable('[TreantEvent]HP_' .. zoneId)
            if savedHP > 0 then
                mob:setHP(savedHP)
            else
                mob:setHP(entry.hp)
            end

            mob:setDropID(0)
            mob:setMobMod(xi.mobMod.NO_REST, 1)
            mob:setMobMod(xi.mobMod.NO_DROPS, 1)
            mob:setMobMod(xi.mobMod.NO_AGGRO, 1)
            mob:setMobMod(xi.mobMod.NO_SPELL_COST, 1)
            mob:setMobMod(xi.mobMod.EXP_BONUS, -100)
            mob:setMobMod(xi.mobMod.GIL_MAX, -1)
            mob:setMobMod(xi.mobMod.CHARMABLE, 0)
            mob:setMobMod(xi.mobMod.CLAIM_TYPE, xi.claimType.NON_EXCLUSIVE)
            mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
            mob:setCallForHelpBlocked(true)

            mob:addStatusEffect(xi.effect.LEVEL_RESTRICTION, {
                power  = entry.cap,
                origin = mob,
                flag   = xi.effectFlag.CONFRONTATION,
            })
        end,

        onMobMobskillChoose = function(mob, target)
            local skills =
            {
                xi.mobSkill.DRILL_BRANCH,
                xi.mobSkill.PINECONE_BOMB,
                xi.mobSkill.ENTANGLE_DRAIN,
                1026, -- arbor_storm
            }

            return skills[math.randomInt(1, #skills)]
        end,

        -- the placeholder spell list only carries a buff, so leave the idle
        -- cast alone and force sleepga in combat
        onMobSpellChoose = function(mob, target)
            return xi.magic.spell.SLEEPGA
        end,

        -- Crash insurance: persist mob HP once per minute while engaged
        onMobFight = function(mob, target)
            if mob:getLocalVar('[TreantEvent]NextHPSave') > GetSystemTime() then
                return
            end

            mob:setLocalVar('[TreantEvent]NextHPSave', GetSystemTime() + 60)
            SetServerVariable('[TreantEvent]HP_' .. zoneId, mob:getHP())
        end,

        onMobDisengage = function(mob)
            SetServerVariable('[TreantEvent]HP_' .. zoneId, mob:getHP())
        end,

        -- On death: Hide moogles, wipe level restriction, announce death
        onMobDeath = function(mob, player, optParams)
            if
                not optParams.isKiller and
                not optParams.noKiller
            then
                return
            end

            if GetServerVariable('[TreantEvent]Dead_' .. zoneId) ~= 0 then
                return
            end

            SetServerVariable('[TreantEvent]Dead_' .. zoneId, GetSystemTime())
            SetServerVariable('[TreantEvent]HP_' .. zoneId, 0)

            local treantZone = mob:getZone()

            for i = 1, #entry.moogles do
                local moogle = GetNPCByID(treantZone:getLocalVar('[TreantEvent]MoogleId' .. i))
                if moogle then
                    moogle:setStatus(xi.status.DISAPPEAR)
                end

                treantZone:setLocalVar('[TreantEvent]MoogleId' .. i, 0)
            end

            treantZone:setLocalVar('[TreantEvent]MobId', 0)

            for _, member in pairs(treantZone:getPlayers()) do
                local restriction = member:getStatusEffect(xi.effect.LEVEL_RESTRICTION)
                if
                    restriction and
                    restriction:getPower() == entry.cap
                then
                    local pet = member:getPet()
                    if pet then
                        pet:delStatusEffect(xi.effect.LEVEL_RESTRICTION)
                    end

                    member:delStatusEffect(xi.effect.LEVEL_RESTRICTION)
                end
            end

            local announcer = player or treantZone:getPlayers()[1]

            local remaining = xi.treantEvent.countRemaining()

            if remaining > 0 then
                if announcer then
                    local message = string.format("The Twinkling Treant of %s has fallen, kupo! Only %i remain across Vana'diel!", entry.zone, remaining)

                    if remaining == 1 then
                        message = string.format("The Twinkling Treant of %s has fallen! Just ONE treant remains... we're almost there, kupo!", entry.zone)
                    end

                    announcer:printToArea(message, xi.msg.channel.SYSTEM_3, xi.msg.area.SYSTEM, '', false)
                end

                return
            end

            SetServerVariable('[TreantEvent]Complete', GetSystemTime())

            if announcer then
                announcer:printToArea('The last Twinkling Treant has fallen, kupo! Outpost teleportation services have been restored across Vana\'diel!', xi.msg.channel.SYSTEM_3, xi.msg.area.SYSTEM, '', false)
            end

            for cityZoneId in pairs(xi.treantEvent.cityTeleporters) do
                SendLuaFuncStringToZone(zoneId, cityZoneId, string.format('xi.treantEvent.setTeleporterStatus(%i, %i)', cityZoneId, xi.status.NORMAL))
            end
        end,
    })

    if not mob then
        return
    end

    mob:setSpawn(entry.treant.x, entry.treant.y, entry.treant.z, entry.treant.rot)
    mob:spawn()
    zone:setLocalVar('[TreantEvent]MobId', mob:getID())
end

xi.treantEvent.startZone = function(zoneId)
    local zone  = GetZone(zoneId)
    local entry = xi.treantEvent.zones[zoneId]

    if
        not zone or
        not entry or
        GetServerVariable('[TreantEvent]Dead_' .. zoneId) ~= 0
    then
        return
    end

    if zone:getLocalVar('[TreantEvent]MoogleId1') == 0 then
        xi.treantEvent.spawnMoogles(zone, zoneId, entry)
    end

    local mobId = zone:getLocalVar('[TreantEvent]MobId')
    if mobId ~= 0 then
        local existing = GetMobByID(mobId)
        if
            existing and
            existing:isSpawned()
        then
            return
        end
    end

    xi.treantEvent.spawnTreant(zone, zoneId, entry)
end

m:addOverride('xi.server.onServerStart', function()
    super()

    -- Inactive until launched with !treants start
    if GetServerVariable('[TreantEvent]Started') == 0 then
        return
    end

    for zoneId in pairs(xi.treantEvent.zones) do
        xi.treantEvent.startZone(zoneId)
    end

    -- Hide the city outpost teleporter NPCs while the event runs
    if GetServerVariable('[TreantEvent]Complete') == 0 then
        for zoneId in pairs(xi.treantEvent.cityTeleporters) do
            xi.treantEvent.setTeleporterStatus(zoneId, xi.status.DISAPPEAR)
        end
    end
end)

-- Forcibly only show the vendor menu while outposts are disabled
m:addOverride('xi.conquest.vendorOnTrigger', function(player, vendorRegion, vendorEvent)
    if
        GetServerVariable('[TreantEvent]Complete') == 0 and
        GetServerVariable('[TreantEvent]Started') ~= 0
    then
        local pNation = player:getNation()
        local owner   = GetRegionOwner(vendorRegion)
        local nation  = 0

        if owner == pNation then
            nation = 1
        elseif xi.conquest.areAllies(pNation, owner) then
            nation = 2
        end

        player:startEvent(vendorEvent, nation, 0, 0, 0, player:getCP(), 0, 0, 0)
        return
    end

    super(player, vendorRegion, vendorEvent)
end)

m:addOverride('xi.conquest.vendorOnEventFinish', function(player, option, vendorRegion)
    if
        GetServerVariable('[TreantEvent]Complete') == 0 and
        GetServerVariable('[TreantEvent]Started') ~= 0 and
        option == 1
    then
        xi.shop.outpost(player)

        return
    end

    super(player, option, vendorRegion)
end)

return m
