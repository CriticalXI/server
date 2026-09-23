# Fishing

Fishing data lives in YAML rather than SQL. One catalog file describes every fish, item, rod and bait; each zone that can be fished carries a file describing where, what bites there, and which monsters can be hooked. The map server holds no fishing logic of its own: it loads these files and hands every cast, hook and interrupt to `xi.fishing` in `scripts/globals/hobbies/fishing/logic.lua`. Lua answers `onStart` with the hook timer in seconds, or nothing to refuse the cast, and answers a hook check with the fight table the client runs, keyed by the 0x115 packet's own field names; the core turns those returns into the status timer byte, the fishing event-off and the 0x115 packet.

The files carry what retail is known to hold and nothing else. Anything the old server invented to drive its own minigame, such as per-fish minigame numbers, bite weights, pool stock, time-of-day curves and rod arithmetic, is gone. The engine derives the fight from the catch's skill cap.

## Where things live

| What                                    | File                                    |
|-----------------------------------------|-----------------------------------------|
| Fish, fished-up items, rods, baits      | `data/fishing.yaml`                     |
| Areas, pools and monsters for one zone  | `data/zones/<zone>/fishing_areas.yaml`  |
| The names the fields use                | `data/enums/fishing_*.yaml`             |

A zone with no `fishing_areas.yaml` cannot be fished. Every entry is keyed by its item name from `item_basic`, the way loot is. Where two items share a name the lower id is the one the name resolves to, and that is the one fishing uses.

---

# The catalog

```yaml
fishing:
  fish:
    moat_carp:
      size:     small
      skill:    11
      max_hook: 3
    lik:
      size:      large
      skill:     140
      legendary: super
      length:    [185, 460]
      key_item:  1977 # serpent_rumors
```

## Fish

| Field       | Meaning                                                                         |
|-------------|---------------------------------------------------------------------------------|
| `item`      | True for by-catch (rusty bucket, coral fragment, the kelps) rather than a fish. Items bite regardless of bait, give no skill-up and carry no fish exdata. |
| `size`      | `small` or `large`. Small fish are held by small rods, large fish by large rods. |
| `skill`     | The skill cap the catch fights at.                                              |
| `legendary` | `basic` or `super`. Omit for an ordinary fish.                                  |
| `length`    | `[min, max]` in Ilms. Omit when the catch has no size.                          |
| `max_hook`  | How many come up on one sabiki rig. Defaults to 1.                              |
| `key_item`  | Key item id the player must hold for the catch to bite.                         |
| `quest`     | `{log, id}`. The catch only bites while that quest is accepted.                |

## Rods

| Field            | Meaning                                                            |
|------------------|--------------------------------------------------------------------|
| `size`           | `small` or `large`.                                                |
| `time`           | Base fight time in seconds.                                        |
| `legendary`      | A legendary rod: Ebisu, Lu Shang's and their +1 versions.          |
| `legendary_time` | Seconds added against a legendary fish.                            |
| `breaks_to`      | The broken rod it becomes. Omit it and the rod cannot break.       |

## Baits

| Field      | Meaning                                                                          |
|------------|----------------------------------------------------------------------------------|
| `type`     | `bait` is consumed, `lure` is kept, `special` is one-shot for a specific catch.  |
| `max_hook` | How many fish it can hook at once. Defaults to 1.                                |
| `affinity` | The fish this bait attracts, by name.                                            |

---

# The zone file

```yaml
areas:
  south_landing:
    cylinder: {center: [172.250, -2.000, -475.286], radius: 150}
    pool:
      - bastore_sardine
      - moat_carp
      - rusty_bucket
  north_side:
    poly:
      - [-266.366, -6.0, -30.548]
      - [-9.807, -6.0, -26.534]
      - [-7.548, -6.0, -118.593]
    pool: []
  whole_zone:
    pool: []
monsters:
  17396141:
    area:  south_landing
    bait:  [giant_shell_bug]
    quest: {log: 0, id: 91}
```

