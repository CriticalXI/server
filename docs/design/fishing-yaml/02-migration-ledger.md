# Migration ledger

Everything the SQL to YAML generator flagged while copying the nine fishing tables. Nothing here changed a value; each line is a fact about the source data that the reviewer should know.

Counts: fish 138 rods 20 baits 39 zones 99.

## Columns dropped because nothing reads them

- fishing_fish: `water_type`, `quest_status`, `required_catches`, `family`, `contest`, `name`
- fishing_rod: `rating`, `mmm`, `name`
- fishing_bait: `losable`, `rankmod`, `mmm`, `name`
- fishing_mob: `name`, `min_length`, `max_length`, `required_keyitem`, `quest_only`
- fishing_zone: `name`, and every row with difficulty 0 and no areas

The generator asserted that every dropped column held its constant value on every row before dropping it.

## Structure changes

- `fishing_catch` and `fishing_group` are inlined as each area's `pool`. The 19 groups that served several areas are repeated per area.
- `fishing_mob` rows are keyed by spawn id, matching `mobs.yaml`. Names were stale in places (Passage_Crab rows pointing at Gugru_Jagil spawns) and are gone.
- `fishing_zone.difficulty` is the zone file's top-level `difficulty`.
- Polygon corners are stored as `[x, z]` with the shared `y`; every corner in the SQL blobs had y 0 and the height band came from `center_y`.
- Area names are the SQL names in snake case. Valkurm Dunes had two `Whole Zone` areas; the second is `pirates_chart_quest` after the catch comment.
- Fish flag bits 0x08 and 0x10 had no C++ name. They are kept as `rusty` (every rusty item) and `bit_10` (five large fish); nothing reads them.

## Flagged rows

- fish: 'bastore_sardine' is shared with a higher item id; resolves to 4360 as the lowest
- fish: 'bhefhel_marlin' is shared with a higher item id; resolves to 4479 as the lowest
- fish: 'black_eel' is shared with a higher item id; resolves to 4429 as the lowest
- fish: 'bladefish' is shared with a higher item id; resolves to 4471 as the lowest
- fish: 'bluetail' is shared with a higher item id; resolves to 4399 as the lowest
- fish: 'copper_frog' is shared with a higher item id; resolves to 4515 as the lowest
- fish: 'crayfish' is shared with a higher item id; resolves to 4472 as the lowest
- fish: 'dark_bass' is shared with a higher item id; resolves to 4428 as the lowest
- fish: 'giant_catfish' is shared with a higher item id; resolves to 4469 as the lowest
- fish: 'giant_donko' is shared with a higher item id; resolves to 4306 as the lowest
- fish: 'gigant_octopus' is shared with a higher item id; resolves to 5475 as the lowest
- fish: 'gold_lobster' is shared with a higher item id; resolves to 4383 as the lowest
- fish: 'gugru_tuna' is shared with a higher item id; resolves to 4480 as the lowest
- fish: 'istavrit' is shared with a higher item id; resolves to 5136 as the lowest
- fish: 'moat_carp' is shared with a higher item id; resolves to 4401 as the lowest
- fish: 'monke-onke' is shared with a higher item id; resolves to 4462 as the lowest
- fish: 'nosteau_herring' is shared with a higher item id; resolves to 4482 as the lowest
- fish: 'ogre_eel' is shared with a higher item id; resolves to 4481 as the lowest
- fish: 'pipira' is shared with a higher item id; resolves to 4464 as the lowest
- fish: 'quus' is shared with a higher item id; resolves to 4514 as the lowest
- fish: 'rhinochimera' is shared with a higher item id; resolves to 5135 as the lowest
- fish: 'shining_trout' is shared with a higher item id; resolves to 4354 as the lowest
- fish: 'three-eyed_fish' is shared with a higher item id; resolves to 4478 as the lowest
- fish: 'tiger_cod' is shared with a higher item id; resolves to 4483 as the lowest
- fish: 'veydal_wrasse' is shared with a higher item id; resolves to 5141 as the lowest
- rod maze_monger_fishing_rod: mmm flag dropped (nothing reads it)
- bait dried_squid: no affinity rows
- bait goliath_worm: no affinity rows
- bait judge_fly: no affinity rows
- bait judge_minnow: no affinity rows
- bait judges_lure: no affinity rows
- bait large_maze_monger_ball: mmm flag dropped (nothing reads it)
- bait large_maze_monger_ball: no affinity rows
- bait maze_monger_minnow: mmm flag dropped (nothing reads it)
- bait maze_monger_minnow: no affinity rows
- bait regular_maze_monger_ball: mmm flag dropped (nothing reads it)
- bait regular_maze_monger_ball: no affinity rows
- bait sea_dragon_liver: no affinity rows
- bait super_scoop: no affinity rows
- zone 3 area maliyakaleya_reef: no fishing_catch row, empty pool
- zone 3 area purgonorgo_isle: no fishing_catch row, empty pool
- zone 118 area brigands_chart_quest: no fishing_catch row, empty pool
- zone 151 area pld_af_fishing_spot: groupid 0, empty pool (mobs only)
- zone 212 area whole_zone: no fishing_catch row, empty pool
- zone 235 area south_side: whole-zone bound carries geometry, dropped
- zone 237 area whole_zone: no fishing_catch row, empty pool

