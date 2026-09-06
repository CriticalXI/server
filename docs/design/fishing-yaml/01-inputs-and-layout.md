# Fishing YAML: inputs and draft layout

Two inputs on top of the catalogue in 00-existing-data.md:

- **Fishing System Proposal.md** (Sept 2026 working draft). Retail mechanics: fatigue, skill caps, general corrections. Authoritative.
- **Cast to Catch** (design 2026-09-03, branch `fishing_adjust`, not present in this repo). A whole-system rewrite plan with a YAML shape. Used for layout ideas only; where it contradicts the proposal, the proposal wins.

## What the proposal needs from the data

Everything below is data the current tables cannot express.

| Need | Source | Data impact |
|---|---|---|
| Daily catch budget, 200 points, per catch cost 1 or item-specific incl. 0 | 5.2 R2, R3 | per-catch `points` on items; fish default 1 |
| Fatigue pool, 200 points, cost by class: small 0.25, large 0.5, junk 0, countable item 0.25, valuable by-catch 4, basic legendary 1.4 flat, super legendary 7.8 flat | 5.3 | fish need a legendary **tier** (none / basic / super), items need a **class** (junk / countable / valuable). Costs live once per class, not per row |
| Over-level x4 on ordinary fish 17+ above effective skill, not on legendaries | 5.3 | tunable, not per row |
| Release costs, raise +10, low-level x20 | 5.3 | tunables |
| Rod fatigue multiplier: Ebisu ~0.85, Lu Shang ~0.95 | R13 | per-rod `fatigue` field |
| Devil manta is a high-fatigue by-catch | R6 | monsters also carry the item class |
| Symptom ramp 80% to 100%, cast wait growth, midnight reset with carry-over | 5.3 to 5.5 | tunables, values unknown, keep in data not code |
| Skill cap corrections, 24 fish, plus Hakuryu missing | 6.1, 6.2, 6.3 | value changes only, applied as separate diffs after the faithful migration |
| Hakuryu: item 5539 exists, size large, super tier, skill ~127, key item, baits cod slice / bream slice / minnow / sinking minnow | 6.3 | new fish row, new affinity rows. The proposal's "Serpent's Legend" is a literal translation of サーペントの伝説, which is Serpent Rumors (SERPENT_RUMORS 1977, already used by Gugrusaurus and Lik). JP wiki: Soryu, Kokuryu, Sekiryu and Hakuryu never bite without it. BG adds Dragon's Tabernacle. None of those five have fish rows in LSB today |
| Lu Shang breaks on exactly 14 legendaries, coral fragment snaps its line | 7.3.1 | per-rod `breaks_on` list replaces rank arithmetic for that rod. Kokuryu, Sekiryu, Soryu are items (5540, 5538, 5537) but not fish rows today |
| +1 rods must inherit every base-rod special case | 7.3 | rod `family: ebisu | lu_shang` (Cast to Catch already proposes this) |
| Regen/drain thresholds 13/25, loss roll cap ~23%, skill-ups on failed reels | 7.1, 7.2 | mechanics, not data |

## Where Cast to Catch conflicts with the proposal

- It states retail's only anti-farm rule is the 200 cap and drops fatigue. The proposal documents two systems. The layout must carry fatigue classes and rod multipliers from day one even if the rule ships later.
- It removes pool stock (`pool_size`, `restock_rate`). The proposal agrees by implication: fatigue is what limits farming. Keep the removal.
- It says 294 zone files. Only 99 zones have any fishing content (97 with areas, Fort Ghelsba and Toraimarai Canal with mobs only, and Toraimarai's rows are all disabled). fishing_zone's other 195 rows carry nothing.
- Its gear section migrates hardcoded C++ item ids. The proposal does not cover gear. Park it; it is not a table today.
- It drops `contest`. Fine, the contest list already lives in fishing_contest.lua.

## What Cast to Catch gets right and we keep

- One global catalog `data/fishing.yaml` (fish, rods, baits) plus per-zone blocks. Schema files are named by file stem in a flat dir, so the catalog must be one file.
- Names, not ids. Item names resolve at map load like loot does. Mob names resolve against the zone's mobs.yaml. Chests resolve against npcs.yaml.
- Enums first via data/enums codegen. Fourteen enums in fishingutils.h, none in data/enums yet.
- Faithful migration first, value corrections as separate diffs.
- Per-zone as blocks inside zone.yaml, matching the transport precedent, rather than a new file.

## Final layout

Documented in docs/wiki/Fishing.md. Decisions that differ from the first draft:

- Data only. Mechanics are untouched, so pool stock (`stock`, `restock`) stays and no proposal-only field (fatigue class, legendary tier, rod fatigue multiplier, breaker list) is invented. Those come with the mechanics change that reads them.
- Per-zone data is its own slice, `data/zones/<zone>/fishing_areas.yaml`, like regions, not a block in zone.yaml. Pools run to 140 lines in some zones, and a separate slice leaves the settings dataset and its tests untouched. The stem differs from the catalog's because schema files share one flat directory.
- Fish and items share the `fish` section with an `item: true` marker, since the C++ treats them as one record type.
- Monsters are keyed by spawn id. Every fishing_mob row is a spawn in the zone's mobs.yaml, with `_fished` and ordinary templates mixed, so a name key cannot express the set. The one name check in the C++ (Buburimu's brigand pugil) reads the entity's name instead.
- Key items stay numeric with a name comment. The C++ enum is hand-written and has no name table.
- Ranking 99 rows and disabled rows are kept in the file and skipped by the loader, as before.

See 02-migration-ledger.md for what the generator flagged.

## Seam

After the data move, the C++ minigame was deleted. `fishingutils` only loads the two datasets and answers `IsFish` for exdata. Action 14 calls `xi.fishing.onStart(player)`, the 0x110 packet calls `xi.fishing.onAction(player, mode, para, para2)` after byte validation, and a hostile action or zone line calls `xi.fishing.onInterrupt(player)`. The Lua side is stubs until the engine is written against the proposal. The character keeps `hookDelay` for the 0x037 status packet; `hookedFish`, `fishingToken`, `nextFishTime` and `lastCastTime` are gone, as is the pool restock tick.

## Trim

With the engine gone the faithful columns were LSB inventions with no consumer. The files now hold only what the proposal or plain retail knowledge backs: cap, size, tier, length, multi-hook, key item and quest per fish; size, fight time, legendary time and broken rod per rod; type, multi-hook and the attracted fish per bait; bounds and what bites per area; area, bait and quest per monster. The full list of what went is in 02-migration-ledger.md. The Lua engine derives the fight from the cap, as the proposal describes.
