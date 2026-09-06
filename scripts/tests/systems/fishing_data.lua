describe('Fishing data', function()
    local function count(t)
        local n = 0
        for _ in pairs(t) do
            n = n + 1
        end

        return n
    end

    it('hands Lua every table the YAML holds', function()
        local data = xi.fishing.getData()

        assert(count(data.fish) == 137)
        assert(count(data.rods) == 20)
        assert(count(data.baits) == 39)
        assert(count(data.zones) == 98)
    end)

    it('keys the catalog by item id and keeps absent fields absent', function()
        local data = xi.fishing.getData()

        local carp = data.fish[xi.item.MOAT_CARP_1]
        assert(carp)
        assert(carp.name == 'moat_carp')
        assert(carp.size == xi.fishingSize.SMALL)
        assert(carp.skill == 11)
        assert(carp.maxHook == nil)
        assert(carp.legendary == nil)
        assert(carp.length == nil)
        assert(carp.item == nil)

        local sardine = data.fish[xi.item.BASTORE_SARDINE_1]
        assert(sardine.maxHook == 3)

        local lik = data.fish[xi.item.LIK]
        assert(lik.legendary == xi.fishingLegendaryTier.SUPER)
        assert(lik.length[1] == 185 and lik.length[2] == 460)
        assert(lik.keyItem == xi.ki.SERPENT_RUMORS)

        local bucket = data.fish[xi.item.RUSTY_BUCKET]
        assert(bucket.item == true)

        local willow = data.rods[xi.item.WILLOW_FISHING_ROD]
        assert(willow.size == xi.fishingSize.SMALL)
        assert(willow.time == 30)
        assert(willow.breaksTo == xi.item.BROKEN_WILLOW_FISHING_ROD)
        assert(willow.legendary == nil)

        local ebisu = data.rods[xi.item.EBISU_FISHING_ROD]
        assert(ebisu.legendary == true)
        assert(ebisu.breaksTo == nil)

        local rig = data.baits[xi.item.SABIKI_RIG]
        assert(rig.type == xi.fishingBaitType.LURE)
        assert(rig.maxHook == 3)
        assert(rig.affinity[xi.item.BASTORE_SARDINE_1] == true)
        assert(rig.affinity[xi.item.MOAT_CARP_1] == nil)
    end)

    it('resolves a zone file to ids and area names', function()
        local data    = xi.fishing.getData()
        local oztroja = data.zones[xi.zone.CASTLE_OZTROJA]
        assert(oztroja)

        local spot = oztroja.areas.pld_af_fishing_spot
        assert(spot.cylinder.radius == 15)
        assert(#spot.pool == 0)

        local whole = oztroja.areas.whole_zone
        assert(whole.cylinder == nil and whole.poly == nil)
        assert(#whole.pool == 1 and whole.pool[1] == xi.item.CRAYFISH_1)

        local odontotyrannus = oztroja.monsters[17396141]
        assert(odontotyrannus.area == 'pld_af_fishing_spot')
        assert(odontotyrannus.bait[xi.item.GIANT_SHELL_BUG] == true)
        assert(odontotyrannus.quest.log == xi.questLog.SANDORIA)
        assert(odontotyrannus.quest.id == 91)

        local bibiki = data.zones[xi.zone.BIBIKI_BAY]
        assert(#bibiki.areas.pi_south_beach.poly == 4)
        assert(#bibiki.areas.pi_south_beach.pool == 14)
    end)

    it('tests a position against an area shape', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE })
        local data   = xi.fishing.getData()
        local bibiki = data.zones[xi.zone.BIBIKI_BAY]
        local beach  = bibiki.areas.pi_south_beach
        local north  = bibiki.areas.pi_north_beach

        player:setPos(-350, 0, -920, 0)
        assert(player:isInsidePoly(beach.poly))
        assert(not player:isInsideCylinder(north.cylinder.x, north.cylinder.z, north.cylinder.radius))

        player:setPos(north.cylinder.x + 10, 0, north.cylinder.z - 10, 0)
        assert(player:isInsideCylinder(north.cylinder.x, north.cylinder.z, north.cylinder.radius))
        assert(not player:isInsidePoly(beach.poly))

        player:setPos(0, 0, 0, 0)
        assert(not player:isInsidePoly(beach.poly))
        assert(not player:isInsideCylinder(north.cylinder.x, north.cylinder.z, north.cylinder.radius))
    end)
end)
