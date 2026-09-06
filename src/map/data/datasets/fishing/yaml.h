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
#include "data/yaml/enum_token.h"
#include "data/yaml/schema_annotations.h"

#include <glaze/glaze.hpp>

#include <array>
#include <map>
#include <optional>
#include <string>
#include <vector>

namespace xi::data::datasets::fishing::wire
{

struct Quest
{
    uint8 log;
    uint8 id;
};

struct Fish
{
    std::optional<bool>                                      item;
    yaml::EnumToken<xi::FishingSize>                         size;
    uint8                                                    skill;
    std::optional<yaml::EnumToken<xi::FishingLegendaryTier>> legendary;
    std::optional<std::array<uint16, 2>>                     length;
    std::optional<uint8>                                     max_hook;
    std::optional<uint16>                                    key_item;
    std::optional<Quest>                                     quest;
};

struct Rod
{
    yaml::EnumToken<xi::FishingSize> size;
    uint8                            time;
    std::optional<bool>              legendary;
    std::optional<uint8>             legendary_time;
    std::optional<std::string>       breaks_to;
};

struct Bait
{
    yaml::EnumToken<xi::FishingBaitType>    type;
    std::optional<uint8>                    max_hook;
    std::optional<std::vector<std::string>> affinity;
};

struct Catalog
{
    std::map<std::string, Fish> fish;
    std::map<std::string, Rod>  rods;
    std::map<std::string, Bait> baits;
};

struct Document
{
    Catalog fishing;

    using YamlRoot = yaml::DatasetRoot<&Document::fishing>;
};

} // namespace xi::data::datasets::fishing::wire

template <>
struct glz::json_schema<xi::data::datasets::fishing::wire::Quest>
{
    glz::schema log{ .description = "Quest log the catch belongs to.", .minimum = 0L, .maximum = 255L };
    glz::schema id{ .description = "Quest id within that log. The catch only bites while the quest is accepted.", .minimum = 0L, .maximum = 255L };
};

template <>
struct glz::json_schema<xi::data::datasets::fishing::wire::Fish>
{
    glz::schema item{ .description = "True for a fished-up item rather than a fish." };
    glz::schema size{ .description = "Small fish are held by small rods, large fish by large rods." };
    glz::schema skill{ .description = "The skill cap the catch fights at.", .minimum = 0L, .maximum = 255L };
    glz::schema legendary{ .description = "Legendary tier. Omitted for an ordinary fish." };
    glz::schema length{ .description = "Minimum and maximum length in Ilms. Omitted means the catch has no size." };
    glz::schema max_hook{ .description = "How many can come up on one sabiki rig. Defaults to 1.", .minimum = 1L, .maximum = 255L };
    glz::schema key_item{ .description = "Key item id the player must hold for the catch to bite.", .minimum = 1L, .maximum = 65535L };
    glz::schema quest{ .description = "Quest the catch is tied to. Omitted means it always bites." };
};

template <>
struct glz::json_schema<xi::data::datasets::fishing::wire::Rod>
{
    glz::schema size{ .description = "Small rods hold small fish, large rods hold large fish." };
    glz::schema time{ .description = "Base fight time in seconds.", .minimum = 0L, .maximum = 255L };
    glz::schema legendary{ .description = "A legendary rod: the Ebisu and Lu Shang's line." };
    glz::schema legendary_time{ .description = "Seconds added against a legendary fish.", .minimum = 0L, .maximum = 255L };
    glz::schema breaks_to{ .description = "Item the rod becomes when it breaks. Omitted means the rod cannot break." };
};

template <>
struct glz::json_schema<xi::data::datasets::fishing::wire::Bait>
{
    glz::schema type{ .description = "Bait is consumed, a lure is kept, a special bait is one-shot for a specific catch." };
    glz::schema max_hook{ .description = "How many fish it can hook at once. Defaults to 1.", .minimum = 1L, .maximum = 255L };
    glz::schema affinity{ .description = "Fish this bait attracts, by name." };
};

template <>
struct glz::json_schema<xi::data::datasets::fishing::wire::Catalog>
{
    glz::schema fish{ .description = "Fish and fished-up items keyed by item name." };
    glz::schema rods{ .description = "Rods keyed by item name." };
    glz::schema baits{ .description = "Baits and lures keyed by item name." };
};

template <>
struct glz::json_schema<xi::data::datasets::fishing::wire::Document>
{
    glz::schema fishing{ .description = "The fishing catalog." };
};