## Second pass: trim to what the proposal backs

The faithful files carried every column the old C++ read. Once the C++ minigame was deleted those columns had no consumer and no source, so they were removed: fish `difficulty`, `delay`, `movement`, `ranking`, `rarity`, `legendary_flags`, `patterns`, `flags`, `quest_only`, `disabled`; rod `material`, `rank`, `attack`, `recovery`, `legendary_attack`, `small_fish`, `large_fish`, `multiplier`, `flags`; bait `flags` and the 1 to 3 affinity grades; zone `difficulty`, pool `rarity`, `stock`, `restock`; monster `level`, `difficulty`, `delay`, `movement`, `ranking`, `nm`, `nm_flags`, `rarity`, `respawn`. Area `id` went with them, since monsters name areas by key. `legendary` became a tier, with the super set taken from the proposal (Gugrusaurus, Lik, Matsya, Abaia; Hakuryu once it has a row).

Rows that only existed through a dropped marker:

- fish abaia: disabled dropped, now an ordinary entry
- fish bastore_sweeper: ranking 99 (LSB 'no data' marker) dropped, now loads like any fish
- fish brass_loach: ranking 99 (LSB 'no data' marker) dropped, now loads like any fish
- fish ca_cuong: ranking 99 (LSB 'no data' marker) dropped, now loads like any fish
- fish garpike: ranking 99 (LSB 'no data' marker) dropped, now loads like any fish
- fish gigant_octopus: ranking 99 (LSB 'no data' marker) dropped, now loads like any fish
- fish matsya: ranking 99 (LSB 'no data' marker) dropped, now loads like any fish
- fish megalodon: ranking 99 (LSB 'no data' marker) dropped, now loads like any fish
- fish mithra_snare: quest_only dropped, now an ordinary entry
- fish pirarucu: ranking 99 (LSB 'no data' marker) dropped, now loads like any fish
- fish tarutaru_snare: quest_only dropped, now an ordinary entry
- fish trumpet_shell: ranking 99 (LSB 'no data' marker) dropped, now loads like any fish
- arrapago_reef: monster 16998401 was disabled, row removed
- arrapago_reef: monster 16998402 was disabled, row removed
- arrapago_reef: monster 16998403 was disabled, row removed
- arrapago_reef: monster 16998404 was disabled, row removed
- arrapago_reef: monster 16998405 was disabled, row removed
- bibiki_bay: monster 16793605 was disabled, row removed
- buburimu_peninsula: monster 17260547 was disabled, row removed
- buburimu_peninsula: monster 17260548 was disabled, row removed
- cape_teriggan: zone difficulty 5 dropped
- dangruf_wadi: monster 17559556 was disabled, row removed
- davoi: zone difficulty 2 dropped
- dragons_aery: zone difficulty 2 dropped
- east_ronfaure: monster 17190913 was disabled, row removed
- east_sarutabaruta: monster 17252356 was disabled, row removed
- eastern_altepa_desert: monster 17244164 was disabled, row removed
- gusgen_mines: monster 17580035 was disabled, row removed
- korroloka_tunnel: monster 17485827 was disabled, row removed
- korroloka_tunnel: monster 17485828 was disabled, row removed
- kuftal_tunnel: zone difficulty 5 dropped
- la_theine_plateau: monster 17195011 was disabled, row removed
- mamook: monster 17043457 was disabled, row removed
- mamook: monster 17043458 was disabled, row removed
- mamook: monster 17043459 was disabled, row removed
- oldton_movalpolos: zone difficulty 2 dropped
- ordelles_caves: monster 17567747 was disabled, row removed
- ordelles_caves: monster 17567748 was disabled, row removed
- pashhow_marshlands: monster 17223684 was disabled, row removed
- quicksand_caves: zone difficulty 2 dropped
- south_gustaberg: monster 17215491 was disabled, row removed
- talacca_cove: zone difficulty 3 dropped
- the_boyahda_tree: zone difficulty 5 dropped
- toraimarai_canal: monster 17469441 was disabled, row removed
- toraimarai_canal: monster 17469442 was disabled, row removed
- toraimarai_canal: monster 17469443 was disabled, row removed
- toraimarai_canal: monster 17469445 was disabled, row removed
- toraimarai_canal: nothing left (only disabled monsters), file removed
- zeruhn_mines: zone difficulty 3 dropped

Area `bound_height` went too: 70 areas at 20, three at 10, two at 50, never tuned and unmentioned by the proposal. Corners and centres keep their y as a record of the water level.

The `gil` catch (item 65535, one pool) went too: the item table never loads gil as an item, so the name cannot resolve, and retail does not fish up gil.
