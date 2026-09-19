# Fishing data: what exists today

Catalogue of the current fishing data before the YAML move. Nothing here is retail-verified; it is what LSB ships and how the C++ consumes it.

## Tables (sql/)

| table | rows | key | loaded by | notes |
|---|---|---|---|---|
| fishing_zone | 294 | zoneid | LoadFishingAreas (LEFT JOIN) | only `difficulty` matters; 9 zones non-zero, 197 zones have no area at all |
| fishing_area | 171 | zoneid, areaid | LoadFishingAreas | 97 zones, max 7 areas/zone; bound_type 0=zone (96), 1=radius (68), 2=poly (7) |
| fishing_catch | 166 | zoneid, areaid, groupid | LoadFishingCatchLists, CreateFishingPools | join table area -> group |
| fishing_group | 1070 | groupid, fishid | LoadFishGroups, CreateFishingPools | 138 groups, up to 20 fish each; 19 groups shared by 2-3 areas |
| fishing_fish | 138 | fishid (item id) | LoadFishItems | fish + 26 "items" (rusty bucket, gil, snares); 1 disabled (Abaia), 9 with ranking 99 (skipped by loader) |
| fishing_mob | 286 | mobid | LoadFishMobs | 60 zones, 123 names; 27 disabled; keyed by real mob entity id |
| fishing_rod | 20 | rodid (item id) | LoadFishingRods | `rating` column never loaded |
| fishing_bait | 39 | baitid (item id) | LoadFishingBaits | `rankmod` all 0, `losable` all 1 |
| fishing_bait_affinity | 617 | baitid, fishid | LoadFishingBaitAffinities | power 1/2/3; 10 baits and 25 fish rows have no affinity |
| fishing_contest / fishing_contest_entries / char_fishing_contest_history | runtime | | fishingcontest.cpp | state, not data; out of scope |

Also consumed but not a fishing table:

- `npc_list` rows named `Jade_Etui` (5) -> chest pool (LoadChests).
- `FISHING_MESSAGE_OFFSET` TextID in 115 zone scripts (LoadFishingMessages).
- `xi.fishingContest.fish` in scripts/globals/hobbies/fishing/contest.lua: 23 contest fish, hand-listed; `fishing_fish.contest` flags the same 23.

## Per-table column usage

Columns the loader reads and the sim actually uses are listed; everything else is dead weight.

### fishing_fish
Used: skill_level, difficulty, base_delay, base_move, min_length, max_length, ranking, size_type (0 small 97 / 1 large 41), water_type (0 all 121 / 1 fresh 17, never 2 salt), log+quest (2 rows: Hydrogauge, Ripped cap), flags (0/1 shellfish/8/9/16), hour_pattern (0-7), moon_pattern (0-5), month_pattern (0-10), legendary (15), legendary_flags (2 rows: 7, 8), item (26), max_hook (1 or 3), rarity, required_keyitem (3 rows: 1976/1977), quest_only (2), contest (23), disabled (1).
Dead: quest_status (all 0), required_catches blob (all empty), family (all 0), name (display only).
Loader skips ranking >= 99 (9 fish) and disabled.

### fishing_mob
Used: level (10..60 in steps of 10), difficulty (15-20), base_delay, base_move (all 15), log+quest (2 rows), nm (15), nm_flags (2 rows = 106), areaid (15 rows non-zero), rarity (1 row 500), min/max_respawn (4 rows), required_baitid + alternative_baitid (9 rows: orobon/piranu family need Minnow 17407 or Sinking Minnow 17400, Odontotyrannus needs Giant Shell Bug), disabled.
Dead: required_keyitem (all 0), quest_only (all 0), min_length/max_length (all 1), ranking (282 rows = 10, 4 rows = 1), name.
Rows are per mob entity id, so the same mob name is repeated once per spawn (286 rows for 123 names). Retail almost certainly keys on family/name per zone, not per spawn.

