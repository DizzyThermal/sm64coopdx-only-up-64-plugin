-- Functions
function mod_active(mod_name)
    for i in pairs(gActiveMods) do
        if string.find(gActiveMods[i].name, mod_name) then return true end
    end

    return false
end

function mod_active_exact(mod_name)
    for i in pairs(gActiveMods) do
        if gActiveMods[i].name == mod_name then return true end
    end

    return false
end

-- Active Mods
_G.ou64_plugin_active = true
_G.ou64_active = mod_active_exact("\\#FAFF20\\Only Up 64") or
        mod_active("Only Up 64 v") or
        mod_active("Only Up 64 %(v")
_G.ou64_flood_active = mod_active("Flood")

-- Toggleable Features
_G.ou64_enable_checkpoints = true
_G.ou64_enable_moveset = true
_G.ou64_show_character_height = true
_G.ou64_show_height_meter = true
_G.ou64_show_run_timer = true
_G.ou64_show_leaderboard = true
gGlobalSyncTable.ou64_enable_warps = true

-- Only Up 64 Moveset
_G.ou64_moveset_twirling = false
_G.ou64_moveset_twirl_counter = 0
_G.ou64_moveset_twirl_count = 10

-- Movement
ACT_WALL_SLIDE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_KAZE_DIVE_SLIDE = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_DIVING | ACT_FLAG_ATTACKING)
ACT_KAZE_AIR_HIT_WALL = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)

-- Character Height
_G.ou64_character_height_scale = 1
_G.ou64_character_height_x_pad = 30
_G.ou64_character_height_x_pad_negative = 13
_G.ou64_character_height_y_pad = 4
_G.ou64_character_height_y_pad_negative = 3

-- Checkpoints
_G.ou64_checkpoint_placed = false
_G.ou64_checkpoint_used = false
_G.ou64_checkpoint_flag_obj = nil
_G.ou64_checkpoint_x = 0
_G.ou64_checkpoint_y = 0
_G.ou64_checkpoint_z = 0
_G.ou64_checkpoint_area = 1
_G.ou64_checkpoint_count = 0
gPlayerSyncTable[0].checkpoint_count = 0
_G.ou64_checkpoint_tip_scale = 0.3
_G.ou64_checkpoint_tip_height = 10
_G.ou64_checkpoint_tip_x_pad = 4
_G.ou64_checkpoint_tip_y_pad = 2
_G.ou64_checkpoint_tip_y_offset = 10

-- Run Timer
_G.ou64_run_timer_running = false
_G.ou64_run_timer_on_start = false
_G.ou64_run_timer_start_time = 0
gPlayerSyncTable[0].run_time = 0
_G.ou64_run_timer_scale = 1

-- Leaderboard
_G.ou64_leaderboard = nil
_G.ou64_leaderboard_entries_per_packet = 10
_G.ou64_leaderboard_requesting = false
_G.ou64_leaderboard_scale = 1
_G.ou64_leaderboard_entries_per_page = 5

-- Packets
_G.ou64_packet_ids = {
    send_run_data = 0,
    get_leaderboard = 1,
    return_leaderboard = 2,
    clear_leaderboard = 3,
    spectator_camera_settings = 4,
}

-- Map Constants
_G.ou64_map_pad = 16390
_G.ou64_top_height = 25380

-- Server Metrics
_G.ou64_metrics_export_metrics = true
_G.ou64_metrics_start_time = 0
_G.ou64_metrics_heartbeat_last_time = 0
_G.ou64_metrics_heartbeat_interval_frames = 300     -- 10 seconds (300 frames @ 30 fps)
_G.ou64_metrics_player_list_last_time = 0
_G.ou64_metrics_player_list_interval_frames = 300   -- 10 seconds (300 frames @ 30 fps)

-- Warps
_G.ou64_warp_level = _G.ou64_level_id
_G.ou64_warp_area = 1
_G.ou64_warp_act = 0
_G.ou64_warp_node = 10
_G.ou64_warped = false

