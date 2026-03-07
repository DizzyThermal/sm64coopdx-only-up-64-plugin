-- Textures
checkpoint_flag = get_texture_info("checkpoint-flag")

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

-- Only Up 64 Plugin API (External Functions)
_G.ou64_plugin_api = {
    settings = {
        enable_moveset = true,
    },
}

-- Active Mods
ou64_plugin_active = true
ou64_active = mod_active_exact("\\#FAFF20\\Only Up 64") or
        mod_active("Only Up 64 v") or
        mod_active("Only Up 64 %(v")
ou64_flood_active = mod_active("Flood")

-- Toggleable Features
ou64_settings_loaded = false
ou64_settings = {
    enable_arcade_mode = false,
    enable_checkpoints = true,
    enable_moveset = true,
    enable_music = true,
    show_character_height = true,
    show_height_meter = true,
    show_leaderboard = true,
    show_run_timer = true,
}

-- Only Up 64 Moveset
ou64_moveset_twirling = false
ou64_moveset_twirl_counter = 0
ou64_moveset_twirl_count = 10

-- Character Height
ou64_character_height_scale = 1
ou64_character_height_x_pad = 30
ou64_character_height_x_pad_negative = 13
ou64_character_height_y_pad = 4
ou64_character_height_y_pad_negative = 3

-- Checkpoints
ou64_checkpoint_placed = false
ou64_checkpoint_used = false
ou64_checkpoint_flag_obj = nil
ou64_checkpoint_x = 0
ou64_checkpoint_y = 0
ou64_checkpoint_z = 0
ou64_checkpoint_face_angle_y = 0
ou64_checkpoint_cam_pos_x = 0
ou64_checkpoint_cam_pos_y = 0
ou64_checkpoint_cam_pos_z = 0
ou64_checkpoint_cam_focus_x = 0
ou64_checkpoint_cam_focus_y = 0
ou64_checkpoint_cam_focus_z = 0
ou64_checkpoint_cam_yaw = 0
ou64_checkpoint_area = 1
ou64_checkpoint_warping = false
ou64_checkpoint_warp_time = 0
ou64_checkpoint_count = 0
gPlayerSyncTable[0].checkpoint_count = 0

-- Run Timer
ou64_run_timer_running = false
ou64_run_timer_on_start = false
ou64_run_timer_start_time = 0
gPlayerSyncTable[0].run_time = 0
ou64_run_timer_scale = 1

-- Leaderboard
ou64_leaderboard = nil
ou64_leaderboard_entries_per_packet = 10
ou64_leaderboard_requesting = false
ou64_leaderboard_scale = 1
ou64_leaderboard_entries_per_page = 5
ou64_leaderboard_page = 0

ou64_flood_leaderboard = nil
ou64_flood_leaderboard_entries_per_packet = 8
ou64_flood_leaderboard_requesting = false
ou64_flood_leaderboard_scale = 1
ou64_flood_leaderboard_entries_per_page = 5

-- Spectator Mode
ou64_spectator_mode = false
ou64_spectator_warping = false
ou64_spectator_warp_time = 0
ou64_prev_info_saved = false
ou64_camera_index = 0
ou64_spectator_prev_level = _G.ou64_level_id
ou64_spectator_prev_area = 1
ou64_spectator_prev_pos_x = 0
ou64_spectator_prev_pos_y = 0
ou64_spectator_prev_pos_z = 0
ou64_spectator_prev_face_angle_y = 0
ou64_l_button_pressed = false
ou64_r_button_pressed = false

lLakituStates = {}
for i = 0, MAX_PLAYERS - 1 do
    lLakituStates[i] = {
        pos = { x = 0, y = 0, z = 0, },
        focus = { x = 0, y = 0, z = 0, },
        yaw = 0,
        posHSpeed = 0,
        posVSpeed = 0,
        focHSpeed = 0,
        focVSpeed = 0,
    }
end

