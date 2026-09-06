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
#include "data/enums/fishing_bait_type.h"
#include "data/enums/fishing_legendary_tier.h"
#include "data/enums/fishing_size.h"

#include <cstddef>
#include <map>
#include <string>
#include <string_view>
#include <vector>

namespace xi::data
{

// One catchable fish or fished-up item. Item names resolve to ids once the item table exists.
struct FishData
{
    std::string              Name;
    bool                     Item{}; // an item rather than a fish
    xi::FishingSize          Size{};
    uint8                    Skill{}; // the skill cap the catch fights at
    xi::FishingLegendaryTier Legendary{};
    uint16                   MinLength{ 1 };
    uint16                   MaxLength{ 1 };
    uint8                    MaxHook{ 1 };
    uint16                   KeyItem{};
    uint8                    QuestLog{ 255 };
    uint8                    QuestId{ 255 };
};

struct FishingRodData
{
    std::string     Name;
    xi::FishingSize Size{};
    uint8           Time{}; // base fight time in seconds
    bool            Legendary{};
    uint8           LegendaryTime{}; // seconds added against a legendary fish
    std::string     BreaksTo;        // empty on an unbreakable rod
};

struct FishingBaitData
{
    std::string              Name;
    xi::FishingBaitType      Type{};
    uint8                    MaxHook{ 1 };
    std::vector<std::string> Affinity; // fish this bait attracts
};

struct Fishing
{
    std::map<std::string, FishData>        Fish;
    std::map<std::string, FishingRodData>  Rods;
    std::map<std::string, FishingBaitData> Baits;

    auto size() const -> std::size_t
    {
        return Fish.size() + Rods.size() + Baits.size();
    }
};

} // namespace xi::data

namespace xi::data::datasets::fishing::wire
{

struct Document;

} // namespace xi::data::datasets::fishing::wire

namespace xi::data::datasets::fishing
{

struct Dataset
{
    using Records      = xi::data::Fishing;
    using YamlDocument = wire::Document;

    static constexpr std::string_view kDataPath{ "fishing" };
    static constexpr std::string_view kTitle{ "Fishing" };
    static constexpr std::string_view kDescription{ "Every fish, fished-up item, rod and bait, and which bait attracts which fish." };

    static auto decode(std::string_view text) -> Records;
};

} // namespace xi::data::datasets::fishing