-- Practice (Warp) Menu
_G.ou64_practice_menu_open = false
_G.ou64_practice_menu_index = 0
_G.ou64_practice_menu_selection_index = 0
_G.ou64_practice_menu_item_height = 32
_G.ou64_practice_menu_returned_neutral = true
_G.ou64_practice_menu = {
    { menu_index = 0, menu_selection_index = 0, text = "Last Warp",                        level = nil,              area = nil, act = nil, node = nil },
    { menu_index = 0, menu_selection_index = 1, text = "Area 1 (Super Mario 64)",          level = nil,              area = 1,   act = nil, node = nil },
    { menu_index = 0, menu_selection_index = 2, text = "Area 2 (The Legend of Zelda)",     level = nil,              area = 2,   act = nil, node = nil },
    { menu_index = 0, menu_selection_index = 3, text = "Area 3 (Pokemon)",                 level = nil,              area = 3,   act = nil, node = nil },
    { menu_index = 0, menu_selection_index = 4, text = "Area 4 (Super Smash 64)",          level = nil,              area = 4,   act = nil, node = nil },
    { menu_index = 0, menu_selection_index = 5, text = "Area 5 (Donkey Kong 64)",          level = nil,              area = 5,   act = nil, node = nil },
    { menu_index = 0, menu_selection_index = 6, text = "Area 6 (Mario Party)",             level = nil,              area = 6,   act = nil, node = nil },
    { menu_index = 0, menu_selection_index = 7, text = "Area 7 (Banjo Kazooie)",           level = nil,              area = 7,   act = nil, node = nil },
    { menu_index = 0, menu_selection_index = 8, text = "Area 8 (N64 Characters)",          level = nil,              area = 0,   act = nil, node = nil },
    { menu_index = 1, menu_selection_index = 0, text = "Area 1 - BoB (Start)",            level = _G.ou64_level_id, area = 1,   act = 0,   node = 10  },
    { menu_index = 1, menu_selection_index = 1, text = "Area 1 - Koopa Shell",            level = _G.ou64_level_id, area = 1,   act = 0,   node = 11  },
    { menu_index = 1, menu_selection_index = 2, text = "Area 1 - Pillars",                level = _G.ou64_level_id, area = 1,   act = 0,   node = 12  },
    { menu_index = 1, menu_selection_index = 3, text = "Area 1 - Whomp's Fortress",       level = _G.ou64_level_id, area = 1,   act = 0,   node = 13  },
    { menu_index = 1, menu_selection_index = 4, text = "Area 1 - Stars (End)",            level = _G.ou64_level_id, area = 1,   act = 0,   node = 14  },
    { menu_index = 2, menu_selection_index = 0, text = "Area 2 - Pot (Start)",            level = _G.ou64_level_id, area = 2,   act = 0,   node = 10  },
    { menu_index = 2, menu_selection_index = 1, text = "Area 2 - Bongos",                 level = _G.ou64_level_id, area = 2,   act = 0,   node = 11  },
    { menu_index = 2, menu_selection_index = 2, text = "Area 2 - Moon",                   level = _G.ou64_level_id, area = 2,   act = 0,   node = 12  },
    { menu_index = 2, menu_selection_index = 3, text = "Area 2 - Heart Piece",            level = _G.ou64_level_id, area = 2,   act = 0,   node = 13  },
    { menu_index = 2, menu_selection_index = 4, text = "Area 2 - Goron",                  level = _G.ou64_level_id, area = 2,   act = 0,   node = 14  },
    { menu_index = 2, menu_selection_index = 5, text = "Area 2 - Majora's Mask",          level = _G.ou64_level_id, area = 2,   act = 0,   node = 15  },
    { menu_index = 2, menu_selection_index = 6, text = "Area 2 - Treasure Chest (End)",   level = _G.ou64_level_id, area = 2,   act = 0,   node = 16  },
    { menu_index = 3, menu_selection_index = 0, text = "Area 3 - Deku Shield (Start)",    level = _G.ou64_level_id, area = 3,   act = 0,   node = 10  },
    { menu_index = 3, menu_selection_index = 1, text = "Area 3 - Onyx",                   level = _G.ou64_level_id, area = 3,   act = 0,   node = 11  },
    { menu_index = 3, menu_selection_index = 2, text = "Area 3 - Squirtle",               level = _G.ou64_level_id, area = 3,   act = 0,   node = 12  },
    { menu_index = 3, menu_selection_index = 3, text = "Area 3 - Dratini",                level = _G.ou64_level_id, area = 3,   act = 0,   node = 13  },
    { menu_index = 3, menu_selection_index = 4, text = "Area 3 - Vaporeon",               level = _G.ou64_level_id, area = 3,   act = 0,   node = 14  },
    { menu_index = 3, menu_selection_index = 5, text = "Area 3 - Nidoqueen (End)",        level = _G.ou64_level_id, area = 3,   act = 0,   node = 15  },
    { menu_index = 4, menu_selection_index = 0, text = "Area 4 - Nidoqueen (Start)",      level = _G.ou64_level_id, area = 4,   act = 0,   node = 10  },
    { menu_index = 4, menu_selection_index = 1, text = "Area 4 - Saffron Towers",         level = _G.ou64_level_id, area = 4,   act = 0,   node = 11  },
    { menu_index = 4, menu_selection_index = 2, text = "Area 4 - Smash Boxes",            level = _G.ou64_level_id, area = 4,   act = 0,   node = 12  },
    { menu_index = 4, menu_selection_index = 3, text = "Area 4 - Captain Falcon",         level = _G.ou64_level_id, area = 4,   act = 0,   node = 13  },
    { menu_index = 4, menu_selection_index = 4, text = "Area 4 - Great Fox",              level = _G.ou64_level_id, area = 4,   act = 0,   node = 14  },
    { menu_index = 4, menu_selection_index = 5, text = "Area 4 - Smash Fan",              level = _G.ou64_level_id, area = 4,   act = 0,   node = 15  },
    { menu_index = 4, menu_selection_index = 6, text = "Area 4 - Luigi (End)",            level = _G.ou64_level_id, area = 4,   act = 0,   node = 16  },
    { menu_index = 5, menu_selection_index = 0, text = "Area 5 - Banana (Start)",         level = _G.ou64_level_id, area = 5,   act = 0,   node = 10  },
    { menu_index = 5, menu_selection_index = 1, text = "Area 5 - Giraffe",                level = _G.ou64_level_id, area = 5,   act = 0,   node = 11  },
    { menu_index = 5, menu_selection_index = 2, text = "Area 5 - Lanky Kong",             level = _G.ou64_level_id, area = 5,   act = 0,   node = 12  },
    { menu_index = 5, menu_selection_index = 3, text = "Area 5 - Mushrooms",              level = _G.ou64_level_id, area = 5,   act = 0,   node = 13  },
    { menu_index = 5, menu_selection_index = 4, text = "Area 5 - Chunky Kong",            level = _G.ou64_level_id, area = 5,   act = 0,   node = 14  },
    { menu_index = 5, menu_selection_index = 5, text = "Area 5 - Hands",                  level = _G.ou64_level_id, area = 5,   act = 0,   node = 15  },
    { menu_index = 5, menu_selection_index = 6, text = "Area 5 - Rambi (End)",            level = _G.ou64_level_id, area = 5,   act = 0,   node = 16  },
    { menu_index = 6, menu_selection_index = 0, text = "Area 6 - Spoon (Start)",          level = _G.ou64_level_id, area = 6,   act = 0,   node = 10  },
    { menu_index = 6, menu_selection_index = 1, text = "Area 6 - Checkers",               level = _G.ou64_level_id, area = 6,   act = 0,   node = 11  },
    { menu_index = 6, menu_selection_index = 2, text = "Area 6 - Koopa",                  level = _G.ou64_level_id, area = 6,   act = 0,   node = 12  },
    { menu_index = 6, menu_selection_index = 3, text = "Area 6 - Thwomp",                 level = _G.ou64_level_id, area = 6,   act = 0,   node = 13  },
    { menu_index = 6, menu_selection_index = 4, text = "Area 6 - SNIFFA",                 level = _G.ou64_level_id, area = 6,   act = 0,   node = 14  },
    { menu_index = 6, menu_selection_index = 5, text = "Area 6 - Cliff (End)",            level = _G.ou64_level_id, area = 6,   act = 0,   node = 15  },
    { menu_index = 7, menu_selection_index = 0, text = "Area 7 - Rare Logo (Start)",      level = _G.ou64_level_id, area = 7,   act = 0,   node = 10  },
    { menu_index = 7, menu_selection_index = 1, text = "Area 7 - Kitchen",                level = _G.ou64_level_id, area = 7,   act = 0,   node = 11  },
    { menu_index = 7, menu_selection_index = 2, text = "Area 7 - Z64",                    level = _G.ou64_level_id, area = 7,   act = 0,   node = 12  },
    { menu_index = 7, menu_selection_index = 3, text = "Area 7 - Box Gap",                level = _G.ou64_level_id, area = 7,   act = 0,   node = 13  },
    { menu_index = 7, menu_selection_index = 4, text = "Area 7 - Pyramid",                level = _G.ou64_level_id, area = 7,   act = 0,   node = 14  },
    { menu_index = 7, menu_selection_index = 5, text = "Area 7 - Smoke Stacks (End)",     level = _G.ou64_level_id, area = 7,   act = 0,   node = 15  },
    { menu_index = 8, menu_selection_index = 0, text = "Area 8 - Smoke Stacks (Start)",   level = _G.ou64_level_id, area = 0,   act = 0,   node = 10  },
    { menu_index = 8, menu_selection_index = 1, text = "Area 8 - Paper Mario",            level = _G.ou64_level_id, area = 0,   act = 0,   node = 11  },
    { menu_index = 8, menu_selection_index = 2, text = "Area 8 - Kirby",                  level = _G.ou64_level_id, area = 0,   act = 0,   node = 12  },
    { menu_index = 8, menu_selection_index = 3, text = "Area 8 - Glover",                 level = _G.ou64_level_id, area = 0,   act = 0,   node = 13  },
    { menu_index = 8, menu_selection_index = 4, text = "Area 8 - Earthworm Jim",          level = _G.ou64_level_id, area = 0,   act = 0,   node = 14  },
    { menu_index = 8, menu_selection_index = 5, text = "Area 8 - Mario Knee",             level = _G.ou64_level_id, area = 0,   act = 0,   node = 15  },
    { menu_index = 8, menu_selection_index = 6, text = "Area 8 - Mario Glove",            level = _G.ou64_level_id, area = 0,   act = 0,   node = 16  },
    { menu_index = 8, menu_selection_index = 7, text = "Area 8 - Mario Hat (End)",        level = _G.ou64_level_id, area = 0,   act = 0,   node = 17  },
}
