-----------------------------------
-- Fishing Data
-----------------------------------
xi = xi or {}
xi.fishing = xi.fishing or {}

-- What a bite roll can produce.
xi.fishing.catchType =
{
    NOTHING = 0,
    FISH    = 1,
    ITEM    = 2,
    MONSTER = 3,
    CHEST   = 4,
}

xi.fishing.stage =
{
    IDLE     = 0,
    CAST     = 1,
    EMPTY    = 2,
    FIGHTING = 3,
    RESOLVED = 4,
}

xi.fishing.mode =
{
    CHECK_HOOK        = 2,
    END_MINIGAME      = 3,
    RELEASE           = 4,
    POTENTIAL_TIMEOUT = 5,
}

xi.fishing.feeling =
{
    GOOD              = 0,
    BAD               = 1,
    TERRIBLE          = 2,
    NO_SKILL          = 3,
    NO_SKILL_SURE     = 4,
    NO_SKILL_POSITIVE = 5,
    KEEN              = 6,
    EPIC              = 7,
}

xi.fishing.failure =
{
    LINE_SNAP  = 0,
    ROD_BREAK  = 1,
    LOST_BIG   = 2,
    LOST_SMALL = 3,
    LOW_SKILL  = 4,
}

xi.fishing.result =
{
    CAUGHT     = 0,
    GAVE_UP    = 1,
    LINE_BREAK = 2,
    LOST       = 3,
    LOW_SKILL  = 4,
    ROD_BREAK  = 5,
}

xi.fishing.skillUpWeight =
{
    FULL = 0,
    NONE = 1,
}

xi.fishing.fatigueEvent =
{
    BASIC_LEGENDARY = 0,
    COUNTABLE_ITEM  = 1,
    EMPTY_CAST      = 2,
    JUNK_ITEM       = 3,
    LARGE_FISH      = 4,
    RELEASE         = 5,
    SMALL_FISH      = 6,
    SUPER_LEGENDARY = 7,
    VALUABLE_ITEM   = 8,
}

xi.fishing.fatigueClass =
{
    COUNTABLE = 0,
    VALUABLE  = 1,
    JUNK      = 2,
}

-- The buckets that need entries behind their weight
xi.fishing.entryBuckets =
{
    xi.fishing.catchType.FISH,
    xi.fishing.catchType.ITEM,
    xi.fishing.catchType.MONSTER,
}

xi.fishing.moonCurves =
{
    [xi.moonCycle.NEW_MOON               ] = 0,
    [xi.moonCycle.LESSER_WAXING_CRESCENT ] = 1,
    [xi.moonCycle.GREATER_WAXING_CRESCENT] = 1,
    [xi.moonCycle.FIRST_QUARTER          ] = 2,
    [xi.moonCycle.LESSER_WAXING_GIBBOUS  ] = 3,
    [xi.moonCycle.GREATER_WAXING_GIBBOUS ] = 3,
    [xi.moonCycle.FULL_MOON              ] = 4,
    [xi.moonCycle.GREATER_WANING_GIBBOUS ] = 5,
    [xi.moonCycle.LESSER_WANING_GIBBOUS  ] = 5,
    [xi.moonCycle.THIRD_QUARTER          ] = 6,
    [xi.moonCycle.GREATER_WANING_CRESCENT] = 7,
    [xi.moonCycle.LESSER_WANING_CRESCENT ] = 7,
}

-- Capture needed
-- TODO: Capture a wide range of monster levels from 1 to 99 to prove out this table
xi.fishing.monsterFightStats =
{
    { level = 19, arrowDamage = 320, arrowDelay = 14, moveFrequency = 15, rank = 10 },
    { level = 29, arrowDamage = 320, arrowDelay = 11, moveFrequency = 15, rank = 10 },
    { level = 39, arrowDamage = 320, arrowDelay = 10, moveFrequency = 15, rank = 10 },
    { level = 99, arrowDamage = 320, arrowDelay =  9, moveFrequency = 15, rank = 10 },
}

-----------------------------------
-- Outcomes
-----------------------------------

-- The line each feeling sends; a keen angler's sense names the catch instead.
xi.fishing.feelingMessages =
{
    [xi.fishing.feeling.GOOD             ] = xi.fishingMessage.GOOD_FEELING,
    [xi.fishing.feeling.BAD              ] = xi.fishingMessage.BAD_FEELING,
    [xi.fishing.feeling.TERRIBLE         ] = xi.fishingMessage.TERRIBLE_FEELING,
    [xi.fishing.feeling.NO_SKILL         ] = xi.fishingMessage.NO_SKILL_FEELING,
    [xi.fishing.feeling.NO_SKILL_SURE    ] = xi.fishingMessage.NO_SKILL_SURE_FEELING,
    [xi.fishing.feeling.NO_SKILL_POSITIVE] = xi.fishingMessage.NO_SKILL_POSITIVE_FEELING,
    [xi.fishing.feeling.EPIC             ] = xi.fishingMessage.EPIC_CATCH,
}

-- The lost line names the reason the claim was rolled against, when it had one.
xi.fishing.lostMessages =
{
    [xi.fishing.failure.LOST_BIG  ] = xi.fishingMessage.LOST_TOO_BIG,
    [xi.fishing.failure.LOST_SMALL] = xi.fishingMessage.LOST_TOO_SMALL,
}