## Areas

Areas are keyed by name.

| Field      | Meaning                                                                                     |
|------------|---------------------------------------------------------------------------------------------|
| `cylinder` | `{center: [x, y, z], radius}`. A player fishes here within `radius` of the centre.          |
| `poly`     | A ring of `[x, y, z]` corners in order, the same shape a roam region uses. It closes implicitly. |
| `pool`     | What bites here, by name from the catalog. Empty means only monsters bite here.             |

Omit both `cylinder` and `poly` for an area covering the whole zone. The y in a corner or centre records the water level and takes no part in the test; the client already decides whether the player is facing water. A whole-zone area is the fallback for everything the shaped areas do not cover, so Bastok Markets draws its north side and leaves the south side as the fallback.

## Monsters

Monsters are keyed by their spawn id in this zone's `mobs.yaml`. The spawn must exist and belong to the zone.

| Field   | Meaning                                                                  |
|---------|--------------------------------------------------------------------------|
| `area`  | Only bites from this area, by key. Omit for anywhere in the zone.        |
| `bait`  | Baits that hook it, by name. Any one of them will do. Omit for any bait. |
| `quest` | `{log, id}`. Only bites while that quest is accepted.                    |

---

# Reading the data from Lua

`GetFishingData()` returns the catalog and every zone's areas as plain tables with names resolved to ids: fish, rods and baits keyed by item id, zones keyed by zone id, areas by name, monsters by spawn id. Enum fields carry the generated Lua enum values. Absent YAML fields are absent in Lua. Bait affinity and monster bait lists arrive as sets keyed by item id. The engine fetches it once through `xi.fishing.getData()` and keeps it, and a module may patch the table after that first call. The full shape is documented for the language server in `scripts/specs/types/Fishing.lua`.

```lua
local data = xi.fishing.getData()
local rod  = data.rods[player:getEquipID(xi.slot.RANGED)]
local bait = data.baits[player:getEquipID(xi.slot.AMMO)]
for _, itemId in ipairs(data.zones[player:getZoneID()].areas.whole_zone.pool) do
    if bait.affinity[itemId] then
        -- candidate
    end
end
```

---

# Quest overrides

A quest does not need a data row to make its catch bite. Before the bite roll the engine asks the interaction framework, and a quest section can answer with the catch to force while its check holds:

```lua
[xi.zone.ARRAPAGO_REEF] =
{
    onFishingHook = function(player, area)
        if quest:getVar(player, 'Prog') == 0 then
            return xi.item.HYDROGAUGE
        end
    end,
},
```

Return an item id for a fish or item, or a mob entity for a monster. `area` is the key of the fishing area the player is standing in. The first quest that answers wins, and no answer means the ordinary roll. The `quest` field on a catch or monster is the data-side version of the same gate, for quests that are not on the framework.

---

# Checks the loader makes

At decode, with no database:

- every affinity names a fish in the catalog, once
- a fish's `length` runs low to high
- an area declares at most one of `cylinder` and `poly`, a poly has at least three corners, and a pool names each catch once
- a monster's `area` names one of the zone's areas
- a monster's spawn id belongs to the zone the file is in

At map start, once items and zones exist:

- every fish, rod, bait and broken rod resolves to an item
- every pool entry and monster bait names a catalog entry

Any failure stops the server and names the file.

# Enums

Each is generated into C++ and into a Lua table under `scripts/enum`.

| File                           | Names                     | Lua table                  |
|--------------------------------|---------------------------|----------------------------|
| `fishing_size.yaml`            | `small`, `large`          | `xi.fishingSize`           |
| `fishing_bait_type.yaml`       | `bait`, `lure`, `special` | `xi.fishingBaitType`       |
| `fishing_legendary_tier.yaml`  | `basic`, `super`          | `xi.fishingLegendaryTier`  |
