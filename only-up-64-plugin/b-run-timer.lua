-- Localize for performance.
local math_floor,math_max,math_min,string_format =
      math.floor,math.max,math.min,string.format

local ByteWriter = require('a-bytewriter')

function reset_timer()
    ou64_run_timer_running = false
    ou64_run_timer_start_time = 0
    gPlayerSyncTable[0].run_time = 0
end

-- Mario Update Hook.
--- @param m MarioState
hook_event(HOOK_MARIO_UPDATE, function(m)
    if m.playerIndex ~= 0 then
        return
    end

    -- Only Up 64 Run Timer Triggers
    if not ou64_flood_active then
        if standing_on_start_timer(m) then
            -- Standing on Timer (Reset Run)
            ou64_run_timer_on_start = true
            reset_timer()
            reset_checkpoints()
            ou64_warped = false
            gPlayerSyncTable[0].checkpoint_count = 0
        elseif not standing_on_start_timer(m) and
                ou64_run_timer_on_start and
                not ou64_warped then
            -- Just Left Start (Start Run)
            ou64_run_timer_on_start = false
            ou64_run_timer_running = true
            ou64_run_timer_start_time = get_global_timer()
            gPlayerSyncTable[0].run_time = get_global_timer() - ou64_run_timer_start_time
            reset_checkpoints()
            djui_chat_message_create("Run Started... GO!")
            play_sound(SOUND_GENERAL_RACE_GUN_SHOT, m.marioObj.header.gfx.cameraToObject)
        elseif standing_on_end_timer(m) and
                ou64_run_timer_running then
            -- Standing on Top (Stop Timer, End Run)
            ou64_run_timer_running = false
            -- Create Packet and Send to Everyone
            local timestamp_sec = get_time()
            local time_elapsed = get_global_timer() - ou64_run_timer_start_time
            local run_time_msec = delta_to_msec(time_elapsed)
            local checkpoints_used = ou64_checkpoint_count
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
            local packet = ByteWriter:new()
            packet:u8(ou64_packet_ids.send_run_data)
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
            -- Add to Leaderboard and Announce Run
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
        -- Standing on Top (Warp to End Level)
        if standing_on_end_timer(m) then
            warp_to_level(_G.ou64_end_level_id, 1, _G.ou64_act_id)
        end
    end

    -- Flood Runs
    if ou64_flood_active and
            ou64_flood_finish_time_msec ~= nil then
        -- Create Packet and Send to Everyone
        local timestamp_sec = get_time()
        local run_time_msec = math.floor(ou64_flood_finish_time_msec)
        local flood_area = _G.ou64_flood_area
        local flood_speed = ou64_flood_speed
        local flood_hardmode = ou64_flood_hardmode and 1 or 0

        ou64_flood_finish_time_msec = nil

        local player_model = gMarioStates[0].character.type
        local hair_part = player_model ~= 2 and HAIR or GLOVES
        local player_hair = pack_color_int(network_player_get_override_palette_color(gNetworkPlayers[0], hair_part))
        local player_skin = pack_color_int(network_player_get_override_palette_color(gNetworkPlayers[0], SKIN))
        local player_cap = pack_color_int(network_player_get_override_palette_color(gNetworkPlayers[0], CAP))
        local player_uuid = get_ou64_id()
        local coopnet_id = get_coopnet_id(gNetworkPlayers[0].localIndex)
        local player_name = gNetworkPlayers[0].name
        local is_player_best_time = is_best_flood_time(flood_area, flood_hardmode, player_uuid, run_time_msec)
        local announce_detail = is_player_best_time and "\n      \\#FAFF20\\A personal best!\\#FFFFFF\\" or ""
        local packet = ByteWriter:new()
        packet:u8(ou64_packet_ids.send_flood_run_data)
        packet:u32(timestamp_sec)
        packet:u32(run_time_msec)
        packet:u8(player_model)
        packet:u32(player_hair)
        packet:u32(player_skin)
        packet:u32(player_cap)
        packet:u8(flood_area)
        packet:u8(flood_hardmode)
        packet:f32(flood_speed)
        packet:string(player_uuid)
        packet:string(coopnet_id)
        packet:string(player_name)
        network_send_bytestring(
            true,
            packet:serialize()
        )
        if not ou64_settings.enable_arcade_mode then
            add_to_flood_leaderboard(
                timestamp_sec,
                run_time_msec,
                player_model,
                player_hair,
                player_skin,
                player_cap,
                flood_area,
                flood_hardmode,
                flood_speed,
                player_uuid,
                coopnet_id,
                player_name)
        end
        djui_chat_message_create(
            string_format("\\#FAFF20\\%s \\#FFFFFF\\escaped \\#FAFF20\\Area %s\\#FFFFFF\\ in %s%s",
                player_name,
                flood_area,
                format_msec(run_time_msec),
                announce_detail)
        )
    end
end)