-- What each result plays and says, and the weight its skill-up roll carries; a catch plays and says its own.
xi.fishing.results =
{
    [xi.fishing.result.CAUGHT    ] = { skillUp = xi.fishing.skillUpWeight.FULL },
    [xi.fishing.result.GAVE_UP   ] = { skillUp = xi.fishing.skillUpWeight.NONE, animation = xi.animation.NEW_FISHING_STOP,       message = xi.fishingMessage.GIVE_UP        },
    [xi.fishing.result.LINE_BREAK] = { skillUp = xi.fishing.skillUpWeight.NONE, animation = xi.animation.NEW_FISHING_LINE_BREAK, message = xi.fishingMessage.LINE_BREAK     },
    [xi.fishing.result.LOST      ] = { skillUp = xi.fishing.skillUpWeight.FULL, animation = xi.animation.NEW_FISHING_STOP,       message = xi.fishingMessage.LOST           },
    [xi.fishing.result.LOW_SKILL ] = { skillUp = xi.fishing.skillUpWeight.NONE, animation = xi.animation.NEW_FISHING_STOP,       message = xi.fishingMessage.LOST_LOW_SKILL },
    [xi.fishing.result.ROD_BREAK ] = { skillUp = xi.fishing.skillUpWeight.NONE, animation = xi.animation.NEW_FISHING_ROD_BREAK,  message = xi.fishingMessage.ROD_BREAK      },
}

xi.fishing.skillUpChances =
{
    { gap =  1, chance =  3 },
    { gap =  2, chance = 16 },
    { gap =  4, chance = 21 },
    { gap =  7, chance = 27 },
    { gap = 11, chance = 34 },
    { gap = 19, chance = 29 },
    { gap = 29, chance = 16 },
    { gap = 50, chance = 14 },
}

xi.fishing.fatigueCosts =
{
    [xi.fishing.fatigueEvent.BASIC_LEGENDARY] = { daily = 1, fatigue = 140 },
    [xi.fishing.fatigueEvent.COUNTABLE_ITEM ] = { daily = 1, fatigue =  25 },
    [xi.fishing.fatigueEvent.EMPTY_CAST     ] = { daily = 0, fatigue =   0 },
    [xi.fishing.fatigueEvent.JUNK_ITEM      ] = { daily = 0, fatigue =   0 },
    [xi.fishing.fatigueEvent.LARGE_FISH     ] = { daily = 1, fatigue =  50, overLevel = 200 },
    [xi.fishing.fatigueEvent.RELEASE        ] = { daily = 0, fatigue =   0, overLevel = 100 },
    [xi.fishing.fatigueEvent.SMALL_FISH     ] = { daily = 1, fatigue =  25, overLevel = 100 },
    [xi.fishing.fatigueEvent.SUPER_LEGENDARY] = { daily = 1, fatigue = 780 },
    [xi.fishing.fatigueEvent.VALUABLE_ITEM  ] = { daily = 1, fatigue = 400 },
}

--------------------------------
-- To YAML?
--------------------------------

