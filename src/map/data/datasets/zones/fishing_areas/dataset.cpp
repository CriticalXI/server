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

#include "data/datasets/zones/fishing_areas/dataset.h"

#include "data/datasets/zones/fishing_areas/yaml.h"
#include "data/yaml/read.h"

#include <fmt/format.h>

#include <stdexcept>
#include <string_view>
#include <unordered_set>
#include <utility>

namespace xi::data::datasets::zones::fishing_areas
{

namespace
{

constexpr size_t kMinimumCorners = 3;

auto convertArea(const std::string& name, const wire::Area& source) -> FishingAreaData
{
    if (source.cylinder && source.poly)
    {
        throw std::runtime_error(fmt::format("area '{}' declares both a cylinder and a poly", name));
    }

    FishingAreaData area{ .Name = name, .Pool = source.pool };

    if (source.cylinder)
    {
        area.Bound  = FishingBoundKind::Cylinder;
        area.Center = source.cylinder->center;
        area.Radius = source.cylinder->radius;
    }
    else if (source.poly)
    {
        if (source.poly->size() < kMinimumCorners)
        {
            throw std::runtime_error(fmt::format("area '{}' has a poly of {} corners", name, source.poly->size()));
        }

        area.Bound   = FishingBoundKind::Polygon;
        area.Corners = *source.poly;
    }

    std::unordered_set<std::string_view> seen;
    for (const auto& item : area.Pool)
    {
        if (!seen.insert(item).second)
        {
            throw std::runtime_error(fmt::format("area '{}' pools '{}' twice", name, item));
        }
    }

    return area;
}

auto convertMonster(const uint32 spawnId, const wire::Monster& source, const std::unordered_set<std::string_view>& areas) -> FishingMonsterData
{
    FishingMonsterData monster{
        .SpawnId = spawnId,
        .Area    = source.area.value_or(std::string{}),
        .Baits   = source.bait.value_or(std::vector<std::string>{}),
    };

    if (!monster.Area.empty() && !areas.contains(monster.Area))
    {
        throw std::runtime_error(fmt::format("monster {} names area '{}', which this zone does not declare", spawnId, monster.Area));
    }

    if (source.quest)
    {
        monster.QuestLog = source.quest->log;
        monster.QuestId  = source.quest->id;
    }

    return monster;
}

} // namespace

auto Dataset::decode(const std::string_view text) -> Records
{
    const auto document = yaml::read<YamlDocument>(text);

    Records                              records;
    std::unordered_set<std::string_view> areaNames;
    if (document.areas)
    {
        records.Areas.reserve(document.areas->size());
        for (const auto& [name, source] : *document.areas)
        {
            areaNames.insert(name);
            records.Areas.push_back(convertArea(name, source));
        }
    }

    if (document.monsters)
    {
        records.Monsters.reserve(document.monsters->size());
        for (const auto& [spawnId, source] : *document.monsters)
        {
            records.Monsters.push_back(convertMonster(spawnId, source, areaNames));
        }
    }

    return records;
}

void Dataset::verifyZone(const Records& records, const xi::ZoneId zoneId)
{
    for (const auto& monster : records.Monsters)
    {
        const auto owner = (monster.SpawnId >> 12) & 0xFFF;
        if (owner != static_cast<uint32>(zoneId))
        {
            throw std::runtime_error(fmt::format("monster 0x{:08X} belongs to zone {}, not {}", monster.SpawnId, owner, static_cast<uint32>(zoneId)));
        }
    }
}

} // namespace xi::data::datasets::zones::fishing_areas