### fishing_area
Used: bound_type, bound_height, bound_radius, center_x/y/z, bounds blob, zone difficulty via join.
Bounds blob = packed little-endian float xyz, up to 32 verts, y always 0 in the blob (height comes from bound_height + center_y). Decoded poly areas:

| zone | area | name | height | verts |
|---|---|---|---|---|
| 4 | 1 | PI - South Beach | 20 | 4 |
| 104 | 3 | Lake Mechieume - Main | 20 | 4 |
| 116 | 1 | Seaside | 20 | 5 |
| 116 | 4 | Other Waterside (rivers) | 50 | 6 |
| 116 | 5 | Lake Tepokalipuka | 20 | 8 |
| 173 | 1 | Salt Water | 20 | 4 |
| 235 | 1 | North Side | 20 | 9 |

Radius areas: height 20 (70), 10 (3), 50 (2). Same shape as `data/zones/*/regions.yaml` (poly + cylinder), which is the obvious home.

### fishing_group / fishing_catch
group row = (fishid, rarity 0-1000, pool_size, restock_rate). rarity is the weighted pick, pool_size/restock_rate drive the per-area stock pool (CreateFishingPools, RestockFishingAreas). One catch row per (zone, area) except Castle Oztroja PLD spot which points at groupid 0 (mob-only area).
Orphans: 5 areas with no catch row (Bibiki Bay Maliyakaleya Reef + Purgonorgo Isle, Zeruhn Mines Brigands Chart Quest, zones 212 and 237 Whole Zone). 12 fish in no group (the ranking-99 set + Abaia + Gerrothorax + Adoulinian Kelp).

### fishing_rod
All columns read except `rating`. flags: 0 normal, 1 small penalty, 2 large penalty, 4 legendary bonus, 8 goldfish scooping. breakable+broken_rodid on 15 rods.

### fishing_bait
type 0 bait (22) / 1 lure (15) / 2 special (2). flags on 5 rows (Robber/Rogue Rig 72 = poor fish + shellfish affinity, Super Scoop 32 goldfish, Sinking Minnow 1, Fly Lure 16 gold arrow). mmm on 3.

## C++ shape (src/map/utils/fishingutils.h)

Runtime maps after load:

- `FishingAreaList[zone][area]` -> fishingarea_t
- `FishList[fishid]` -> fish_t
- `FishZoneMobList[zone][mobid]` -> fishmob_t
- `FishingRods[rodid]`, `FishingBaits[baitid]`, `FishingBaitAffinities[baitid][fishid]`
- `FishingGroups[groupid]` (vector of fishinggroupitem_t), `FishingCatchLists[zone][area]` -> groupid
- `FishingPools[zone].catchPools[area].stock[fishid]` -> quantity/max/restock
- `ChestList[zone]`, `MessageOffset[zone]`

Enums that the YAML will need names for: FISHINGBOUNDTYPE, FISHINGSIZETYPE, FISHINGWATERTYPE, FISHINGBAITTYPE, FISHINGBAITPOWER, FISHFLAG, RODFLAG, BAITFLAG, FISHINGLEGENDARY, FISHINGNM, HOURCATCHPATTERNS, MOONCATCHPATTERNS, MONTHCATCHPATTERNS, FISHINGRODMATERIAL. All are plain `enum X : uintN` in fishingutils.h, none in data/enums yet.

## Dead parallel copy

scripts/globals/hobbies/fishing/data.lua (rodData / baitData / catchData) was an abandoned SQL-to-Lua conversion (commits 4b54f49117, bdac303c00). Nothing requires it and it has drifted from the SQL on 24 fish (skill caps and lengths). Delete it as part of the move.

## Integrity summary

- No dangling ids across bait_affinity, group->fish, catch->area.
- Castle Oztroja catch row uses groupid 0 (no such group) as a "mobs only" marker.
- 197 fishing_zone rows are pure noise (difficulty 0, no areas).
- fishing_mob is denormalised per spawn; the YAML layout should key per (zone, mob name) and resolve entity ids at load, or drop ids entirely if the rework says the hooked mob is a family/name pick.
