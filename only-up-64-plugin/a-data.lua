ENABLE_CHARACTER_HEIGHT = true
ENABLE_ONLY_UP_MOVESET = true
gGlobalSyncTable.enable_warps = false

IN_PRACTICE_MENU = false
MENU_INDEX = 0
MENU_SELECTION_INDEX = 0
MENU_ITEM_HEIGHT = 32
RETURNED_NEUTRAL = true

TWIRLING = false
TWIRL_COUNTER = 0
TWIRL_COUNT = 10
MAP_PAD = 16390

LEVEL_ONLY_UP_64 = 0x32
WARP_LEVEL = LEVEL_ONLY_UP_64
WARP_AREA = 1
WARP_ACT = 0
WARP_NODE = 10
WARPED = false

ACT_WALL_SLIDE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_KAZE_DIVE_SLIDE = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_DIVING | ACT_FLAG_ATTACKING)
ACT_KAZE_AIR_HIT_WALL = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)

PRACTICE_MENU = {
    { menuIndex = 0, menuSelectionIndex = 0, text = "Last Warp",                        level = nil,              area = nil, act = nil, node = nil },
    { menuIndex = 0, menuSelectionIndex = 1, text = "Area 1 (Super Mario 64)",          level = nil,              area = 1,   act = nil, node = nil },
    { menuIndex = 0, menuSelectionIndex = 2, text = "Area 2 (The Legend of Zelda)",     level = nil,              area = 2,   act = nil, node = nil },
    { menuIndex = 0, menuSelectionIndex = 3, text = "Area 3 (Pokemon)",                 level = nil,              area = 3,   act = nil, node = nil },
    { menuIndex = 0, menuSelectionIndex = 4, text = "Area 4 (Super Smash 64)",          level = nil,              area = 4,   act = nil, node = nil },
    { menuIndex = 0, menuSelectionIndex = 5, text = "Area 5 (Donkey Kong 64)",          level = nil,              area = 5,   act = nil, node = nil },
    { menuIndex = 0, menuSelectionIndex = 6, text = "Area 6 (Mario Party)",             level = nil,              area = 6,   act = nil, node = nil },
    { menuIndex = 0, menuSelectionIndex = 7, text = "Area 7 (Banjo Kazooie)",           level = nil,              area = 7,   act = nil, node = nil },
    { menuIndex = 0, menuSelectionIndex = 8, text = "Area 8 (N64 Characters)",          level = nil,              area = 0,   act = nil, node = nil },
    { menuIndex = 1, menuSelectionIndex = 0, text = "Area 1 - BoB (Start)",            level = LEVEL_ONLY_UP_64, area = 1,   act = 0,   node = 10  },
    { menuIndex = 1, menuSelectionIndex = 1, text = "Area 1 - Koopa Shell",            level = LEVEL_ONLY_UP_64, area = 1,   act = 0,   node = 11  },
    { menuIndex = 1, menuSelectionIndex = 2, text = "Area 1 - Pillars",                level = LEVEL_ONLY_UP_64, area = 1,   act = 0,   node = 12  },
    { menuIndex = 1, menuSelectionIndex = 3, text = "Area 1 - Whomp's Fortress",       level = LEVEL_ONLY_UP_64, area = 1,   act = 0,   node = 13  },
    { menuIndex = 1, menuSelectionIndex = 4, text = "Area 1 - Stars (End)",            level = LEVEL_ONLY_UP_64, area = 1,   act = 0,   node = 14  },
    { menuIndex = 2, menuSelectionIndex = 0, text = "Area 2 - Pot (Start)",            level = LEVEL_ONLY_UP_64, area = 2,   act = 0,   node = 10  },
    { menuIndex = 2, menuSelectionIndex = 1, text = "Area 2 - Bongos",                 level = LEVEL_ONLY_UP_64, area = 2,   act = 0,   node = 11  },
    { menuIndex = 2, menuSelectionIndex = 2, text = "Area 2 - Moon",                   level = LEVEL_ONLY_UP_64, area = 2,   act = 0,   node = 12  },
    { menuIndex = 2, menuSelectionIndex = 3, text = "Area 2 - Heart Piece",            level = LEVEL_ONLY_UP_64, area = 2,   act = 0,   node = 13  },
    { menuIndex = 2, menuSelectionIndex = 4, text = "Area 2 - Goron",                  level = LEVEL_ONLY_UP_64, area = 2,   act = 0,   node = 14  },
    { menuIndex = 2, menuSelectionIndex = 5, text = "Area 2 - Majora's Mask",          level = LEVEL_ONLY_UP_64, area = 2,   act = 0,   node = 15  },
    { menuIndex = 2, menuSelectionIndex = 6, text = "Area 2 - Treasure Chest (End)",   level = LEVEL_ONLY_UP_64, area = 2,   act = 0,   node = 16  },
    { menuIndex = 3, menuSelectionIndex = 0, text = "Area 3 - Deku Shield (Start)",    level = LEVEL_ONLY_UP_64, area = 3,   act = 0,   node = 10  },
    { menuIndex = 3, menuSelectionIndex = 1, text = "Area 3 - Onyx",                   level = LEVEL_ONLY_UP_64, area = 3,   act = 0,   node = 11  },
    { menuIndex = 3, menuSelectionIndex = 2, text = "Area 3 - Squirtle",               level = LEVEL_ONLY_UP_64, area = 3,   act = 0,   node = 12  },
    { menuIndex = 3, menuSelectionIndex = 3, text = "Area 3 - Dratini",                level = LEVEL_ONLY_UP_64, area = 3,   act = 0,   node = 13  },
    { menuIndex = 3, menuSelectionIndex = 4, text = "Area 3 - Vaporeon",               level = LEVEL_ONLY_UP_64, area = 3,   act = 0,   node = 14  },
    { menuIndex = 3, menuSelectionIndex = 5, text = "Area 3 - Nidoqueen (End)",        level = LEVEL_ONLY_UP_64, area = 3,   act = 0,   node = 15  },
    { menuIndex = 4, menuSelectionIndex = 0, text = "Area 4 - Nidoqueen (Start)",      level = LEVEL_ONLY_UP_64, area = 4,   act = 0,   node = 10  },
    { menuIndex = 4, menuSelectionIndex = 1, text = "Area 4 - Saffron Towers",         level = LEVEL_ONLY_UP_64, area = 4,   act = 0,   node = 11  },
    { menuIndex = 4, menuSelectionIndex = 2, text = "Area 4 - Smash Boxes",            level = LEVEL_ONLY_UP_64, area = 4,   act = 0,   node = 12  },
    { menuIndex = 4, menuSelectionIndex = 3, text = "Area 4 - Captain Falcon",         level = LEVEL_ONLY_UP_64, area = 4,   act = 0,   node = 13  },
    { menuIndex = 4, menuSelectionIndex = 4, text = "Area 4 - Great Fox",              level = LEVEL_ONLY_UP_64, area = 4,   act = 0,   node = 14  },
    { menuIndex = 4, menuSelectionIndex = 5, text = "Area 4 - Smash Fan",              level = LEVEL_ONLY_UP_64, area = 4,   act = 0,   node = 15  },
    { menuIndex = 4, menuSelectionIndex = 6, text = "Area 4 - Luigi (End)",            level = LEVEL_ONLY_UP_64, area = 4,   act = 0,   node = 16  },
    { menuIndex = 5, menuSelectionIndex = 0, text = "Area 5 - Banana (Start)",         level = LEVEL_ONLY_UP_64, area = 5,   act = 0,   node = 10  },
    { menuIndex = 5, menuSelectionIndex = 1, text = "Area 5 - Giraffe",                level = LEVEL_ONLY_UP_64, area = 5,   act = 0,   node = 11  },
    { menuIndex = 5, menuSelectionIndex = 2, text = "Area 5 - Lanky Kong",             level = LEVEL_ONLY_UP_64, area = 5,   act = 0,   node = 12  },
    { menuIndex = 5, menuSelectionIndex = 3, text = "Area 5 - Mushrooms",              level = LEVEL_ONLY_UP_64, area = 5,   act = 0,   node = 13  },
    { menuIndex = 5, menuSelectionIndex = 4, text = "Area 5 - Chunky Kong",            level = LEVEL_ONLY_UP_64, area = 5,   act = 0,   node = 14  },
    { menuIndex = 5, menuSelectionIndex = 5, text = "Area 5 - Hands",                  level = LEVEL_ONLY_UP_64, area = 5,   act = 0,   node = 15  },
    { menuIndex = 5, menuSelectionIndex = 6, text = "Area 5 - Rambi (End)",            level = LEVEL_ONLY_UP_64, area = 5,   act = 0,   node = 16  },
    { menuIndex = 6, menuSelectionIndex = 0, text = "Area 6 - Spoon (Start)",          level = LEVEL_ONLY_UP_64, area = 6,   act = 0,   node = 10  },
    { menuIndex = 6, menuSelectionIndex = 1, text = "Area 6 - Checkers",               level = LEVEL_ONLY_UP_64, area = 6,   act = 0,   node = 11  },
    { menuIndex = 6, menuSelectionIndex = 2, text = "Area 6 - Koopa",                  level = LEVEL_ONLY_UP_64, area = 6,   act = 0,   node = 12  },
    { menuIndex = 6, menuSelectionIndex = 3, text = "Area 6 - Thwomp",                 level = LEVEL_ONLY_UP_64, area = 6,   act = 0,   node = 13  },
    { menuIndex = 6, menuSelectionIndex = 4, text = "Area 6 - SNIFFA",                 level = LEVEL_ONLY_UP_64, area = 6,   act = 0,   node = 14  },
    { menuIndex = 6, menuSelectionIndex = 5, text = "Area 6 - Cliff (End)",            level = LEVEL_ONLY_UP_64, area = 6,   act = 0,   node = 15  },
    { menuIndex = 7, menuSelectionIndex = 0, text = "Area 7 - Rare Logo (Start)",      level = LEVEL_ONLY_UP_64, area = 7,   act = 0,   node = 10  },
    { menuIndex = 7, menuSelectionIndex = 1, text = "Area 7 - Kitchen",                level = LEVEL_ONLY_UP_64, area = 7,   act = 0,   node = 11  },
    { menuIndex = 7, menuSelectionIndex = 2, text = "Area 7 - Z64",                    level = LEVEL_ONLY_UP_64, area = 7,   act = 0,   node = 12  },
    { menuIndex = 7, menuSelectionIndex = 3, text = "Area 7 - Box Gap",                level = LEVEL_ONLY_UP_64, area = 7,   act = 0,   node = 13  },
    { menuIndex = 7, menuSelectionIndex = 4, text = "Area 7 - Pyramid",                level = LEVEL_ONLY_UP_64, area = 7,   act = 0,   node = 14  },
    { menuIndex = 7, menuSelectionIndex = 5, text = "Area 7 - Smoke Stacks (End)",     level = LEVEL_ONLY_UP_64, area = 7,   act = 0,   node = 15  },
    { menuIndex = 8, menuSelectionIndex = 0, text = "Area 8 - Smoke Stacks (Start)",   level = LEVEL_ONLY_UP_64, area = 0,   act = 0,   node = 10  },
    { menuIndex = 8, menuSelectionIndex = 1, text = "Area 8 - Paper Mario",            level = LEVEL_ONLY_UP_64, area = 0,   act = 0,   node = 11  },
    { menuIndex = 8, menuSelectionIndex = 2, text = "Area 8 - Kirby",                  level = LEVEL_ONLY_UP_64, area = 0,   act = 0,   node = 12  },
    { menuIndex = 8, menuSelectionIndex = 3, text = "Area 8 - Glover",                 level = LEVEL_ONLY_UP_64, area = 0,   act = 0,   node = 13  },
    { menuIndex = 8, menuSelectionIndex = 4, text = "Area 8 - Earthworm Jim",          level = LEVEL_ONLY_UP_64, area = 0,   act = 0,   node = 14  },
    { menuIndex = 8, menuSelectionIndex = 5, text = "Area 8 - Mario Knee",             level = LEVEL_ONLY_UP_64, area = 0,   act = 0,   node = 15  },
    { menuIndex = 8, menuSelectionIndex = 6, text = "Area 8 - Mario Glove",            level = LEVEL_ONLY_UP_64, area = 0,   act = 0,   node = 16  },
    { menuIndex = 8, menuSelectionIndex = 7, text = "Area 8 - Mario Hat (End)",        level = LEVEL_ONLY_UP_64, area = 0,   act = 0,   node = 17  },
}