-- Packets
ou64_packet_ids = {
    -- OU64 Packets
    send_run_data = 0,
    get_leaderboard = 1,
    return_leaderboard = 2,
    clear_leaderboard = 3,
    spectator_camera_settings = 4,
    -- OU64 Flood Packets
    send_flood_run_data = 10,
    get_flood_leaderboard = 11,
    return_flood_leaderboard = 12,
    clear_flood_leaderboard = 13,
}

-- Map Constants
ou64_map_pad = 16390
ou64_top_height = 25380

-- Server Metrics
ou64_metrics_export_metrics = true
ou64_metrics_start_time = 0
ou64_metrics_heartbeat_last_time = 0
ou64_metrics_heartbeat_interval_frames = 300     -- 10 seconds (300 frames @ 30 fps)
ou64_metrics_player_list_last_time = 0
ou64_metrics_player_list_interval_frames = 300   -- 10 seconds (300 frames @ 30 fps)

-- State Variables
ou64_plugin_debug = false

-- Warps
ou64_warp_level = _G.ou64_level_id
ou64_warp_area = 1
ou64_warp_act = 0
ou64_warp_node = 10
ou64_warped = false

-- Menu
ou64_menu_show_menu = false
ou64_menu_state_changed = false
ou64_menu_repeat_delay = 4
ou64_menu_last_up = 0
ou64_menu_last_down = 0
ou64_menu_index = 0
ou64_menu_selection_index = 0
ou64_menu_stick_returned_neutral = true
ou64_menu_ids = {
    main_menu = 0,
    practice_main_menu = 10,
    practice_area_1_menu = 11,
    practice_area_2_menu = 12,
    practice_area_3_menu = 13,
    practice_area_4_menu = 14,
    practice_area_5_menu = 15,
    practice_area_6_menu = 16,
    practice_area_7_menu = 17,
    practice_area_8_menu = 18,
    settings_menu = 20,
}
ou64_menus = {
    [ou64_menu_ids.main_menu] = {
        title = "Main Menu",
        entries = {
            { action = "menu", text = "Practice Menu", menu_id = ou64_menu_ids.practice_main_menu },
            { action = "restart-level", text = "Restart Level" },
            { action = "spectator-mode", text = "Spectator Mode" },
            { action = "menu", text = "Settings", menu_id = ou64_menu_ids.settings_menu },
        },
    },
    [ou64_menu_ids.practice_main_menu] = {
        title = "Practice Menu",
        align = "left",
        entries = {
            { action = "menu", text = "Area 1: Super Mario 64", menu_id = ou64_menu_ids.practice_area_1_menu, prev_menu_id = ou64_menu_ids.main_menu, prev_menu_index = 0 },
            { action = "menu", text = "Area 2: The Legend of Zelda", menu_id = ou64_menu_ids.practice_area_2_menu, prev_menu_id = ou64_menu_ids.main_menu, prev_menu_index = 0 },
            { action = "menu", text = "Area 3: Pokemon", menu_id = ou64_menu_ids.practice_area_3_menu, prev_menu_id = ou64_menu_ids.main_menu, prev_menu_index = 0 },
            { action = "menu", text = "Area 4: Super Smash 64", menu_id = ou64_menu_ids.practice_area_4_menu, prev_menu_id = ou64_menu_ids.main_menu, prev_menu_index = 0 },
            { action = "menu", text = "Area 5: Donkey Kong 64", menu_id = ou64_menu_ids.practice_area_5_menu, prev_menu_id = ou64_menu_ids.main_menu, prev_menu_index = 0 },
            { action = "menu", text = "Area 6: Mario Party", menu_id = ou64_menu_ids.practice_area_6_menu, prev_menu_id = ou64_menu_ids.main_menu, prev_menu_index = 0 },
            { action = "menu", text = "Area 7: Banjo Kazooie", menu_id = ou64_menu_ids.practice_area_7_menu, prev_menu_id = ou64_menu_ids.main_menu, prev_menu_index = 0 },
            { action = "menu", text = "Area 8: N64 Characters", menu_id = ou64_menu_ids.practice_area_8_menu, prev_menu_id = ou64_menu_ids.main_menu, prev_menu_index = 0 },
            { action = "warp", text = "Ending", align = "center", level = _G.ou64_end_level_id, area = 1, act = 0, node = 10, prev_menu_id = ou64_menu_ids.main_menu, prev_menu_index = 0 },
        },
    },
    [ou64_menu_ids.practice_area_1_menu] = {
        title = "Area 1: Super Mario 64",
        align = "left",
        entries = {
            { action = "warp", text = "Bob-Omb Battlefield", level = _G.ou64_level_id, area = 1, act = 0, node = 10, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 0 },
            { action = "warp", text = "Koopa Shells", level = _G.ou64_level_id, area = 1, act = 0, node = 11, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 0 },
            { action = "warp", text = "HMC Pillars", level = _G.ou64_level_id, area = 1, act = 0, node = 12, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 0 },
            { action = "warp", text = "Whomp's Fortress", level = _G.ou64_level_id, area = 1, act = 0, node = 13, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 0 },
            { action = "warp", text = "Stars", level = _G.ou64_level_id, area = 1, act = 0, node = 14, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 0 },
        },
    },
    [ou64_menu_ids.practice_area_2_menu] = {
        title = "Area 2: The Legend of Zelda",
        align = "left",
        entries = {
            { action = "warp", text = "Pot", level = _G.ou64_level_id, area = 2, act = 0, node = 10, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 1 },
            { action = "warp", text = "Bongos", level = _G.ou64_level_id, area = 2, act = 0, node = 11, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 1 },
            { action = "warp", text = "Moon", level = _G.ou64_level_id, area = 2, act = 0, node = 12, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 1 },
            { action = "warp", text = "Heart Piece", level = _G.ou64_level_id, area = 2, act = 0, node = 13, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 1 },
            { action = "warp", text = "Goron", level = _G.ou64_level_id, area = 2, act = 0, node = 14, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 1 },
            { action = "warp", text = "Majora's Mask", level = _G.ou64_level_id, area = 2, act = 0, node = 15, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 1 },
            { action = "warp", text = "Treasure Chests", level = _G.ou64_level_id, area = 2, act = 0, node = 16, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 1 },
        },
    },
    [ou64_menu_ids.practice_area_3_menu] = {
        title = "Area 3: Pokemon",
        align = "left",
        entries = {
            { action = "warp", text = "Deku Shield", level = _G.ou64_level_id, area = 3, act = 0, node = 10, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 2 },
            { action = "warp", text = "Onyx", level = _G.ou64_level_id, area = 3, act = 0, node = 11, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 2 },
            { action = "warp", text = "Squirtle", level = _G.ou64_level_id, area = 3, act = 0, node = 12, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 2 },
            { action = "warp", text = "Dratini", level = _G.ou64_level_id, area = 3, act = 0, node = 13, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 2 },
            { action = "warp", text = "Vaporeon", level = _G.ou64_level_id, area = 3, act = 0, node = 14, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 2 },
            { action = "warp", text = "Nidoqueen", level = _G.ou64_level_id, area = 3, act = 0, node = 15, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 2 },
        },
    },
    [ou64_menu_ids.practice_area_4_menu] = {
        title = "Area 4: Super Smash 64",
        align = "left",
        entries = {
            { action = "warp", text = "Nidoqueen", level = _G.ou64_level_id, area = 4, act = 0, node = 10, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 3 },
            { action = "warp", text = "Saffron Towers", level = _G.ou64_level_id, area = 4, act = 0, node = 11, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 3 },
            { action = "warp", text = "Smash Boxes", level = _G.ou64_level_id, area = 4, act = 0, node = 12, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 3 },
            { action = "warp", text = "Captain Falcon", level = _G.ou64_level_id, area = 4, act = 0, node = 13, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 3 },
            { action = "warp", text = "Great Fox", level = _G.ou64_level_id, area = 4, act = 0, node = 14, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 3 },
            { action = "warp", text = "Smash Fan", level = _G.ou64_level_id, area = 4, act = 0, node = 15, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 3 },
            { action = "warp", text = "Luigi", level = _G.ou64_level_id, area = 4, act = 0, node = 16, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 3 },
        },
    },
    [ou64_menu_ids.practice_area_5_menu] = {
        title = "Area 5: Donkey Kong 64",
        align = "left",
        entries = {
            { action = "warp", text = "Banana", level = _G.ou64_level_id, area = 5, act = 0, node = 10, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 4 },
            { action = "warp", text = "Giraffe", level = _G.ou64_level_id, area = 5, act = 0, node = 11, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 4 },
            { action = "warp", text = "Lanky Kong", level = _G.ou64_level_id, area = 5, act = 0, node = 12, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 4 },
            { action = "warp", text = "Mushrooms", level = _G.ou64_level_id, area = 5, act = 0, node = 13, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 4 },
            { action = "warp", text = "DK Key", level = _G.ou64_level_id, area = 5, act = 0, node = 14, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 4 },
            { action = "warp", text = "Hands", level = _G.ou64_level_id, area = 5, act = 0, node = 15, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 4 },
            { action = "warp", text = "Rambi", level = _G.ou64_level_id, area = 5, act = 0, node = 16, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 4 },
        },
    },
    [ou64_menu_ids.practice_area_6_menu] = {
        title = "Area 6: Mario Party",
        align = "left",
        entries = {
            { action = "warp", text = "Spoon", level = _G.ou64_level_id, area = 6, act = 0, node = 10, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 5 },
            { action = "warp", text = "Checkers", level = _G.ou64_level_id, area = 6, act = 0, node = 11, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 5 },
            { action = "warp", text = "Koopa", level = _G.ou64_level_id, area = 6, act = 0, node = 12, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 5 },
            { action = "warp", text = "Thwomp", level = _G.ou64_level_id, area = 6, act = 0, node = 13, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 5 },
            { action = "warp", text = "Snifit", level = _G.ou64_level_id, area = 6, act = 0, node = 14, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 5 },
            { action = "warp", text = "Cliff Tower", level = _G.ou64_level_id, area = 6, act = 0, node = 15, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 5 },
        },
    },
    [ou64_menu_ids.practice_area_7_menu] = {
        title = "Area 7: Banjo Kazooie",
        align = "left",
        entries = {
            { action = "warp", text = "Rare Logo", level = _G.ou64_level_id, area = 7, act = 0, node = 10, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 6 },
            { action = "warp", text = "Kitchen", level = _G.ou64_level_id, area = 7, act = 0, node = 11, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 6 },
            { action = "warp", text = "Z64", level = _G.ou64_level_id, area = 7, act = 0, node = 12, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 6 },
            { action = "warp", text = "Box Gap", level = _G.ou64_level_id, area = 7, act = 0, node = 13, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 6 },
            { action = "warp", text = "Pyramid", level = _G.ou64_level_id, area = 7, act = 0, node = 14, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 6 },
            { action = "warp", text = "Watermelon Box", level = _G.ou64_level_id, area = 7, act = 0, node = 15, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 6 },
        },
    },
    [ou64_menu_ids.practice_area_8_menu] = {
        title = "Area 8: N64 Characters",
        align = "left",
        entries = {
            { action = "warp", text = "Smoke Stacks", level = _G.ou64_level_id, area = 0, act = 0, node = 10, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 7 },
            { action = "warp", text = "Paper Mario", level = _G.ou64_level_id, area = 0, act = 0, node = 11, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 7 },
            { action = "warp", text = "Kirby", level = _G.ou64_level_id, area = 0, act = 0, node = 12, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 7 },
            { action = "warp", text = "Glover", level = _G.ou64_level_id, area = 0, act = 0, node = 13, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 7 },
            { action = "warp", text = "Earthworm Jim", level = _G.ou64_level_id, area = 0, act = 0, node = 14, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 7 },
            { action = "warp", text = "Mario Knee", level = _G.ou64_level_id, area = 0, act = 0, node = 15, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 7 },
            { action = "warp", text = "Mario Glove", level = _G.ou64_level_id, area = 0, act = 0, node = 16, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 7 },
            { action = "warp", text = "Mario Hat", level = _G.ou64_level_id, area = 0, act = 0, node = 17, prev_menu_id = ou64_menu_ids.practice_main_menu, prev_menu_index = 7 },
        },
    },
    [ou64_menu_ids.settings_menu] = {
        title = "Settings",
        align = "left",
        entries = {
            { action = "setting-toggle", text = "Enable Checkpoints", setting_id = "enable_checkpoints", prev_menu_id = ou64_menu_ids.main_menu, prev_menu_index = 3 },
            { action = "setting-toggle", text = "Enable Only Up 64 Moveset", setting_id = "enable_moveset", prev_menu_id = ou64_menu_ids.main_menu, prev_menu_index = 3 },
            { action = "setting-toggle", text = "Play Only Up 64 Music", setting_id = "enable_music", prev_menu_id = ou64_menu_ids.main_menu, prev_menu_index = 3 },
            { action = "setting-toggle", text = "Show Height Meter", setting_id = "show_height_meter", prev_menu_id = ou64_menu_ids.main_menu, prev_menu_index = 3 },
            { action = "setting-toggle", text = "Show Leaderboard", setting_id = "show_leaderboard", prev_menu_id = ou64_menu_ids.main_menu, prev_menu_index = 3 },
            { action = "setting-toggle", text = "Show Run Timer", setting_id = "show_run_timer", prev_menu_id = ou64_menu_ids.main_menu, prev_menu_index = 3 },
            { action = "setting-toggle", text = "Show Y Position", setting_id = "show_character_height", prev_menu_id = ou64_menu_ids.main_menu, prev_menu_index = 3 },
            { action = "reset-settings", text = "Reset Settings", align = "center", prev_menu_id = ou64_menu_ids.main_menu, prev_menu_index = 3 },
        },
    },
}

