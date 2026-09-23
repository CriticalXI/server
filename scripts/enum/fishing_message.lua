-----------------------------------
-- Fishing text: offsets from each zone's FISHING_MESSAGE_OFFSET
-----------------------------------
xi = xi or {}

---@enum xi.fishingMessage
xi.fishingMessage =
{
    CANNOT_FISH_HERE          = 0,  -- You can't fish here.
    NO_ROD                    = 1,  -- You can't fish without a rod in your hands.
    NO_BAIT                   = 2,  -- You can't fish without bait on the hook.
    CANNOT_FISH_MOMENT        = 3,  -- You can't fish at the moment.
    NO_CATCH                  = 4,  -- You didn't catch anything.
    MONSTER                   = 5,  -- <Player> caught a monster!
    LINE_BREAK                = 6,  -- Your line breaks.
    ROD_BREAK                 = 7,  -- Your rod breaks.
    HOOKED_SMALL_FISH         = 8,  -- Something caught the hook!
    LOST                      = 9,  -- You lost your catch.
    CATCH_INVENTORY_FULL      = 10, -- <Player> caught <Fish>, but cannot carry any more items.
    CATCH_MULTI               = 14, -- <Player> caught X <Fish>
    ROD_BREAK_TOO_BIG         = 17, -- Your rod breaks. Whatever caught the hook was pretty big.
    ROD_BREAK_TOO_HEAVY       = 18, -- Your rod breaks. Whatever caught the hook was too heavy to catch with this rod.
    LOST_TOO_SMALL            = 19, -- You lost your catch. Whatever caught the hook was too small to catch with this rod.
    LOST_LOW_SKILL            = 20, -- You lost your catch due to your lack of skill.
    GOLDFISH_PAPER_RIPPED     = 23, -- The paper on your <item> ripped.
    GOLDFISH_APPROACHES       = 24, -- A tiny goldfish approaches!
    PLUMP_BLACK_APPROACHES    = 25, -- A plump, black goldfish approaches!
    FAT_JUICY_APPROACHES      = 26, -- A fat, juicy goldfish approaches!
    NO_GOLDFISH_FOUND         = 27, -- There are no goldfish to be found...
    CATCH_GOLDFISH_FULL       = 28, -- <Player> caught <Goldfish>, but cannot carry any more items.
    GOLDFISH_SLIPPED_OFF      = 29, -- The goldfish slipped off your scoop...
    GIVE_UP_BAIT_LOSS         = 36, -- You give up and reel in your line.
    GIVE_UP                   = 37, -- You give up.
    CATCH                     = 39, -- <Player> caught <Fish>
    WARNING                   = 40, -- You don't know how much longer you can keep this one on the line...
    GOOD_FEELING              = 41, -- You have a good feeling about this one!
    BAD_FEELING               = 42, -- You have a bad feeling about this one.
    TERRIBLE_FEELING          = 43, -- You have a terrible feeling about this one...
    NO_SKILL_FEELING          = 44, -- You don't know if you have enough skill to reel this one in.
    NO_SKILL_SURE_FEELING     = 45, -- You're fairly sure you don't have enough skill to reel this one in.
    NO_SKILL_POSITIVE_FEELING = 46, -- You're positive you don't have enough skill to reel this one in!
    HOOKED_LARGE_FISH         = 50, -- Something caught the hook!!!
    HOOKED_ITEM               = 51, -- You feel something pulling at your line.
    HOOKED_MONSTER            = 52, -- Something clamps onto your line ferociously!
    KEEN_ANGLERS_SENSE        = 53, -- Your keen angler's senses tell you that this is the pull of <fish>
    EPIC_CATCH                = 54, -- This strength... You get the sense that you are on the verge of an epic catch!
    LOST_TOO_BIG              = 60, -- You lost your catch. Whatever caught the hook was too large to catch with this rod.
    HURRY_GOLDFISH_WARNING    = 63, -- Hurry before the goldfish sees you!
    CATCH_CHEST               = 64, -- <Player> fishes up a large box!
    CANNOT_FISH_TIME          = 94, -- You can't fish at this time.
}