xi.fishing.rodStats =
{
    [xi.item.BAMBOO_FISHING_ROD       ] = { attack = 140, recovery =  60, maxRank =  8, smallDelay = 2, smallMove = 1, largeDelay = 1, largeMove =  0 },
    [xi.item.CARBON_FISHING_ROD       ] = { attack = 100, recovery =  75, maxRank = 13, smallDelay = 2, smallMove = 1, largeDelay = 1, largeMove =  0 },
    [xi.item.CLOTHESPOLE              ] = { attack = 170, recovery =  50, maxRank = 16, smallDelay = 0, smallMove = 0, largeDelay = 1, largeMove =  0, penalty = xi.fishingSize.SMALL },
    [xi.item.COMPOSITE_FISHING_ROD    ] = { attack = 100, recovery =  70, maxRank = 24, smallDelay = 0, smallMove = 0, largeDelay = 1, largeMove =  0, penalty = xi.fishingSize.SMALL },
    [xi.item.EBISU_FISHING_ROD        ] = { attack = 100, recovery =  50, maxRank = 30, smallDelay = 2, smallMove = 1, largeDelay = 1, largeMove =  0, legendaryAttack = 50, legendaryRecovery = 25, keenBonus = 40, pullStart = 15, pullDivisor = 13, fatigue = 85, drainStart = 12, drainSlope = 1.3 }, -- Capture needed: the keen term
    [xi.item.EBISU_FISHING_ROD_P1     ] = { attack = 100, recovery =  50, maxRank = 30, smallDelay = 2, smallMove = 1, largeDelay = 1, largeMove =  0, legendaryAttack = 50, legendaryRecovery = 25, keenBonus = 40, pullStart = 15, pullDivisor = 13, fatigue = 85, drainStart = 12, drainSlope = 1.3 }, -- Capture needed: the keen term
    [xi.item.FASTWATER_FISHING_ROD    ] = { attack = 135, recovery =  65, maxRank =  7, smallDelay = 2, smallMove = 1, largeDelay = 1, largeMove =  0 },
    [xi.item.GLASS_FIBER_FISHING_ROD  ] = { attack = 100, recovery =  80, maxRank = 12, smallDelay = 2, smallMove = 1, largeDelay = 1, largeMove =  0 },
    [xi.item.GOLDFISH_BASKET          ] = { attack = 100, recovery =  50, maxRank =  5, smallDelay = 0, smallMove = 0, largeDelay = 0, largeMove =  0 },
    [xi.item.HALCYON_FISHING_ROD      ] = { attack = 100, recovery =  70, maxRank = 18, smallDelay = 2, smallMove = 1, largeDelay = 0, largeMove =  2, penalty = xi.fishingSize.LARGE },
    [xi.item.HUME_FISHING_ROD         ] = { attack = 125, recovery =  75, maxRank = 10, smallDelay = 2, smallMove = 1, largeDelay = 0, largeMove =  2, penalty = xi.fishingSize.LARGE },
    [xi.item.JUDGES_ROD               ] = { attack = 200, recovery = 100, maxRank = 40, smallDelay = 2, smallMove = 1, largeDelay = 1, largeMove =  0, legendaryAttack = 100 },
    [xi.item.LU_SHANGS_FISHING_ROD    ] = { attack = 110, recovery = 100, maxRank = 28, smallDelay = 2, smallMove = 1, largeDelay = 1, largeMove =  0, legendaryAttack = 20, pullStart = 10, pullDivisor = 15, fatigue = 95, drainStart = 20, drainSlope = 1.5 },
    [xi.item.LU_SHANGS_FISHING_ROD_P1 ] = { attack = 110, recovery = 100, maxRank = 28, smallDelay = 2, smallMove = 1, largeDelay = 1, largeMove =  0, legendaryAttack = 20, pullStart = 10, pullDivisor = 15, fatigue = 95, drainStart = 20, drainSlope = 1.5 },
    [xi.item.MAZE_MONGER_FISHING_ROD  ] = { attack = 100, recovery = 100, maxRank = 25, smallDelay = 2, smallMove = 1, largeDelay = 1, largeMove = 10 },
    [xi.item.MITHRAN_FISHING_ROD      ] = { attack = 130, recovery =  65, maxRank = 18, smallDelay = 0, smallMove = 0, largeDelay = 1, largeMove =  0, penalty = xi.fishingSize.SMALL },
    [xi.item.SINGLE_HOOK_FISHING_ROD  ] = { attack = 100, recovery =  80, maxRank = 22, smallDelay = 0, smallMove = 0, largeDelay = 1, largeMove =  0, penalty = xi.fishingSize.SMALL },
    [xi.item.TARUTARU_FISHING_ROD     ] = { attack = 130, recovery =  70, maxRank =  9, smallDelay = 2, smallMove = 1, largeDelay = 1, largeMove =  0 },
    [xi.item.WILLOW_FISHING_ROD       ] = { attack = 150, recovery =  50, maxRank =  5, smallDelay = 2, smallMove = 1, largeDelay = 1, largeMove =  0 },
    [xi.item.YEW_FISHING_ROD          ] = { attack = 145, recovery =  55, maxRank =  6, smallDelay = 2, smallMove = 1, largeDelay = 1, largeMove =  0 },
}

