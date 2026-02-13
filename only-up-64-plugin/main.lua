-- name: \\#FAFF20\\Only Up \\#E01F2D\\Plugin
-- description: \\#FAFF20\\Only Up 64 Plugin\\#FFF\\ v2.0.0\nBy \\#E01F2D\\DizzyThermal\\#FFF\\\n\nAdds the following features:\n > Only Up 64 Moveset\n > Heights (HUD and Playerlist)\n > Checkpoints\n > Leaderboards\n > Warp Menu (Disabled by Default)\n > Exportable Metrics\n\nSpecial thanks to \\#0868EC\\steven3004\\#FFF\\ for movement fixes and sparkle particles\nSpecial thanks to \\#4E6D29\\djoslin0\\#FFF\\ for checkpoints - modified to work with multiple areas\nSpecial thanks to \\#EEA7B0\\EmilyEmmi\\#FFF\\ for recolorable player heads in height meter

local math_floor,string_format = math.floor,string.format

local ByteReader = require('a-bytereader')
local ByteWriter = require('a-bytewriter')

-- Load Plugin Settings on Load
load_plugin_settings()

-- Render Character Height / Menu
hook_event(HOOK_ON_HUD_RENDER, function()
    m = gMarioStates[0]

    -- If in cutscene or Act Selector, don't render anything
    if m.action == ACT_END_PEACH_CUTSCENE or
            m.action == ACT_CREDITS_CUTSCENE or
            m.action == ACT_END_WAVING_CUTSCENE or
            obj_get_first_with_behavior_id(id_bhvActSelector) ~= nil then return end

    -- Render Character Height on HUD (Y Value)
    if _G.ou64_show_character_height and
            not _G.ou64_flood_active then
        render_character_height()
    end

    -- Render Practice Menu
    if _G.ou64_practice_menu_open then
        render_practice_menu()
    end

    -- Render Checkpoint Tip
    if _G.ou64_active and 
            not _G.ou64_flood_active and
            _G.ou64_enable_checkpoints and
            (not _G.ou64_checkpoint_placed or
                not _G.ou64_checkpoint_used) then
        render_checkpoint_tip()
    end

    -- Timer Render Current Run
    if _G.ou64_active and
            not _G.ou64_flood_active and
            _G.ou64_show_run_timer then
        render_run_timer()
    end

    -- Leaderboard --
    if _G.ou64_active and
            not _G.ou64_flood_active and
            _G.ou64_show_leaderboard then
        render_leaderboard()
    end

    -- Player Height Meter
    if _G.ou64_show_height_meter and
            _G.ou64_active and
            (not _G.ou64_flood_active or not _G.ou64_flood_in_lobby) then
        render_height_meter()
    end
end)

