/*
===========================================================================

  Copyright (c) 2010-2015 Darkstar Dev Teams

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

#include "fishingutils.h"

#include "common/logging.h"
#include "data/loader.h"
#include "dataset_loader.h"
#include "items/item.h"
#include "itemutils.h"

#include <cstdlib>
#include <map>
#include <ranges>
#include <string>
#include <string_view>
#include <unordered_set>
#include <utility>

namespace fishingutils
{

namespace
{

xi::data::Fishing                           Catalog;
std::map<xi::ZoneId, xi::data::ZoneFishing> Zones;
std::unordered_set<uint16>                  FishIds; // fish, not by-catch items, for exdata

auto resolveItem(const std::string& name, const std::string_view what) -> uint16
{
    const auto itemId = xi::items::lookupIdByName(name);
    if (!itemId)
    {
        ShowCriticalFmt("fishing: {} names unknown item '{}'", what, name);
        std::exit(-1);
    }

    return *itemId;
}

void LoadCatalog()
{
    Catalog = xi::data::loadDataset<xi::data::datasets::fishing::Dataset>();

    for (const auto& [name, fish] : Catalog.Fish)
    {
        const auto itemId = resolveItem(name, "fish");
        if (!fish.Item)
        {
            FishIds.insert(itemId);
        }
    }

    for (const auto& [name, rod] : Catalog.Rods)
    {
        resolveItem(name, "rod");
        if (!rod.BreaksTo.empty())
        {
            resolveItem(rod.BreaksTo, "broken rod");
        }
    }

    for (const auto& name : Catalog.Baits | std::views::keys)
    {
        resolveItem(name, "bait");
    }
}

// Every zone file on disk, not just the zones this process runs, so the data is one whole.
void LoadZones()
{
    for (const auto& [name, zoneId] : xi::data::EnumTraits<xi::ZoneId>::kEntries)
    {
        auto records = xi::data::loadZoneFile<xi::data::datasets::zones::fishing_areas::Dataset>(zoneId);
        if (!records)
        {
            continue;
        }

        for (const auto& area : records->Areas)
        {
            for (const auto& item : area.Pool)
            {
                if (!Catalog.Fish.contains(item))
                {
                    ShowCriticalFmt("fishing: zone {} area '{}' pools '{}', which is not in the catalog", static_cast<uint32>(zoneId), area.Name, item);
                    std::exit(-1);
                }
            }
        }

        for (const auto& monster : records->Monsters)
        {
            for (const auto& bait : monster.Baits)
            {
                if (!Catalog.Baits.contains(bait))
                {
                    ShowCriticalFmt("fishing: zone {} monster {} names bait '{}', which is not in the catalog", static_cast<uint32>(zoneId), monster.SpawnId, bait);
                    std::exit(-1);
                }
            }
        }

        Zones.emplace(zoneId, std::move(*records));
    }
}

} // namespace

void InitializeFishingSystem()
{
    LoadCatalog();
    LoadZones();
}

void CleanupFishing()
{
    Catalog = {};
    Zones.clear();
    FishIds.clear();
}

auto GetCatalog() -> const xi::data::Fishing&
{
    return Catalog;
}

auto GetZones() -> const std::map<xi::ZoneId, xi::data::ZoneFishing>&
{
    return Zones;
}

auto IsFish(const CItem* item) -> bool
{
    return item && FishIds.contains(item->getID());
}

} // namespace fishingutils