xi.fishing.catchStats =
{
    [xi.item.ABAIA                    ] = { arrowDamage =  740, arrowDelay =  7, moveFrequency = 13, rank = 34 },
    [xi.item.AHTAPOT                  ] = { arrowDamage =  620, arrowDelay =  8, moveFrequency =  7, rank = 25 },
    [xi.item.ALABALIGI                ] = { arrowDamage =  320, arrowDelay =  5, moveFrequency = 11, rank = 15 },
    [xi.item.ARMORED_PISCES           ] = { arrowDamage =  440, arrowDelay =  5, moveFrequency = 13, rank = 19 },
    [xi.item.ARROWWOOD_LOG            ] = { arrowDamage =  360, arrowDelay = 14, moveFrequency =  3, rank = 18 },
    [xi.item.BASTORE_BREAM            ] = { arrowDamage =  620, arrowDelay =  7, moveFrequency =  9, rank = 22 },
    [xi.item.BASTORE_SARDINE_1        ] = { arrowDamage =  420, arrowDelay = 11, moveFrequency =  6, rank = 10, sizeLoss = 13 },
    [xi.item.BASTORE_SWEEPER          ] = { arrowDamage =  340, arrowDelay =  4, moveFrequency =  2, rank = 10 }, -- Capture needed: the rank
    [xi.item.BETTA                    ] = { arrowDamage =  320, arrowDelay =  3, moveFrequency = 12, rank = 10 },
    [xi.item.BHEFHEL_MARLIN_1         ] = { arrowDamage =  400, arrowDelay = 10, moveFrequency = 11, rank = 23 },
    [xi.item.BIBIKIBO                 ] = { arrowDamage =  440, arrowDelay = 12, moveFrequency =  3, rank =  1 },
    [xi.item.BIBIKI_URCHIN            ] = { arrowDamage =  400, arrowDelay = 13, moveFrequency =  1, rank =  1 },
    [xi.item.BLACK_EEL_1              ] = { arrowDamage =  480, arrowDelay =  5, moveFrequency =  8, rank = 15 },
    [xi.item.BLACK_GHOST              ] = { arrowDamage =  720, arrowDelay =  9, moveFrequency = 11, rank = 18 },
    [xi.item.BLACK_SOLE               ] = { arrowDamage =  660, arrowDelay =  5, moveFrequency = 11, rank = 23 },
    [xi.item.BLADEFISH_1              ] = { arrowDamage =  420, arrowDelay =  6, moveFrequency = 12, rank = 23 },
    [xi.item.BLINDFISH                ] = { arrowDamage =  360, arrowDelay =  6, moveFrequency =  8, rank = 18 },
    [xi.item.BLUETAIL_1               ] = { arrowDamage =  480, arrowDelay =  4, moveFrequency = 12, rank = 14 },
    [xi.item.BRASS_LOACH              ] = { arrowDamage =  540, arrowDelay =  4, moveFrequency =  3, rank = 15 }, -- Capture needed: the rank
    [xi.item.BUGBEAR_MASK             ] = { arrowDamage =  840, arrowDelay = 13, moveFrequency =  2, rank =  5 },
    [xi.item.CAEDARVA_FROG            ] = { arrowDamage =  340, arrowDelay =  6, moveFrequency = 13, rank =  5 },
    [xi.item.CAVE_CHERAX              ] = { arrowDamage =  720, arrowDelay =  7, moveFrequency =  4, rank = 32 },
    [xi.item.CA_CUONG                 ] = { arrowDamage =  340, arrowDelay = 12, moveFrequency =  6, rank = 14 }, -- Capture needed: the rank
    [xi.item.CHEVAL_SALMON            ] = { arrowDamage =  420, arrowDelay =  7, moveFrequency =  7, rank = 17, sizeLoss = 48 },
    [xi.item.CLUMP_OF_ADOULINIAN_KELP ] = { arrowDamage =  360, arrowDelay = 13, moveFrequency =  2, rank = 13 },
    [xi.item.CLUMP_OF_PAMTAM_KELP     ] = { arrowDamage =  480, arrowDelay = 13, moveFrequency =  2, rank = 13 },
    [xi.item.COBALT_JELLYFISH         ] = { arrowDamage =  560, arrowDelay = 13, moveFrequency =  0, rank = 14 },
    [xi.item.CONE_CALAMARY            ] = { arrowDamage =  800, arrowDelay = 10, moveFrequency =  5, rank = 10 },
    [xi.item.COPPER_FROG_1            ] = { arrowDamage =  440, arrowDelay =  8, moveFrequency =  4, rank =  9 },
    [xi.item.COPPER_RING              ] = { arrowDamage =  800, arrowDelay = 13, moveFrequency =  2, rank =  5, fatigue = xi.fishing.fatigueClass.VALUABLE },
    [xi.item.CORAL_BUTTERFLY          ] = { arrowDamage =  520, arrowDelay = 10, moveFrequency =  8, rank = 19 },
    [xi.item.CORAL_FRAGMENT           ] = { arrowDamage =  940, arrowDelay = 13, moveFrequency =  2, rank =  5, lineSnap = 20, fatigue = xi.fishing.fatigueClass.VALUABLE }, -- Capture needed: the snap rate
    [xi.item.CRAYFISH_1               ] = { arrowDamage =  480, arrowDelay = 13, moveFrequency =  6, rank =  8 },
    [xi.item.CRESCENT_FISH            ] = { arrowDamage =  560, arrowDelay =  7, moveFrequency =  8, rank = 13 },
    [xi.item.CRYSTAL_BASS             ] = { arrowDamage =  480, arrowDelay =  7, moveFrequency = 12, rank = 17 },
    [xi.item.DAMP_SCROLL              ] = { arrowDamage =  700, arrowDelay = 13, moveFrequency =  2, rank =  1 },
    [xi.item.DARK_BASS_1              ] = { arrowDamage =  460, arrowDelay =  7, moveFrequency =  8, rank = 13 },
    [xi.item.DENIZANASI               ] = { arrowDamage =  560, arrowDelay = 13, moveFrequency =  0, rank = 14 },
    [xi.item.DIL                      ] = { arrowDamage =  660, arrowDelay =  5, moveFrequency = 11, rank = 23 },
    [xi.item.ELSHIMO_FROG             ] = { arrowDamage =  500, arrowDelay =  7, moveFrequency =  5, rank =  5 },
    [xi.item.ELSHIMO_NEWT             ] = { arrowDamage =  520, arrowDelay =  5, moveFrequency =  9, rank = 19 },
    [xi.item.EMPEROR_FISH             ] = { arrowDamage =  720, arrowDelay =  4, moveFrequency = 13, rank = 23 },
    [xi.item.FAT_GREEDIE              ] = { arrowDamage =  600, arrowDelay = 10, moveFrequency =  8, rank = 11 },
    [xi.item.FISH_SCALE_SHIELD        ] = { arrowDamage =  300, arrowDelay = 13, moveFrequency =  2, rank = 13 },
    [xi.item.FOREST_CARP              ] = { arrowDamage =  220, arrowDelay =  9, moveFrequency = 11, rank = 14 },
    [xi.item.GARPIKE                  ] = { arrowDamage =  480, arrowDelay =  3, moveFrequency = 10, rank = 22 }, -- Capture needed: the rank
    [xi.item.GAVIAL_FISH              ] = { arrowDamage =  600, arrowDelay = 14, moveFrequency = 15, rank = 23 },
    [xi.item.GERROTHORAX              ] = { arrowDamage =  580, arrowDelay =  6, moveFrequency =  7, rank = 32 },
    [xi.item.GIANT_CATFISH_1          ] = { arrowDamage =  260, arrowDelay =  6, moveFrequency = 12, rank = 19 },
    [xi.item.GIANT_CHIRAI             ] = { arrowDamage =  500, arrowDelay =  4, moveFrequency = 15, rank = 27 },
    [xi.item.GIANT_DONKO_1            ] = { arrowDamage =  340, arrowDelay = 14, moveFrequency =  8, rank = 23 },
    [xi.item.GIGANT_OCTOPUS_1         ] = { arrowDamage =  360, arrowDelay =  6, moveFrequency =  9, rank = 23 }, -- Capture needed: the rank
    [xi.item.GIGANT_SQUID             ] = { arrowDamage =  860, arrowDelay =  7, moveFrequency = 13, rank = 23 },
    [xi.item.GOLD_CARP                ] = { arrowDamage =  360, arrowDelay = 10, moveFrequency = 14, rank = 14, sizeLoss = 84 },
    [xi.item.GOLD_LOBSTER_1           ] = { arrowDamage =  700, arrowDelay =  4, moveFrequency =  3, rank = 14 },
    [xi.item.GREEDIE                  ] = { arrowDamage =  200, arrowDelay =  7, moveFrequency = 14, rank = 10 },
    [xi.item.GRIMMONITE               ] = { arrowDamage =  620, arrowDelay =  8, moveFrequency =  7, rank = 25 },
    [xi.item.GUGRUSAURUS              ] = { arrowDamage =  780, arrowDelay =  6, moveFrequency =  5, rank = 33, timeBonus = -20 },
    [xi.item.GUGRU_TUNA_1             ] = { arrowDamage =  320, arrowDelay =  6, moveFrequency = 13, rank = 22 },
    [xi.item.GURNARD                  ] = { arrowDamage =  260, arrowDelay =  3, moveFrequency = 11, rank =  5 },
    [xi.item.HAKURYU                  ] = { arrowDamage =  500, arrowDelay =  3, moveFrequency = 13, rank = 33 }, -- Capture needed: the rank
    [xi.item.HAMSI                    ] = { arrowDamage =  420, arrowDelay = 11, moveFrequency =  6, rank = 10 },
    [xi.item.HYDROGAUGE               ] = { arrowDamage =  500, arrowDelay = 13, moveFrequency =  2, rank =  1 },
    [xi.item.ICEFISH                  ] = { arrowDamage =  760, arrowDelay = 11, moveFrequency =  7, rank = 14 },
    [xi.item.ISTAKOZ                  ] = { arrowDamage =  700, arrowDelay =  4, moveFrequency =  3, rank = 14 },
    [xi.item.ISTAVRIT_1               ] = { arrowDamage =  260, arrowDelay =  7, moveFrequency = 12, rank = 16, sizeLoss = 39 },
    [xi.item.ISTIRIDYE                ] = { arrowDamage =  540, arrowDelay = 13, moveFrequency =  2, rank = 14 },
    [xi.item.JUNGLE_CATFISH           ] = { arrowDamage =  520, arrowDelay =  6, moveFrequency = 12, rank = 23 },
    [xi.item.KALAMAR                  ] = { arrowDamage =  800, arrowDelay = 10, moveFrequency =  5, rank = 10 },
    [xi.item.KALKANBALIGI             ] = { arrowDamage =  380, arrowDelay =  6, moveFrequency = 12, rank = 27 },
    [xi.item.KAPLUMBAGA               ] = { arrowDamage =  560, arrowDelay =  8, moveFrequency =  5, rank = 11 },
    [xi.item.KAYABALIGI               ] = { arrowDamage =  600, arrowDelay =  7, moveFrequency =  8, rank = 10 },
    [xi.item.KILICBALIGI              ] = { arrowDamage =  360, arrowDelay =  6, moveFrequency = 15, rank = 23 },
    [xi.item.LAKERDA                  ] = { arrowDamage =  320, arrowDelay =  6, moveFrequency = 13, rank = 22 },
    [xi.item.LAMP_MARIMO              ] = { arrowDamage =  520, arrowDelay = 13, moveFrequency =  2, rank =  1 },
    [xi.item.LIK                      ] = { arrowDamage =  960, arrowDelay =  2, moveFrequency = 14, rank = 33, timeBonus = 30 },
    [xi.item.LUNGFISH                 ] = { arrowDamage =  320, arrowDelay =  4, moveFrequency =  8, rank = 10 },
    [xi.item.MATSYA                   ] = { arrowDamage =  620, arrowDelay =  5, moveFrequency = 12, rank = 34 }, -- Capture needed: the rank
    [xi.item.MEGALODON                ] = { arrowDamage =  660, arrowDelay = 10, moveFrequency = 11, rank = 25 }, -- Capture needed: the rank
    [xi.item.MERCANBALIGI             ] = { arrowDamage =  620, arrowDelay =  7, moveFrequency =  9, rank = 22 },
    [xi.item.MITHRA_SNARE             ] = { arrowDamage =  440, arrowDelay = 13, moveFrequency =  2, rank =  1 },
    [xi.item.MOAT_CARP_1              ] = { arrowDamage =  320, arrowDelay = 10, moveFrequency =  9, rank =  7 },
    [xi.item.MOBLIN_MASK              ] = { arrowDamage =  880, arrowDelay = 13, moveFrequency =  2, rank =  5 },
    [xi.item.MOLA_MOLA                ] = { arrowDamage =  320, arrowDelay = 12, moveFrequency = 12, rank = 32 },
    [xi.item.MONKE_ONKE_1             ] = { arrowDamage =  340, arrowDelay = 11, moveFrequency =  9, rank = 18 },
    [xi.item.MOORISH_IDOL             ] = { arrowDamage =  360, arrowDelay =  6, moveFrequency = 11, rank =  9 },
    [xi.item.MORINABALIGI             ] = { arrowDamage =  720, arrowDelay =  4, moveFrequency = 13, rank = 23 },
    [xi.item.MUDDY_SIREDON            ] = { arrowDamage =  460, arrowDelay = 12, moveFrequency = 11, rank =  1 },
    [xi.item.MYTHRIL_DAGGER           ] = { arrowDamage = 1560, arrowDelay = 13, moveFrequency =  2, rank =  5, fatigue = xi.fishing.fatigueClass.VALUABLE },
    [xi.item.MYTHRIL_SWORD            ] = { arrowDamage =  300, arrowDelay = 13, moveFrequency =  2, rank = 10, fatigue = xi.fishing.fatigueClass.VALUABLE },
    [xi.item.NEBIMONITE               ] = { arrowDamage =  600, arrowDelay =  9, moveFrequency =  5, rank = 10, sizeLoss = 66 },
    [xi.item.NOBLE_LADY               ] = { arrowDamage =  600, arrowDelay =  7, moveFrequency = 10, rank = 13 },
    [xi.item.NORG_SHELL               ] = { arrowDamage =  620, arrowDelay = 13, moveFrequency =  2, rank = 14 },
    [xi.item.NOSTEAU_HERRING_1        ] = { arrowDamage =  420, arrowDelay =  7, moveFrequency =  8, rank = 10, sizeLoss = 92 },
    [xi.item.OGRE_EEL_1               ] = { arrowDamage =  580, arrowDelay = 13, moveFrequency = 11, rank = 14 },
    [xi.item.PHANAUET_NEWT            ] = { arrowDamage =  260, arrowDelay = 10, moveFrequency = 11, rank =  1 },
    [xi.item.PIPIRA_1                 ] = { arrowDamage =  220, arrowDelay =  6, moveFrequency = 14, rank = 10, sizeLoss = 52 },
    [xi.item.PIRARUCU                 ] = { arrowDamage =  480, arrowDelay = 14, moveFrequency =  4, rank = 32 }, -- Capture needed: the rank
    [xi.item.PTERYGOTUS               ] = { arrowDamage =  560, arrowDelay =  8, moveFrequency =  7, rank = 24 },
    [xi.item.QUUS_1                   ] = { arrowDamage =  240, arrowDelay =  7, moveFrequency = 11, rank =  5 },
    [xi.item.RED_TERRAPIN             ] = { arrowDamage =  560, arrowDelay =  8, moveFrequency =  5, rank = 11 },
    [xi.item.RHINOCHIMERA_1           ] = { arrowDamage =  340, arrowDelay =  6, moveFrequency = 15, rank = 23 },
    [xi.item.RIPPED_CAP               ] = { arrowDamage =  720, arrowDelay = 13, moveFrequency =  2, rank = 13, fatigue = xi.fishing.fatigueClass.JUNK },
    [xi.item.RUSTY_BUCKET             ] = { arrowDamage =  380, arrowDelay = 13, moveFrequency =  2, rank = 10 },
    [xi.item.RUSTY_CAP                ] = { arrowDamage =  760, arrowDelay = 13, moveFrequency =  2, rank =  5, fatigue = xi.fishing.fatigueClass.VALUABLE },
    [xi.item.RUSTY_GREATSWORD         ] = { arrowDamage = 1140, arrowDelay = 13, moveFrequency =  2, rank =  5 },
    [xi.item.RUSTY_LEGGINGS           ] = { arrowDamage =  520, arrowDelay = 13, moveFrequency =  2, rank = 18, fatigue = xi.fishing.fatigueClass.JUNK },
    [xi.item.RUSTY_PICK               ] = { arrowDamage =  940, arrowDelay = 13, moveFrequency =  2, rank =  5, fatigue = xi.fishing.fatigueClass.VALUABLE },
    [xi.item.RUSTY_SUBLIGAR           ] = { arrowDamage =  440, arrowDelay = 13, moveFrequency =  2, rank =  5, fatigue = xi.fishing.fatigueClass.JUNK },
    [xi.item.RYUGU_TITAN              ] = { arrowDamage =  960, arrowDelay =  1, moveFrequency = 15, rank = 34 },
    [xi.item.SANDFISH                 ] = { arrowDamage =  720, arrowDelay =  3, moveFrequency = 10, rank = 13 },
    [xi.item.SAZANBALIGI              ] = { arrowDamage =  360, arrowDelay = 10, moveFrequency = 14, rank = 14 },
    [xi.item.SEA_ZOMBIE               ] = { arrowDamage =  780, arrowDelay =  3, moveFrequency = 15, rank = 28 },
    [xi.item.SHALL_SHELL              ] = { arrowDamage =  540, arrowDelay = 13, moveFrequency =  2, rank = 14 },
    [xi.item.SHINING_TROUT_1          ] = { arrowDamage =  320, arrowDelay =  5, moveFrequency = 11, rank = 15, sizeLoss = 67 },
    [xi.item.SILVER_RING              ] = { arrowDamage =  800, arrowDelay = 13, moveFrequency =  2, rank =  5, fatigue = xi.fishing.fatigueClass.VALUABLE },
    [xi.item.SILVER_SHARK             ] = { arrowDamage =  700, arrowDelay =  3, moveFrequency =  9, rank = 14 },
    [xi.item.TAKITARO                 ] = { arrowDamage =  360, arrowDelay =  3, moveFrequency = 14, rank = 28 },
    [xi.item.TARUTARU_SNARE           ] = { arrowDamage =  440, arrowDelay = 13, moveFrequency =  2, rank =  1 },
    [xi.item.TAVNAZIAN_GOBY           ] = { arrowDamage =  600, arrowDelay =  7, moveFrequency =  8, rank = 10 },
    [xi.item.THREE_EYED_FISH_1        ] = { arrowDamage =  440, arrowDelay = 10, moveFrequency = 10, rank = 25 },
    [xi.item.TIGER_COD_1              ] = { arrowDamage =  460, arrowDelay =  9, moveFrequency =  9, rank = 10, sizeLoss = 58 },
    [xi.item.TINY_GOLDFISH            ] = { arrowDamage =  440, arrowDelay =  0, moveFrequency = 14, rank =  5 },
    [xi.item.TITANICTUS               ] = { arrowDamage =  560, arrowDelay =  3, moveFrequency = 12, rank = 28 },
    [xi.item.TITANIC_SAWFISH          ] = { arrowDamage =  780, arrowDelay =  6, moveFrequency = 15, rank = 32 },
    [xi.item.TRICOLORED_CARP          ] = { arrowDamage =  380, arrowDelay = 12, moveFrequency = 12, rank = 13, sizeLoss = 38 },
    [xi.item.TRICORN                  ] = { arrowDamage =  760, arrowDelay = 11, moveFrequency =  9, rank = 29 },
    [xi.item.TRILOBITE                ] = { arrowDamage =  540, arrowDelay =  5, moveFrequency =  6, rank = 14 },
    [xi.item.TRUMPET_SHELL            ] = { arrowDamage =  360, arrowDelay = 10, moveFrequency =  5, rank = 14 }, -- Capture needed: the rank
    [xi.item.TURNABALIGI              ] = { arrowDamage =  600, arrowDelay =  4, moveFrequency = 13, rank = 24 },
    [xi.item.USKUMRU                  ] = { arrowDamage =  480, arrowDelay =  4, moveFrequency = 12, rank = 14 },
    [xi.item.VEYDAL_WRASSE_1          ] = { arrowDamage =  260, arrowDelay =  5, moveFrequency = 13, rank = 25 },
    [xi.item.VONGOLA_CLAM             ] = { arrowDamage =  400, arrowDelay =  8, moveFrequency =  4, rank = 13 },
    [xi.item.YAYINBALIGI              ] = { arrowDamage =  260, arrowDelay =  6, moveFrequency = 12, rank = 19 },
    [xi.item.YELLOW_GLOBE             ] = { arrowDamage =  340, arrowDelay =  8, moveFrequency =  8, rank = 10, sizeLoss = 15 },
    [xi.item.YILANBALIGI              ] = { arrowDamage =  480, arrowDelay =  5, moveFrequency =  8, rank = 15 },
    [xi.item.ZAFMLUG_BASS             ] = { arrowDamage =  540, arrowDelay =  6, moveFrequency =  7, rank = 15 },
    [xi.item.ZEBRA_EEL                ] = { arrowDamage =  640, arrowDelay = 10, moveFrequency = 10, rank = 23 },
}