-- Mario Update Hook --
hook_event(HOOK_MARIO_UPDATE, function(m)
    if not _G.ou64_enable_moveset or
            m.playerIndex ~= 0 then
        return
    end

    -- Ground Pound Dive Out (From: mods/extended-moveset.lua)
    if m.action == ACT_GROUND_POUND and
            (m.input & INPUT_B_PRESSED) ~= 0 then
        if (m.input & INPUT_NONZERO_ANALOG) ~= 0 then
            m.faceAngle.y = m.intendedYaw
        end
        mario_set_forward_vel(m, 10.0)
        m.vel.y = 35.0
        set_mario_action(m, ACT_DIVE, 0)
    end

    -- Ground Pound Twirl
    if m.action == ACT_GROUND_POUND and
            (m.input & INPUT_A_PRESSED) ~= 0 then
        _G.ou64_moveset_twirling = true
        _G.ou64_moveset_twirl_counter = 0
        m.vel.y = 40.0
        set_mario_action(m, ACT_TWIRLING, 0)
    end

    -- Ground Pound Jump (From: mods/extended-moveset.lua)
    if m.action == ACT_GROUND_POUND_LAND and
            (m.input & INPUT_A_PRESSED) ~= 0 then
        set_mario_action(m, ACT_TRIPLE_JUMP, 0)
    end

    -- Instant Turn
    if m.action == ACT_WALKING and
            analog_stick_held_back(m) ~= 0 and
            m.forwardVel > 0 and
            m.forwardVel < 16 and
            (m.input & INPUT_NONZERO_ANALOG) ~= 0 then
        m.faceAngle.y = m.intendedYaw
    end

    -- Checkpoints
    if bind_tp(m) and
            not _G.ou64_flood_active then
        teleport()
    elseif bind_cp(m) and 
            not _G.ou64_flood_active then
        checkpoint()
    end

    -- Timer
    if not _G.ou64_flood_active then
        if standing_on_start_timer(m) then
            -- Standing on Timer (Reset Run)
            _G.ou64_run_timer_on_start = true
            reset_timer()
            reset_checkpoints()
	    gPlayerSyncTable[0].checkpoint_count = 0
        elseif not standing_on_start_timer(m) and 
                _G.ou64_run_timer_on_start then
            -- Just Left Start (Start Run)
            _G.ou64_run_timer_on_start = false
            _G.ou64_run_timer_running = true
            _G.ou64_run_timer_start_time = get_global_timer()
            gPlayerSyncTable[0].run_time = get_global_timer() - _G.ou64_run_timer_start_time
            _G.ou64_checkpoint_x = 0
            _G.ou64_checkpoint_y = m.pos.y - 100
            _G.ou64_checkpoint_z = 0
            _G.ou64_checkpoint_area = 1
            _G.ou64_checkpoint_placed = false
            _G.ou64_checkpoint_used = false
            _G.ou64_checkpoint_count = 0
            gPlayerSyncTable[0].checkpoint_count = 0
            djui_chat_message_create("Run Started... GO!")
            play_sound(SOUND_GENERAL_RACE_GUN_SHOT, m.marioObj.header.gfx.cameraToObject)
        elseif standing_on_end_timer(m) and 
                _G.ou64_run_timer_running then
            -- Standing on Top (Stop Timer, End Run)
            _G.ou64_run_timer_running = false
            -- Create Run Data
            local timestamp_sec = get_time()
            local time_elapsed = get_global_timer() - _G.ou64_run_timer_start_time
            local run_time_msec = delta_to_msec(time_elapsed)
            local checkpoints_used = _G.ou64_checkpoint_count
            local player_model = gMarioStates[0].character.type
            local hair_part = player_model ~= 2 and HAIR or GLOVES
            local player_hair = pack_color_int(network_player_get_override_palette_color(gNetworkPlayers[0], hair_part))
            local player_skin = pack_color_int(network_player_get_override_palette_color(gNetworkPlayers[0], SKIN))
            local player_cap = pack_color_int(network_player_get_override_palette_color(gNetworkPlayers[0], CAP))
            local player_uuid = get_ou64_id()
            local coopnet_id = get_coopnet_id(gNetworkPlayers[0].localIndex)
            local player_name = gNetworkPlayers[0].name
            local is_player_best_time = is_best_time(player_uuid, run_time_msec)
            local announce_detail = is_player_best_time and "\n      \\#FAFF20\\A personal best!\\#FFFFFF\\" or ""
            -- Create Packet and Send to Everyone
            local packet = ByteWriter:new()
            packet:u8(_G.ou64_packet_ids.send_run_data)
            packet:u32(timestamp_sec)
            packet:u32(run_time_msec)
            packet:u16(checkpoints_used)
            packet:u8(player_model)
            packet:u32(player_hair)
            packet:u32(player_skin)
            packet:u32(player_cap)
            packet:string(player_uuid)
            packet:string(coopnet_id)
            packet:string(player_name)
            network_send_bytestring(
                true,
                packet:serialize()
            )
            add_to_leaderboard(
                timestamp_sec,
                run_time_msec,
                checkpoints_used,
                player_model,
                player_hair,
                player_skin,
                player_cap,
                player_uuid,
                coopnet_id,
                player_name)
            djui_chat_message_create(
                string_format("\\#FAFF20\\%s \\#FFFFFF\\completed an \\#FAFF20\\Only Up 64\\#FFFFFF\\ run\n  %s  %s %s%s",
                    player_name,
                    format_msec(run_time_msec),
                    checkpoints_used,
                    checkpoints_used == 1 and "checkpoint" or "checkpoints",
                    announce_detail)
            )
            reset_timer()
            reset_checkpoints()
        end
    end
    if not _G.ou64_flood_active and 
            standing_on_end_timer(m) then
        djui_chat_message_create("WARPING")
        warp_to_level(_G.ou64_end_level_id, 1, _G.ou64_act_id)
    end

    -- Export Spectator Camera Settings
    --if gPlayerSyncTable[0].run_time > 0 then
    --    network_send(true, {
    --        packet_id = _G.ou64_packet_ids.spectator_camera_settings,
    --        player_index = network_global_index_from_local(0),
    --        posX = gLakituState.pos.x,
    --        posY = gLakituState.pos.y,
    --        posZ = gLakituState.pos.z,
    --        focusX = gLakituState.focus.x,
    --        focusY = gLakituState.focus.y,
    --        focusZ = gLakituState.focus.z,
    --        yaw = gLakituState.yaw,
    --        posHSpeed = gLakituState.posHSpeed,
    --        posVSpeed = gLakituState.posVSpeed,
    --        focHSpeed = gLakituState.focHSpeed,
    --        focVSpeed = gLakituState.focVSpeed,
    --    })
    --end

    -- DEBUG (SERVER ONLY)
    if bind_debug(m) and
            network_is_server() then
        debug()
    end
end)

