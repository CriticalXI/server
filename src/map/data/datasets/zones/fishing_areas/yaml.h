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
#include "data/yaml/schema_annotations.h"

#include <glaze/glaze.hpp>

#include <array>
#include <map>
#include <optional>
#include <string>
#include <vector>

namespace xi::data::datasets::zones::fishing_areas::wire
{

struct Cylinder
{
    std::array<float, 3> center;
    uint16               radius;
};

// A ring of x, y, z corners, the same shape a roam region uses; it closes implicitly.
using Ring = std::vector<std::array<float, 3>>;

struct Area
{
    std::optional<Cylinder>  cylinder;
    std::optional<Ring>      poly;
    std::vector<std::string> pool;
};

struct Quest
{
    uint8 log;
    uint8 id;
};

struct Monster
{
    std::optional<std::string>              area;
    std::optional<std::vector<std::string>> bait;
    std::optional<Quest>                    quest;
};

struct Document
{
    std::optional<std::map<std::string, Area>> areas;
    std::optional<std::map<uint32, Monster>>   monsters;
};

} // namespace xi::data::datasets::zones::fishing_areas::wire

template <>
struct glz::json_schema<xi::data::datasets::zones::fishing_areas::wire::Cylinder>
{
    glz::schema center{ .description = "Centre of the spot as x, y, z." };
    glz::schema radius{ .description = "How far from the centre a player may stand.", .minimum = 1L, .maximum = 65535L };
};

template <>
struct glz::json_schema<xi::data::datasets::zones::fishing_areas::wire::Area>
{
    glz::schema cylinder{ .description = "Round spot: a centre and a radius. Omit both cylinder and poly for the whole zone." };
    glz::schema poly{ .description = "Spot drawn as a ring of x, y, z corners in order, as a roam region is. Closes implicitly. Omit both cylinder and poly for the whole zone." };
    glz::schema pool{ .description = "What bites here, by fish or item name from data/fishing.yaml. Empty means only monsters bite." };
};

template <>
struct glz::json_schema<xi::data::datasets::zones::fishing_areas::wire::Quest>
{
    glz::schema log{ .description = "Quest log the monster is tied to.", .minimum = 0L, .maximum = 255L };
    glz::schema id{ .description = "Quest id within that log. The monster only bites while the quest is accepted.", .minimum = 0L, .maximum = 255L };
};

template <>
struct glz::json_schema<xi::data::datasets::zones::fishing_areas::wire::Monster>
{
    glz::schema area{ .description = "Only bites from this area, by key. Omitted means anywhere in the zone." };
    glz::schema bait{ .description = "Baits that hook it, by name from data/fishing.yaml. Omitted means any bait." };
    glz::schema quest{ .description = "Quest the monster is tied to. Omitted means it always bites." };
};

template <>
struct glz::json_schema<xi::data::datasets::zones::fishing_areas::wire::Document>
{
    glz::schema areas{ .description = "Fishing spots keyed by name." };
    glz::schema monsters{ .description = "Monsters that can be hooked, keyed by their spawn id in this zone's mobs.yaml." };
};
