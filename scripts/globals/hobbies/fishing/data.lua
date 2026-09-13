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
}

xi.fishing.stage =
{
    IDLE     = 0,
    CAST     = 1,
    EMPTY    = 2,
    FIGHTING = 3,
    RESOLVED = 4,
}

-- The buckets that need entries behind their weight
xi.fishing.entryBuckets =
{
    xi.fishing.catchType.FISH,
    xi.fishing.catchType.ITEM,
}

-----------------------------------
-- To YAML?
-----------------------------------

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