function debug()
    -- Print OU64 ID
    djui_chat_message_create(string_format("%s", get_ou64_id()))

    -- Print Location
    local m = gMarioStates[0]
    local mpos = m.pos
    djui_chat_message_create(string.format("%s, %s, %s", mpos.x, mpos.y, mpos.z))

    -- Warp to Ending
    --warp_to_warpnode(_G.ou64_level_id, 0, _G.ou64_act_id, 0x11)
end

function teleport()
    m = gMarioStates[0]

    if _G.ou64_enable_checkpoints and _G.ou64_checkpoint_placed then
        if _G.ou64_checkpoint_area ~= m.area.index then
            m.area.index = _G.ou64_checkpoint_area
            warp_to_level(_G.ou64_level_id, m.area.index, _G.ou64_act_id)
        end
        m.pos.x = _G.ou64_checkpoint_x
        m.pos.y = _G.ou64_checkpoint_y
        m.pos.z = _G.ou64_checkpoint_z
        m.vel.x = 0
        m.vel.y = 0
        m.vel.z = 0

        m.marioObj.oIntangibleTimer = 0
        m.hurtCounter = 0
        m.healCounter = 31
        m.health = 0x100
        m.invincTimer = 30 * 3

        set_mario_action(m, ACT_IDLE, 0)
        m.statusForCamera.action = ACT_IDLE
        soft_reset_camera(m.area.camera)
        _G.ou64_checkpoint_used = true
    end
end

function checkpoint()
    m = gMarioStates[0]

    local stationary = (m.action & ACT_FLAG_STATIONARY) ~= 0
    local ledge_grabbing = m.action == ACT_LEDGE_GRAB

    if _G.ou64_enable_checkpoints and 
            stationary and
            not ledge_grabbing and
            not (_G.ou64_checkpoint_x == m.pos.x and 
                 _G.ou64_checkpoint_y == m.pos.y and
                 _G.ou64_checkpoint_z == m.pos.z) then
        _G.ou64_checkpoint_x = m.pos.x
        _G.ou64_checkpoint_y = m.pos.y
        _G.ou64_checkpoint_z = m.pos.z
        _G.ou64_checkpoint_area = m.area.index
        _G.ou64_checkpoint_placed = true
        _G.ou64_checkpoint_count = _G.ou64_checkpoint_count + 1
	    gPlayerSyncTable[0].checkpoint_count = _G.ou64_checkpoint_count
    end
end

hook_event(HOOK_ON_SYNC_VALID, function()
    local m = gMarioStates[0]
    _G.ou64_checkpoint_flag_obj = spawn_non_sync_object(
        id_bhvCheckpointFlag,
        E_MODEL_KOOPA_FLAG,
        m.pos.x, m.pos.y, m.pos.z,
        nil
    )
end)

-- On Set Mario Action Hook --
hook_event(HOOK_ON_SET_MARIO_ACTION, function(m)
    if not _G.ou64_enable_moveset then return end

    if m.action == ACT_WALL_SLIDE then
        m.vel.y = 0.0
    elseif m.action == ACT_AIR_HIT_WALL then
		return set_mario_action(m, ACT_KAZE_AIR_HIT_WALL, 0)
    elseif m.action == ACT_DIVE_SLIDE then
		return set_mario_action(m, ACT_KAZE_DIVE_SLIDE, 0)
    elseif m.action == ACT_KAZE_AIR_HIT_WALL and (m.input & INPUT_A_PRESSED) ~= 0 then
        m.vel.y = 52.0
        m.faceAngle.y = limit_angle(m.faceAngle.y + 0x8000)
        m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
        return set_mario_action(m, ACT_WALL_KICK_AIR, 0)
    end

    -- Get Sparkles from Speed Kicks.
    if m.action == ACT_JUMP_KICK and m.forwardVel >= 40 then
        m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
    end
end)