xi.fishing.preferredCatches =
{
    [xi.item.BALL_OF_CRAYFISH_PASTE] = { xi.item.BLACK_EEL_1, xi.item.NEBIMONITE, xi.item.YELLOW_GLOBE },
    [xi.item.BALL_OF_INSECT_PASTE  ] = { xi.item.BLINDFISH, xi.item.FOREST_CARP, xi.item.MOAT_CARP_1 },
    [xi.item.BALL_OF_SARDINE_PASTE ] = { xi.item.ABAIA, xi.item.DARK_BASS_1, xi.item.EMPEROR_FISH, xi.item.JUNGLE_CATFISH, xi.item.MORINABALIGI },
    [xi.item.BALL_OF_TROUT_PASTE   ] = { xi.item.ABAIA, xi.item.DARK_BASS_1, xi.item.EMPEROR_FISH, xi.item.JUNGLE_CATFISH, xi.item.MORINABALIGI },
    [xi.item.FLY_LURE              ] = { xi.item.BETTA, xi.item.BIBIKIBO, xi.item.CHEVAL_SALMON, xi.item.COBALT_JELLYFISH, xi.item.COPPER_FROG_1, xi.item.CRESCENT_FISH, xi.item.DENIZANASI, xi.item.ELSHIMO_FROG, xi.item.PHANAUET_NEWT, xi.item.SHINING_TROUT_1, xi.item.TAKITARO },
    [xi.item.FROG_LURE             ] = { xi.item.ARMORED_PISCES, xi.item.ELSHIMO_NEWT, xi.item.KAPLUMBAGA, xi.item.MUDDY_SIREDON, xi.item.RED_TERRAPIN },
    [xi.item.LITTLE_WORM           ] = { xi.item.COBALT_JELLYFISH, xi.item.DENIZANASI },
    [xi.item.LIZARD_LURE           ] = { xi.item.GAVIAL_FISH },
    [xi.item.LUFAISE_FLY           ] = { xi.item.GIANT_CHIRAI },
    [xi.item.LUGWORM               ] = { xi.item.ISTAVRIT_1, xi.item.PTERYGOTUS, xi.item.QUUS_1 },
    [xi.item.MEATBALL              ] = { xi.item.ARMORED_PISCES, xi.item.BLADEFISH_1, xi.item.CAVE_CHERAX, xi.item.COBALT_JELLYFISH, xi.item.DENIZANASI, xi.item.GAVIAL_FISH, xi.item.GUGRUSAURUS, xi.item.MEGALODON, xi.item.PIRARUCU, xi.item.SILVER_SHARK, xi.item.TITANICTUS },
    [xi.item.MINNOW                ] = { xi.item.ABAIA, xi.item.ARMORED_PISCES, xi.item.BLACK_GHOST, xi.item.BLUETAIL_1, xi.item.CONE_CALAMARY, xi.item.CRYSTAL_BASS, xi.item.DARK_BASS_1, xi.item.GIANT_CATFISH_1, xi.item.GIGANT_SQUID, xi.item.GREEDIE, xi.item.JUNGLE_CATFISH, xi.item.PIPIRA_1, xi.item.SHINING_TROUT_1, xi.item.TAVNAZIAN_GOBY, xi.item.THREE_EYED_FISH_1 },
    [xi.item.PEELED_CRAYFISH       ] = { xi.item.EMPEROR_FISH, xi.item.GIANT_DONKO_1 },
    [xi.item.PIECE_OF_ROTTEN_MEAT  ] = { xi.item.CAVE_CHERAX },
    [xi.item.ROBBER_RIG            ] = { xi.item.SHALL_SHELL },
    [xi.item.SABIKI_RIG            ] = { xi.item.BASTORE_SARDINE_1, xi.item.COBALT_JELLYFISH, xi.item.DENIZANASI, xi.item.HAMSI, xi.item.ICEFISH, xi.item.YELLOW_GLOBE },
    [xi.item.SHELL_BUG             ] = { xi.item.BLACK_EEL_1 },
    [xi.item.SHRIMP_LURE           ] = { xi.item.BASTORE_BREAM, xi.item.GIGANT_OCTOPUS_1, xi.item.GOLD_CARP, xi.item.GRIMMONITE, xi.item.KALKANBALIGI, xi.item.LUNGFISH, xi.item.MERCANBALIGI, xi.item.MOLA_MOLA, xi.item.MONKE_ONKE_1, xi.item.MOORISH_IDOL, xi.item.OGRE_EEL_1, xi.item.TRICOLORED_CARP, xi.item.TURNABALIGI, xi.item.ZEBRA_EEL },
    [xi.item.SINKING_MINNOW        ] = { xi.item.ARMORED_PISCES, xi.item.BLACK_SOLE, xi.item.CRYSTAL_BASS, xi.item.GARPIKE, xi.item.GIANT_CATFISH_1, xi.item.GOLD_LOBSTER_1, xi.item.GUGRU_TUNA_1, xi.item.ISTAKOZ, xi.item.KAYABALIGI, xi.item.LAKERDA, xi.item.NOBLE_LADY, xi.item.RHINOCHIMERA_1, xi.item.SHINING_TROUT_1 },
    [xi.item.SLICE_OF_BLUETAIL     ] = { xi.item.BASTORE_SWEEPER, xi.item.BHEFHEL_MARLIN_1, xi.item.BLADEFISH_1, xi.item.KALAMAR, xi.item.KILICBALIGI, xi.item.VEYDAL_WRASSE_1 },
    [xi.item.SLICE_OF_COD          ] = { xi.item.DIL, xi.item.GIGANT_SQUID, xi.item.RYUGU_TITAN, xi.item.THREE_EYED_FISH_1 },
    [xi.item.SLICE_OF_MOAT_CARP    ] = { xi.item.CA_CUONG, xi.item.CRAYFISH_1 },
    [xi.item.SLICE_OF_SARDINE      ] = { xi.item.ZEBRA_EEL },
    [xi.item.WORM_LURE             ] = { xi.item.CORAL_BUTTERFLY, xi.item.MOORISH_IDOL, xi.item.SANDFISH, xi.item.TRILOBITE, xi.item.YELLOW_GLOBE, xi.item.ZAFMLUG_BASS },
}

xi.fishing.monsters =
{
    ['Devil_Manta'    ] = { fatigue = xi.fishing.fatigueClass.VALUABLE, cooldown = 600 },
    ['Northern_Piranu'] = { cooldown = 14400 },
    ['Southern_Piranu'] = { cooldown = 14400 },
}
