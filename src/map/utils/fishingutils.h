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

#pragma once

#include "common/cbasetypes.h"
#include "data/datasets/fishing/dataset.h"
#include "data/datasets/zones/fishing_areas/dataset.h"
#include "data/enums/zone.h"

#include <map>

class CItem;

// The fishing data, loaded once at start. Every rule lives in Lua (xi.fishing).
namespace fishingutils
{

void InitializeFishingSystem();
void CleanupFishing();

auto GetCatalog() -> const xi::data::Fishing&;
auto GetZones() -> const std::map<xi::ZoneId, xi::data::ZoneFishing>&;
auto IsFish(const CItem* item) -> bool;

} // namespace fishingutils