-- Update Hook --
hook_event(HOOK_UPDATE, function()
    local m = gMarioStates[0]

    -- Update Character Height and add to gPlayerSyncTable for other players
    local character_height = math_floor(m.pos.y)
    if _G.ou64_active then
        if gNetworkPlayers[0].currLevelNum == _G.ou64_end_level_id then
            character_height = _G.ou64_top_height
        else
            local area_index = m.area.index - 1
            if area_index < 0 then
                area_index = 7
            end
            character_height = math_floor((_G.ou64_map_pad + (32000 * area_index) + m.pos.y) / 10)
        end
    end
    gPlayerSyncTable[0].height = character_height

    -- Update Run Time
    if _G.ou64_run_timer_start_time > 0 then
        gPlayerSyncTable[0].run_time = delta_to_msec(get_global_timer() - _G.ou64_run_timer_start_time)
    else
        gPlayerSyncTable[0].run_time = 0
    end

    -- Update Character Action
    gPlayerSyncTable[0].action = m.action

    -- Twirl Counter
    _G.ou64_moveset_twirl_counter = _G.ou64_moveset_twirl_counter + 1
    if _G.ou64_moveset_twirling
            and _G.ou64_moveset_twirl_counter >= _G.ou64_moveset_twirl_count then
        _G.ou64_moveset_twirling = false
        _G.ou64_moveset_twirl_counter = 0
        set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
    end

    -- Lock / Unlock Mario depending on Practice Menu State
    m.freeze = _G.ou64_practice_menu_open and 1 or 0

    -- Menu Selection
    check_menu_input(m)

    -- Server Metrics
    if network_is_server() and
            _G.ou64_metrics_export_metrics and
            _G.ou64_metrics_start_time == 0 then
        export_start_time()
    end
    if network_is_server() and
            _G.ou64_metrics_export_metrics and
            (get_global_timer() - _G.ou64_metrics_heartbeat_last_time) >= _G.ou64_metrics_heartbeat_interval_frames then
        export_heartbeat()
    end
    if network_is_server() and
            _G.ou64_metrics_export_metrics and 
            (get_global_timer() - _G.ou64_metrics_player_list_last_time) >= _G.ou64_metrics_player_list_interval_frames then
        export_player_list()
    end
end)

-- Character Height --
if not _G.ou64_flood_active then
    hook_chat_command('ou64-height', '- Toggles Character height on HUD and Player List', function()
        _G.ou64_show_character_height = not _G.ou64_show_character_height
        if _G.ou64_show_character_height then
            djui_popup_create("Only Up 64 Plugin: \n\\#00C7FF\\Y Position Enabled", 1)
        else
            djui_popup_create("Only Up 64 Plugin: \n\\#A02200\\Y Position Disabled", 1)
            for i = 0, MAX_PLAYERS - 1 do
                network_player_set_description(gNetworkPlayers[i], "", 255, 255, 255, 255)
            end
        end
        save_plugin_settings()
        return true
    end)
end

-- Height Meter --
hook_chat_command('ou64-meter', '- Toggles Height Meter', function()
    _G.ou64_show_height_meter = not _G.ou64_show_height_meter
    if _G.ou64_show_height_meter then
        djui_popup_create("Only Up 64 Plugin: \n\\#00C7FF\\Height Meter Enabled", 1)
    else
        djui_popup_create("Only Up 64 Plugin: \n\\#A02200\\Height Meter Disabled", 1)
    end
    save_plugin_settings()
    return true
end)

-- Only Up 64 Moveset --
hook_chat_command('ou64-moveset', '- Toggles \\#FAFF20\\Only Up 64\\#FFF\\ Moveset', function()
    _G.ou64_enable_moveset = not _G.ou64_enable_moveset
    if _G.ou64_enable_moveset then
        djui_popup_create("Only Up 64 Plugin: \n\\#00C7FF\\Moveset Enabled", 1)
    else
        djui_popup_create("Only Up 64 Plugin: \n\\#A02200\\Moveset Disabled", 1)
    end
    save_plugin_settings()
    return true
end)

