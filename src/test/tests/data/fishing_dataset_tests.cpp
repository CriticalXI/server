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

// Invariants fishingutils relies on when reading data/fishing.yaml.

#include "map/data/datasets/fishing/dataset.h"
#include "map/utils/dataset_loader.h"

#include <catch2/catch_test_macros.hpp>

#include <stdexcept>

namespace
{

using FishingDataset = xi::data::datasets::fishing::Dataset;

constexpr auto kMinimal = R"(
fishing:
  fish:
    moat_carp:
      size:     small
      skill:    11
      max_hook: 3
    rusty_bucket:
      item:   true
      size:   large
      skill:  1
      length: [1, 3]
    lik:
      size:      large
      skill:     140
      legendary: super
      length:    [185, 460]
      key_item:  1977
  rods:
    willow_fishing_rod:
      size:      small
      time:      30
      breaks_to: broken_willow_fishing_rod
    ebisu_fishing_rod:
      size:           small
      time:           30
      legendary:      true
      legendary_time: 10
  baits:
    sabiki_rig:
      type:     lure
      max_hook: 3
      affinity: [moat_carp]
)";

auto fishing() -> const xi::data::Fishing*
{
    static const auto loaded = xi::data::loadDataset<FishingDataset>();
    return &loaded;
}

} // namespace

TEST_CASE("fishing: a fish keeps its cap, size, tier and length", "[data][fishing]")
{
    const auto records = FishingDataset::decode(kMinimal);

    REQUIRE(records.Fish.size() == 3);
    REQUIRE(records.Rods.size() == 2);
    REQUIRE(records.Baits.size() == 1);

    const auto& carp = records.Fish.at("moat_carp");
    CHECK(carp.Item == false);
    CHECK(carp.Size == xi::FishingSize::Small);
    CHECK(carp.Skill == 11);
    CHECK(carp.Legendary == xi::FishingLegendaryTier::None);
    CHECK(carp.MinLength == 1);
    CHECK(carp.MaxLength == 1);
    CHECK(carp.MaxHook == 3);
    CHECK(carp.QuestLog == 255);

    const auto& bucket = records.Fish.at("rusty_bucket");
    CHECK(bucket.Item == true);
    CHECK(bucket.MinLength == 1);
    CHECK(bucket.MaxLength == 3);

    const auto& lik = records.Fish.at("lik");
    CHECK(lik.Legendary == xi::FishingLegendaryTier::Super);
    CHECK(lik.KeyItem == 1977);
}

TEST_CASE("fishing: a rod is breakable only when it names a broken rod", "[data][fishing]")
{
    const auto records = FishingDataset::decode(kMinimal);

    const auto& willow = records.Rods.at("willow_fishing_rod");
    CHECK(willow.Size == xi::FishingSize::Small);
    CHECK(willow.Time == 30);
    CHECK(willow.BreaksTo == "broken_willow_fishing_rod");
    CHECK(willow.Legendary == false);

    const auto& ebisu = records.Rods.at("ebisu_fishing_rod");
    CHECK(ebisu.BreaksTo.empty());
    CHECK(ebisu.Legendary == true);
    CHECK(ebisu.LegendaryTime == 10);
}

TEST_CASE("fishing: bait affinity names a fish in the same file", "[data][fishing]")
{
    const auto records = FishingDataset::decode(kMinimal);

    const auto& rig = records.Baits.at("sabiki_rig");
    CHECK(rig.Type == xi::FishingBaitType::Lure);
    CHECK(rig.MaxHook == 3);
    REQUIRE(rig.Affinity.size() == 1);
    CHECK(rig.Affinity.front() == "moat_carp");

    constexpr auto unknownFish = R"(
fishing:
  fish: {}
  rods: {}
  baits:
    sabiki_rig:
      type:     lure
      affinity: [moat_carp]
)";

    REQUIRE_THROWS_AS(FishingDataset::decode(unknownFish), std::runtime_error);
}

TEST_CASE("fishing: an inverted length is rejected", "[data][fishing]")
{
    constexpr auto badLength = R"(
fishing:
  fish:
    lik:
      size:   large
      skill:  140
      length: [460, 185]
  rods: {}
  baits: {}
)";

    REQUIRE_THROWS_AS(FishingDataset::decode(badLength), std::runtime_error);
}

TEST_CASE("fishing: the shipped catalog carries every table the SQL held", "[data][fishing]")
{
    const auto& records = *fishing();

    CHECK(records.Fish.size() == 137);
    CHECK(records.Rods.size() == 20);
    CHECK(records.Baits.size() == 39);

    size_t affinities = 0;
    for (const auto& [name, bait] : records.Baits)
    {
        affinities += bait.Affinity.size();
    }
    CHECK(affinities == 617);

    CHECK(records.Fish.at("gugrusaurus").Legendary == xi::FishingLegendaryTier::Super);
    CHECK(records.Fish.at("cave_cherax").Legendary == xi::FishingLegendaryTier::Basic);

    const auto& luShang = records.Rods.at("lu_shangs_fishing_rod");
    CHECK(luShang.BreaksTo == "broken_lu_shangs_fishing_rod");
    CHECK(luShang.Legendary == true);
}
