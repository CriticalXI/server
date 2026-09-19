---@meta

-- What GetFishingData() returns: the fishing catalog and every zone's fishing areas, keyed by
-- item id, zone id and spawn id. Absent fields are absent, as in the YAML they come from.

---@class TFishingData
---@field fish table<integer, TFishingFish> keyed by item id
---@field rods table<integer, TFishingRod> keyed by item id
---@field baits table<integer, TFishingBait> keyed by item id
---@field zones table<xi.zone, TFishingZone> only zones with a fishing_areas.yaml

---@class TFishingFish
---@field name string item name
---@field size xi.fishingSize
---@field skill integer the skill cap the catch fights at
---@field item? boolean by-catch such as a rusty bucket rather than a fish
---@field legendary? xi.fishingLegendaryTier absent on an ordinary fish
---@field length? { [1]: integer, [2]: integer } minimum and maximum length in Ilms
---@field maxHook? integer how many come up on one sabiki rig, absent means 1
---@field keyItem? xi.keyItem key item the player must hold for it to bite
---@field quest? TFishingQuest only bites while this quest is accepted

---@class TFishingRod
---@field name string item name
---@field size xi.fishingSize
---@field time integer base fight time in seconds
---@field legendary? boolean the Ebisu and Lu Shang's line
---@field legendaryTime? integer seconds added against a legendary fish
---@field breaksTo? integer item id of the broken rod, absent means unbreakable

---@class TFishingBait
---@field name string item name
---@field type xi.fishingBaitType
---@field affinity table<integer, true> item ids of the fish this bait attracts
---@field maxHook? integer how many fish it can hook at once, absent means 1

---@class TFishingZone
---@field areas table<string, TFishingArea> keyed by area name
---@field monsters table<integer, TFishingMonster> keyed by spawn id

---@class TFishingArea
---@field cylinder? TFishingCylinder round spot
---@field poly? { [1]: number, [2]: number, [3]: number }[] ring of x, y, z corners, closes implicitly
---@field pool integer[] item ids that bite here; empty means only monsters bite

---@class TFishingCylinder
---@field x number
---@field y number
---@field z number
---@field radius number

---@class TFishingMonster
---@field area? string only bites from this area, by key
---@field bait? table<integer, true> item ids of the baits that hook it, absent means any
---@field quest? TFishingQuest only bites while this quest is accepted

---@class TFishingQuest
---@field log xi.questLog
---@field id integer