-- Checkpoints --
if not _G.ou64_flood_active then
    if network_is_server() or network_is_moderator() then
        hook_chat_command('ou64-checkpoints', '- Toggles Checkpointing [Mod Only]', function()
            _G.ou64_enable_checkpoints = not _G.ou64_enable_checkpoints
            if _G.ou64_enable_checkpoints then
                djui_popup_create("Only Up 64 Plugin: \n\\#00C7FF\\Checkpoints Enabled", 1)
            else
                djui_popup_create("Only Up 64 Plugin: \n\\#A02200\\Checkpoints Disabled", 1)
            end
            return true 
        end)
    end
    hook_chat_command('c', '- Creates a checkpoint', checkpoint)
    hook_chat_command('tp', '- Teleports to last checkpoint', teleport)
end

-- Warp Menu for Practice --
function PracticeMenu()
    if not gGlobalSyncTable.ou64_enable_warps then return true end

    _G.ou64_practice_menu_open = true
    _G.ou64_practice_menu[1].text = "Last Warp" .. last_warp_string()
    play_sound(SOUND_MENU_PAUSE, gMarioStates[0].marioObj.header.gfx.cameraToObject)
    return true
end
if _G.ou64_active and not _G.ou64_flood_active then
    hook_chat_command("ou64-practice", "- Shows Warp Menu (Must be Enabled)", PracticeMenu)

    if network_is_server() or network_is_moderator() then
        hook_chat_command('ou64-warps', '- Toggles Warps [Mod Only]', function()
            gGlobalSyncTable.ou64_enable_warps = not gGlobalSyncTable.ou64_enable_warps
            if gGlobalSyncTable.ou64_enable_warps then
                djui_popup_create("Only Up 64 Plugin: \n\\#00C7FF\\Warps Enabled", 1)
                _G.ou64_run_timer_running = false
            else
                djui_popup_create("Only Up 64 Plugin: \n\\#A02200\\Warps Disabled", 1)
            end
            return true
        end)
    end
end

-- Run Timer
if not _G.ou64_flood_active then
    hook_chat_command('ou64-run-timer', '- Toggles Run Timer', function()
        _G.ou64_show_run_timer = not _G.ou64_show_run_timer
        if _G.ou64_show_run_timer then
            djui_popup_create("Only Up 64 Plugin: \n\\#00C7FF\\Run Timer Enabled", 1)
        else
            djui_popup_create("Only Up 64 Plugin: \n\\#A02200\\Run Timer Disabled", 1)
        end
        save_plugin_settings()
        return true
    end)
end

-- Leaderboard
if not _G.ou64_flood_active then
    hook_chat_command('ou64-leaderboard', '- Toggles Leaderboard', function()
        _G.ou64_show_leaderboard = not _G.ou64_show_leaderboard
        if _G.ou64_show_leaderboard then
            djui_popup_create("Only Up 64 Plugin: \n\\#00C7FF\\Leaderboard Enabled", 1)
        else
            djui_popup_create("Only Up 64 Plugin: \n\\#A02200\\Leaderboard Disabled", 1)
        end
        save_plugin_settings()
        return true
    end)
end

hook_chat_command('ou64-reset-settings', '- Restores Default Settings', function()
    reset_plugin_settings()
    save_plugin_settings()
    return true
end)