-- Arcade Mode: Beds
E_MODEL_BED = smlua_model_util_get_id("bed_geo")
define_custom_obj_fields({
    oBedStrength = "s32",
})
ou64_arcade_beds = {
    [1] = {
        { x = 6399, y = -16402, z = -4552, a = 0x0000, strength = 110 },    -- Start
        { x = 2306, y = -15690, z = -1022, a = -0x2000, strength = 200 },   -- Bridge Pillar
        { x = -563, y = -11140, z = -1445, a = -0x2000, strength = 165 },   -- Fountain
        { x = -4354, y = -9898, z = -2013, a = -0x2000, strength = 145 },   -- Castle
        { x = -3534, y = -6675, z = 134, a = 0x2000, strength = 150 },      -- Ice Platform (Upper)
        { x = -5174, y = -7135, z = -828, a = 0x4000, strength = 100 },     -- Ice Platform (Lower)
        { x = -2318, y = -4128, z = 972, a = 0x0000, strength = 145 },      -- HMC Pillars
        { x = -1872, y = -1815, z = 2170, a = 0x0000, strength = 125 },     -- Pyramid (Bottom)
        { x = -1671, y = -515, z = 3973, a = 0x0000, strength = 135 },      -- Pyramid (Top)
        { x = -1162, y = 1690, z = 5325, a = -0x2000, strength = 200 },     -- Pyramid Pillar
        { x = -1391, y = 5260, z = 1715, a = 0x0000, strength = 189 },      -- Air
        { x = -2844, y = 8000, z = -1501, a = 0x0000, strength = 162 },     -- "M"
        { x = -3575, y = 11660, z = -4242, a = 0x0000, strength = 190 },    -- Whomp's Platform
        { x = -1224, y = 15295, z = -790, a = 0x0000, strength = 140 },     -- Star
    },
    [2] = {
        { x = 1844, y = -15400, z = -1836, a = -0x6000, strength = 175 },   -- Start to Triforce
        { x = -3234, y = -13750, z = -3216, a = -0x2000, strength = 190 },  -- Triforce to Bongo
        { x = -2609, y = -11500, z = 1847, a = 0x4000, strength = 90 },     -- Bongo to Bongo
        { x = 2310, y = -9120, z = -841, a = -0x6000, strength = 130 },     -- Bongo to N64
        { x = 1831, y = -7235, z = -2707, a = -0x6000, strength = 140 },    -- N64 to Moon
        { x = -3772, y = -3420, z = -3564, a = 0x0000, strength = 160 },    -- Sword to Stone
        { x = -3611, y = 0, z = 541, a = 0x0000, strength = 210 },          -- Stone to Tree
        { x = 539, y = 4540, z = 2180, a = 0x0000, strength = 200 },        -- Tree to Goron
        { x = 3154, y = 6750, z = -3912, a = 0x0000, strength = 80 },       -- Goron to Platform
        { x = -1045, y = 7200, z = -4200, a = 0x0000, strength = 150 },     -- Platform to Platform
        { x = -4666, y = 8900, z = -330, a = 0x0000, strength = 80 },       -- Platform to Cave
        { x = -5375, y = 9500, z = 1700, a = 0x0000, strength = 110 },      -- Cave to Majora
        { x = -3851, y = 10950, z = 52, a = 0x0000, strength = 130 },       -- Majora to Chest
        { x = -5000, y = 13680, z = -1265, a = 0x0000, strength = 110 },    -- Chest to Chest
    },
    [3] = {
        { x = -4642, y = -16150, z = 1939, a = 0x4000, strength = 170 },    -- Start
        { x = -2409, y = -14550, z = 4372, a = 0x4000, strength = 120 },    -- Bulbasaur
        { x = -176, y = -13026, z = 5219, a = -0x2000, strength = 160 },    -- Bulbasaur to Metapod
        { x = 1756, y = -10546, z = 4099, a = 0x0000, strength = 230 },     -- Metapod to Onyx
        { x = -3322, y = -7129, z = 294, a = 0x2000, strength = 90 },       -- Onyx
        { x = -3312, y = -6838, z = -1994, a = -0x2000, strength = 120 },   -- Onyx
        { x = -1304, y = -5601, z = -3692, a = 0x2000, strength = 240 },    -- Onyx to Squirtle
        { x = 3422, y = -600, z = -916, a = 0x0000, strength = 200 },       -- Squirtle to Dratini
        { x = 2855, y = 2400, z = 2292, a = 0x0000, strength = 160 },       -- Dratini to Parasect
        { x = 1303, y = 5590, z = 5917, a = 0x0000, strength = 160 },       -- Parasect to Vaporeon
        { x = -1171, y = 8200, z = 5578, a = 0x0000, strength = 160 },      -- Vaporeon
        { x = -3537, y = 10767, z = 5144, a = 0x0000, strength = 70 },      -- Vaporeon to Porygon
        { x = -5017, y = 10889, z = 5085, a = 0x0000, strength = 70 },      -- Porygon
        { x = -6559, y = 12570, z = 5151, a = 0x0000, strength = 185 },     -- Porygon to Nidoqueen
    },
    [4] = {
        { x = -4279, y = -15199, z = 1504, a = 0x0000, strength = 100 },    -- Start
        { x = -3387, y = -14150, z = 928, a = 0x0000, strength = 160 },     -- Tower
        { x = -4171, y = -9529, z = -1195, a = 0x2000, strength = 160 },    -- Saffron Towers
        { x = -2061, y = -5952, z = -1439, a = 0x4000, strength = 140 },    -- Saffron Towers to Captain Falcon
        { x = 421, y = -4769, z = -281, a = 0x0000, strength = 160 },       -- Captain Falcon
        { x = 1037, y = -1970, z = 3151, a = 0x0000, strength = 140 },      -- Captain Falcon to Metal Cavern
        { x = 1791, y = -30, z = 4949, a = 0x4000, strength = 220 },        -- Metal Cavern to Great Fox
        { x = 4626, y = 3654, z = 3058, a = 0x2000, strength = 270 },       -- Great Fox to Barrel
        { x = -863, y = 7901, z = -1900, a = 0x0000, strength = 160 },      -- Barrel to Fan
        { x = -2470, y = 10428, z = -3614, a = 0x0000, strength = 230 },    -- Fan to Luigi
    },
    [5] = {},
    [6] = {},
    [7] = {},
    [8] = {},
}
