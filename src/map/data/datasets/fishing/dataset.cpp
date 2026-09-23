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

#include "data/datasets/fishing/dataset.h"

#include "data/datasets/fishing/yaml.h"
#include "data/yaml/read.h"

#include <fmt/format.h>

#include <stdexcept>
#include <string_view>
#include <unordered_set>
#include <utility>

namespace xi::data::datasets::fishing
{

namespace
{

auto convertFish(const std::string& name, const wire::Fish& source) -> FishData
{
    FishData fish{
        .Name      = name,
        .Item      = source.item.value_or(false),
        .Size      = yaml::resolveEnum(source.size),
        .Skill     = source.skill,
        .Legendary = yaml::resolveEnum(source.legendary),
        .MaxHook   = source.max_hook.value_or(1),
        .KeyItem   = source.key_item.value_or(0),
    };

    if (source.length)
    {
        fish.MinLength = (*source.length)[0];
        fish.MaxLength = (*source.length)[1];
        if (fish.MinLength > fish.MaxLength)
        {
            throw std::runtime_error(fmt::format("fish '{}' has a minimum length above its maximum", name));
        }
    }

    if (source.quest)
    {
        fish.QuestLog = source.quest->log;
        fish.QuestId  = source.quest->id;
    }

    if (fish.MaxHook == 0)
    {
        throw std::runtime_error(fmt::format("fish '{}' has max_hook 0", name));
    }

    return fish;
}

auto convertRod(const std::string& name, const wire::Rod& source) -> FishingRodData
{
    return FishingRodData{
        .Name          = name,
        .Size          = yaml::resolveEnum(source.size),
        .Time          = source.time,
        .Legendary     = source.legendary.value_or(false),
        .LegendaryTime = source.legendary_time.value_or(0),
        .BreaksTo      = source.breaks_to.value_or(std::string{}),
    };
}

auto convertBait(const std::string& name, const wire::Bait& source, const std::map<std::string, wire::Fish>& fish) -> FishingBaitData
{
    FishingBaitData bait{
        .Name    = name,
        .Type    = yaml::resolveEnum(source.type),
        .MaxHook = source.max_hook.value_or(1),
    };

    if (bait.MaxHook == 0)
    {
        throw std::runtime_error(fmt::format("bait '{}' has max_hook 0", name));
    }

    if (source.affinity)
    {
        std::unordered_set<std::string_view> seen;
        for (const auto& fishName : *source.affinity)
        {
            if (!fish.contains(fishName))
            {
                throw std::runtime_error(fmt::format("bait '{}' has affinity for unknown fish '{}'", name, fishName));
            }

            if (!seen.insert(fishName).second)
            {
                throw std::runtime_error(fmt::format("bait '{}' lists '{}' twice", name, fishName));
            }
        }

        bait.Affinity = *source.affinity;
    }

    return bait;
}

} // namespace

auto Dataset::decode(const std::string_view text) -> Records
{
    const auto  document = yaml::read<YamlDocument>(text);
    const auto& catalog  = document.fishing;

    Records records;
    for (const auto& [name, source] : catalog.fish)
    {
        records.Fish.emplace(name, convertFish(name, source));
    }

    for (const auto& [name, source] : catalog.rods)
    {
        records.Rods.emplace(name, convertRod(name, source));
    }

    for (const auto& [name, source] : catalog.baits)
    {
        records.Baits.emplace(name, convertBait(name, source, catalog.fish));
    }

    return records;
}

} // namespace xi::data::datasets::fishing
