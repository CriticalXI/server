/*
===========================================================================

  Copyright (c) 2026 LandSandBoat Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#pragma once

#include "common/cbasetypes.h"
#include "data/enums/zone.h"

#include <array>
#include <string>
#include <string_view>
#include <vector>

namespace xi::data
{

enum class FishingBoundKind : uint8
{
    Zone,     // anywhere in the zone
    Cylinder, // within a radius of a centre
    Polygon,  // inside a ring of corners
};

// Corners in the XZ plane, each carrying the water height under it. The ring closes implicitly.
using FishingRing = std::vector<std::array<float, 3>>;

struct FishingAreaData
{
    std::string              Name;
    FishingBoundKind         Bound{};
    std::array<float, 3>     Center{}; // cylinder centre
    uint16                   Radius{};
    FishingRing              Corners; // polygon ring
    std::vector<std::string> Pool;    // fish and item names from data/fishing.yaml
};

// A monster that can be hooked, by the spawn id it holds in this zone's mobs.yaml.
struct FishingMonsterData
{
    uint32                   SpawnId{};
    std::string              Area;  // empty means anywhere in the zone
    std::vector<std::string> Baits; // bait names, any of which hooks it; empty means any bait
    uint8                    QuestLog{ 255 };
    uint8                    QuestId{ 255 };
};

struct ZoneFishing
{
    std::vector<FishingAreaData>    Areas;
    std::vector<FishingMonsterData> Monsters;
};

} // namespace xi::data

namespace xi::data::datasets::zones::fishing_areas::wire
{

struct Document;

}

namespace xi::data::datasets::zones::fishing_areas
{

struct Dataset
{
    using Records      = xi::data::ZoneFishing;
    using YamlDocument = wire::Document;

    // Per-zone file: data/zones/<zone>/fishing_areas.yaml
    static constexpr std::string_view kDataPath{ "fishing_areas" };
    static constexpr std::string_view kTitle{ "Zone fishing areas" };
    static constexpr std::string_view kDescription{ "Where a player may fish in one zone, what bites at each spot, and the monsters that can be hooked." };

    static auto decode(std::string_view text) -> Records;
    static void verifyZone(const Records& records, xi::ZoneId zoneId);
};

} // namespace xi::data::datasets::zones::fishing_areas