hook_event(HOOK_ON_PACKET_BYTESTRING_RECEIVE, function(bytestring)
    if bytestring ~= nil then
        local packet = ByteReader:new(bytestring)
        local packet_id = packet:u8()
        if packet_id == _G.ou64_packet_ids.send_run_data then
            -- Read Run Data Packet
            local timestamp_sec = packet:u32()
            local run_time_msec = packet:u32()
            local checkpoints_used = packet:u16()
            local player_model = packet:u8()
            local player_hair = packet:u32()
            local player_skin = packet:u32()
            local player_cap = packet:u32()
            local player_uuid = packet:string()
            local coopnet_id = packet:string()
            local player_name = packet:string()

            -- Announce Completed Run
            local is_player_best_time = is_best_time(player_uuid, run_time_msec)
            local announce_detail = is_player_best_time and "\n      \\#FAFF20\\A personal best!\\#FFFFFF\\" or ""
            djui_chat_message_create(
                string_format("\\#FAFF20\\%s \\#FFFFFF\\completed an \\#FAFF20\\Only Up 64\\#FFFFFF\\ run\n  %s  %s %s%s",
                    player_name,
                    format_msec(run_time_msec),
                    checkpoints_used,
                    checkpoints_used == 1 and "checkpoint" or "checkpoints",
                    announce_detail)
            )

            -- Add to Leaderboard
            add_to_leaderboard(
                timestamp_sec,
                run_time_msec,
                checkpoints_used,
                player_model,
                player_hair,
                player_skin,
                player_cap,
                player_uuid,
                coopnet_id,
                player_name
            )
        elseif packet_id == _G.ou64_packet_ids.get_leaderboard and
                network_is_server() then
            local return_player_index = packet:u8()
            local clear_packet = ByteWriter:new()
            clear_packet:u8(_G.ou64_packet_ids.clear_leaderboard)
            network_send_bytestring_to(
                return_player_index,
                true,
                clear_packet:serialize()
            )
            local rtn_packet = ByteWriter:new()
            if _G.ou64_leaderboard ~= nil and
                    #_G.ou64_leaderboard > 0 then
                for i, entry in ipairs(_G.ou64_leaderboard) do
                    if rtn_packet:is_empty() then
                        rtn_packet:u8(_G.ou64_packet_ids.return_leaderboard)
                    end
                    rtn_packet:u32(entry.run_id)
                    rtn_packet:u32(entry.timestamp_sec)
                    rtn_packet:u32(entry.run_time_msec)
                    rtn_packet:u16(entry.checkpoints_used)
                    rtn_packet:u8(entry.player_model)
                    rtn_packet:u32(entry.player_hair)
                    rtn_packet:u32(entry.player_skin)
                    rtn_packet:u32(entry.player_cap)
                    rtn_packet:string(entry.player_uuid)
                    rtn_packet:string(entry.coopnet_id)
                    rtn_packet:string(entry.player_name)
                    if (i % _G.ou64_leaderboard_entries_per_packet) == 0 then
                        network_send_bytestring_to(
                            return_player_index,
                            true,
                            rtn_packet:serialize()
                        )
                        rtn_packet = ByteWriter:new()
                    end
                end
                if not rtn_packet:is_empty() then
                    network_send_bytestring_to(
                        return_player_index,
                        true,
                        rtn_packet:serialize()
                    )
                end
            end
        elseif packet_id == _G.ou64_packet_ids.clear_leaderboard then
            clear_leaderboard()
        elseif packet_id == _G.ou64_packet_ids.return_leaderboard then
            _G.ou64_leaderboard_requesting = false
            while not packet:at_end() do
                local run_id = packet:u32()
                local timestamp_sec = packet:u32()
                local run_time_msec = packet:u32()
                local checkpoints_used = packet:u16()
                local player_model = packet:u8()
                local player_hair = packet:u32()
                local player_skin = packet:u32()
                local player_cap = packet:u32()
                local player_uuid = packet:string()
                local coopnet_id = packet:string()
                local player_name = packet:string()
                table.insert(
                    _G.ou64_leaderboard,
                    {
                        run_id = run_id,
                        timestamp_sec = timestamp_sec,
                        run_time_msec = run_time_msec,
                        checkpoints_used = checkpoints_used,
                        player_model = player_model,
                        player_hair = player_hair,
                        player_skin = player_skin,
                        player_cap = player_cap,
                        player_uuid = player_uuid,
                        coopnet_id = coopnet_id,
                        player_name = player_name
                    }
                )
            end
        end
    end
end)

hook_event(HOOK_ON_WARP, function()
    _G.ou64_run_timer_on_start = false
    reset_timer()
    reset_checkpoints()
    _G.ou64_warped = true
end)

hook_event(HOOK_ON_PLAYER_CONNECTED, function()
    if network_is_server() then
        -- Server Metrics
        export_player_count(network_player_connected_count())
    end
end)

hook_event(HOOK_ON_PLAYER_DISCONNECTED, function()
    if network_is_server() then
        -- Server Metrics
        export_player_count(network_player_connected_count())
    end
end)

-- Mario Action Hooks
---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
hook_mario_action(ACT_KAZE_AIR_HIT_WALL, { every_frame = act_kaze_air_hit_wall })
---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
hook_mario_action(ACT_KAZE_DIVE_SLIDE, { every_frame = act_kaze_dive_slide })
---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
hook_mario_action(ACT_WALL_SLIDE, { every_frame = act_wall_slide, gravity = act_wall_slide_gravity })
