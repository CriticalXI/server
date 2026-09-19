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

// Invariants fishingutils relies on, checked against Bibiki Bay and Castle Oztroja.

#include "map/data/datasets/zones/fishing_areas/dataset.h"
#include "map/data/loader.h"

#include <catch2/catch_test_macros.hpp>

#include <algorithm>
#include <stdexcept>

namespace
{

using FishingAreasDataset = xi::data::datasets::zones::fishing_areas::Dataset;

constexpr auto kMinimal = R"(
areas:
  whole_zone:
    pool: [moat_carp]
  south_beach:
    poly:
      - [-440.0, 5.0, -860.0]
      - [-260.0, 5.0, -860.0]
      - [-260.0, 5.0, -980.0]
    pool: []
  pond:
    cylinder: {center: [172.25, -2.0, -475.286], radius: 150}
    pool:     [crayfish]
monsters:
  17396141:
    area:  pond
    bait:  [giant_shell_bug, minnow]
    quest: {log: 0, id: 91}
)";

} // namespace

TEST_CASE("fishing areas: each bound kind decodes with its geometry", "[data][fishing]")
{
    const auto records = FishingAreasDataset::decode(kMinimal);

    REQUIRE(records.Areas.size() == 3);

    const auto find = [&](const std::string_view name)
    {
        return std::ranges::find(records.Areas, name, &xi::data::FishingAreaData::Name);
    };

    const auto& whole = *find("whole_zone");
    CHECK(whole.Bound == xi::data::FishingBoundKind::Zone);
    REQUIRE(whole.Pool.size() == 1);
    CHECK(whole.Pool.front() == "moat_carp");

    const auto& beach = *find("south_beach");
    CHECK(beach.Bound == xi::data::FishingBoundKind::Polygon);
    CHECK(beach.Corners.size() == 3);
    CHECK(beach.Corners.front()[0] == -440.0f);
    CHECK(beach.Corners.front()[1] == 5.0f);
    CHECK(beach.Corners.front()[2] == -860.0f);
    CHECK(beach.Pool.empty());

    const auto& pond = *find("pond");
    CHECK(pond.Bound == xi::data::FishingBoundKind::Cylinder);
    CHECK(pond.Center[0] == 172.25f);
    CHECK(pond.Radius == 150);
}

TEST_CASE("fishing areas: a monster keeps its area, baits and quest", "[data][fishing]")
{
    const auto records = FishingAreasDataset::decode(kMinimal);

    REQUIRE(records.Monsters.size() == 1);
    const auto& monster = records.Monsters.front();
    CHECK(monster.SpawnId == 17396141);
    CHECK(monster.Area == "pond");
    REQUIRE(monster.Baits.size() == 2);
    CHECK(monster.Baits.front() == "giant_shell_bug");
    CHECK(monster.QuestLog == 0);
    CHECK(monster.QuestId == 91);
}

TEST_CASE("fishing areas: a monster in another zone's id range is rejected", "[data][fishing]")
{
    const auto records = FishingAreasDataset::decode(kMinimal);

    REQUIRE_NOTHROW(FishingAreasDataset::verifyZone(records, xi::ZoneId::CastleOztroja));
    REQUIRE_THROWS_AS(FishingAreasDataset::verifyZone(records, xi::ZoneId::WestRonfaure), std::runtime_error);
}

TEST_CASE("fishing areas: bad shapes are rejected", "[data][fishing]")
{
    constexpr auto bothBounds = R"(
areas:
  spot:
    cylinder: {center: [0.0, 0.0, 0.0], radius: 10}
    poly:     [[0.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 1.0]]
    pool:     []
)";
    REQUIRE_THROWS_AS(FishingAreasDataset::decode(bothBounds), std::runtime_error);

    constexpr auto twoCorners = R"(
areas:
  spot:
    poly: [[0.0, 0.0, 0.0], [1.0, 0.0, 0.0]]
    pool: []
)";
    REQUIRE_THROWS_AS(FishingAreasDataset::decode(twoCorners), std::runtime_error);

    constexpr auto twice = R"(
areas:
  spot:
    pool: [moat_carp, moat_carp]
)";
    REQUIRE_THROWS_AS(FishingAreasDataset::decode(twice), std::runtime_error);

    constexpr auto unknownArea = R"(
areas:
  spot:
    pool: []
monsters:
  17396141:
    area: elsewhere
)";
    REQUIRE_THROWS_AS(FishingAreasDataset::decode(unknownArea), std::runtime_error);
}

TEST_CASE("fishing areas: Bibiki Bay draws its beaches and Castle Oztroja keeps its quest spot", "[data][fishing]")
{
    const auto bibiki = xi::data::loadZoneFile<FishingAreasDataset>(xi::ZoneId::BibikiBay);
    REQUIRE(bibiki.has_value());
    REQUIRE(bibiki->Areas.size() == 6);

    const auto southBeach = std::ranges::find(bibiki->Areas, "pi_south_beach", &xi::data::FishingAreaData::Name);
    REQUIRE(southBeach != bibiki->Areas.end());
    CHECK(southBeach->Bound == xi::data::FishingBoundKind::Polygon);
    CHECK(southBeach->Corners.size() == 4);
    CHECK(southBeach->Pool.size() == 14);

    const auto oztroja = xi::data::loadZoneFile<FishingAreasDataset>(xi::ZoneId::CastleOztroja);
    REQUIRE(oztroja.has_value());
    REQUIRE(oztroja->Areas.size() == 2);
    REQUIRE(oztroja->Monsters.size() == 1);

    const auto spot = std::ranges::find(oztroja->Areas, "pld_af_fishing_spot", &xi::data::FishingAreaData::Name);
    REQUIRE(spot != oztroja->Areas.end());
    CHECK(spot->Pool.empty());

    const auto& odontotyrannus = oztroja->Monsters.front();
    CHECK(odontotyrannus.SpawnId == 17396141);
    CHECK(odontotyrannus.Area == "pld_af_fishing_spot");
    REQUIRE(odontotyrannus.Baits.size() == 1);
    CHECK(odontotyrannus.Baits.front() == "giant_shell_bug");
}