-- Render Run Timer
hook_event(HOOK_ON_HUD_RENDER, function()
    m = gMarioStates[0]

    -- If in cutscene or Act Selector, don't render anything
    if not ou64_active or
            ou64_flood_active or
            not ou64_settings.show_run_timer or
            m.action == ACT_END_PEACH_CUTSCENE or
            m.action == ACT_CREDITS_CUTSCENE or
            m.action == ACT_END_WAVING_CUTSCENE or
            obj_get_first_with_behavior_id(id_bhvActSelector) ~= nil then return end

    -- Run Timer Parameters
    djui_hud_set_resolution(RESOLUTION_DJUI)

    local anchor_x = 10
    local leaderboard_visible = ou64_leaderboard ~= nil and #ou64_leaderboard > 0 and ou64_settings.show_leaderboard
    local anchor_y = leaderboard_visible and 258 or 24
    local top_height = ou64_top_height

    -- Gather Players
    local players_running = {}
    for i = 1, MAX_PLAYERS - 1 do
        if gNetworkPlayers[i].connected then
            local run_time = gPlayerSyncTable[i].run_time ~= nil and gPlayerSyncTable[i].run_time or 0
            local height = gPlayerSyncTable[i].height ~= nil and gPlayerSyncTable[i].height or 0
            local checkpoints = gPlayerSyncTable[i].checkpoint_count ~= nil and gPlayerSyncTable[i].checkpoint_count or 0
            if run_time > 0 then
                table.insert(players_running, {
                    idx = i,
                    name = gNetworkPlayers[i].name,
                    height = height,
                    run_time = run_time,
                    run_time_str = format_msec(run_time),
                    checkpoints = checkpoints,
                })
            end
        end
    end
    table.sort(players_running, function(p1, p2)
        if p1.height == p2.height then
            return p1.checkpoints < p2.checkpoints
        else
            return p1.height > p2.height
        end
    end)

    -- Background Box
    local player_count = players_running ~= nil and #players_running or 0
    local timer_height = 32 * player_count + 80
    djui_hud_set_adjusted_color(0, 0, 0, 128)
    djui_hud_render_rect(anchor_x, anchor_y, 450, timer_height)

    -- Current Run Title
    djui_hud_set_font(FONT_MENU)
    djui_hud_set_adjusted_color(1, 147, 105, 255)
    djui_hud_print_text("Current Runs", anchor_x - 8, anchor_y - 24, ou64_run_timer_scale / 1.5)

    -- Run Timer / Checkpoint Count
    djui_hud_set_adjusted_color(255, 255, 255, 255)
    djui_hud_set_font(FONT_ALIASED)
    djui_hud_print_text("Time", anchor_x + 316, anchor_y + 6, ou64_run_timer_scale)
    djui_hud_render_texture(checkpoint_flag, anchor_x + 419, anchor_y + 16, 1.0, 1.0)

    local time_string = "00:00.00"
    local checkpoints_used = "0"
    if ou64_run_timer_running then
        local time_elapsed = get_global_timer() - ou64_run_timer_start_time
        time_string = format_time(time_elapsed)
        checkpoints_used = string_format("%s", ou64_checkpoint_count)
    end
    djui_hud_set_adjusted_color(255, 255, 255, 255)
    local player_name = gNetworkPlayers[0].name
    local name_length = djui_hud_measure_text(string_without_hex(player_name))

    if player_name == string_without_hex(player_name) then
        local cap_color = network_player_get_override_palette_color(gNetworkPlayers[0], CAP)
        local cap_r = 127 + cap_color.r // 2
        local cap_g = 127 + cap_color.g // 2
        local cap_b = 127 + cap_color.b // 2
        player_name = "\\#" .. string_format("%02x", cap_r) .. string_format("%02x", cap_g) .. string_format("%02x", cap_b) .. "\\" .. player_name
    end
    local icon_pad = 42
    local head_x_pad = 18
    local head_y_pad = 1
    local y_pad = 38
    render_player_head(0,
        anchor_x + icon_pad + head_x_pad,
        anchor_y + y_pad + head_y_pad,
        1.8, 
        1.8
    )

    local height = gPlayerSyncTable[0].height ~= nil and gPlayerSyncTable[0].height or 0
    local percent_done = height / top_height * 100.0
    percent_done = math_max(percent_done, 0)
    local percent_done_str = string.format("%.0f", math_min(percent_done, 100)) .. "%"
    djui_hud_print_text(percent_done_str, anchor_x - (djui_hud_measure_text(percent_done_str) / 2) + 30, anchor_y + 41, ou64_leaderboard_scale * 0.8)
    djui_hud_print_colored_text(player_name, anchor_x - (name_length / 2) + 182, anchor_y + 40, ou64_leaderboard_scale, 16)
    djui_hud_print_text(string_format("%s", time_string), anchor_x - djui_hud_measure_text(time_string) / 2 + 330, anchor_y + 40, ou64_run_timer_scale)
    djui_hud_print_text(string_format("%s", checkpoints_used), anchor_x - djui_hud_measure_text(checkpoints_used) / 2 + 424, anchor_y + 40, ou64_run_timer_scale)

    local y_offset = 32
    for i, entry in ipairs(players_running) do
        local name_length = djui_hud_measure_text(string_without_hex(entry.name))
        local run_time_length = djui_hud_measure_text(entry.run_time_str)
        local checkpoints = tostring(entry.checkpoints)
        local checkpoint_length = djui_hud_measure_text(checkpoints)
        local entry_name = entry.name
        if entry_name == string_without_hex(entry.name) then
            local cap_color = network_player_get_override_palette_color(gNetworkPlayers[entry.idx], CAP)
            local cap_r = 127 + cap_color.r // 2
            local cap_g = 127 + cap_color.g // 2
            local cap_b = 127 + cap_color.b // 2
            entry_name = "\\#" .. string_format("%02x", cap_r) .. string_format("%02x", cap_g) .. string_format("%02x", cap_b) .. "\\" .. entry_name
        end
        local player_percent_done = entry.height / top_height * 100.0
        player_percent_done = math_max(player_percent_done, 0)
        local player_percent_done_str = string.format("%.0f", math_min(player_percent_done, 100)) .. "%"
        djui_hud_print_text(player_percent_done_str, anchor_x - (djui_hud_measure_text(player_percent_done_str) / 2) + 30, anchor_y + 41 + y_offset, ou64_leaderboard_scale * 0.8)
        render_player_head(entry.idx,
            anchor_x + icon_pad + head_x_pad,
            anchor_y + y_pad + head_y_pad + y_offset,
            1.8,
            1.8
        )
        djui_hud_print_colored_text(entry_name, anchor_x - (name_length / 2) + 182, anchor_y + 40 + y_offset, ou64_leaderboard_scale, 16)
        djui_hud_print_text(entry.run_time_str, anchor_x - (run_time_length / 2) + 330, anchor_y + 40 + y_offset, ou64_leaderboard_scale)
        djui_hud_print_text(checkpoints, anchor_x - (checkpoint_length / 2) + 424, anchor_y + 40 + y_offset, ou64_leaderboard_scale)
        y_offset = y_offset + 32
    end
end)

-- Update Hook --
hook_event(HOOK_UPDATE, function()
    local m = gMarioStates[0]

    -- Sync Mario Action
    gPlayerSyncTable[0].action = m.action

    -- Sync Run Time
    if ou64_run_timer_start_time > 0 then
        gPlayerSyncTable[0].run_time = delta_to_msec(get_global_timer() - ou64_run_timer_start_time)
    else
        gPlayerSyncTable[0].run_time = 0
    end

    -- Sync Character Height
    local character_height = math_floor(m.pos.y)
    if ou64_active then
        if gNetworkPlayers[0].currLevelNum == _G.ou64_end_level_id then
            character_height = ou64_top_height
        else
            local area_index = m.area.index - 1
            if area_index < 0 then
                area_index = 7
            end
            character_height = math_floor((ou64_map_pad + (32000 * area_index) + m.pos.y) / 10)
        end
    end
    gPlayerSyncTable[0].height = character_height
end)