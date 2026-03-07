-- Localize for performance.
local math_floor,math_min,string_format,string_sub =
      math.floor,math.min,string.format,string.sub

local ByteReader = require('a-bytereader')
local ByteWriter = require('a-bytewriter')

-- Textures
local d_pad_left_and_right = get_texture_info("d_pad_left_and_right")

local function bind_next_page(m)
    return (m.controller.buttonPressed & R_JPAD) ~= 0
end

local function bind_prev_page(m)
    return (m.controller.buttonPressed & L_JPAD) ~= 0
end

-- Renders the Only Up 64 Leaderboard
function render_leaderboard()
    if ou64_leaderboard == nil and
            not ou64_leaderboard_requesting then
        request_leaderboard()
    elseif ou64_leaderboard ~= nil and
            #ou64_leaderboard > 0 then
        -- Leaderboard Parameters
        djui_hud_set_resolution(RESOLUTION_DJUI)
        local entry_count = math_min(#ou64_leaderboard , ou64_leaderboard_entries_per_page)
        local lb_x = 10
        local lb_y = 24
        local lb_scale = 1.0
        local entry_height = 32
        local leaderboard_pad = 46
        local leaderboard_width = 450
        local leaderboard_height = (entry_height * entry_count) + leaderboard_pad

        -- Render Background
        djui_hud_set_adjusted_color(0, 0, 0, 128)
        djui_hud_render_rect(lb_x, lb_y, leaderboard_width, leaderboard_height)

        -- Leaderboard Title
        djui_hud_set_resolution(RESOLUTION_DJUI)
        djui_hud_set_font(FONT_MENU)
        djui_hud_set_adjusted_color(1, 147, 105, 255)
        djui_hud_print_text("Leaderboard", lb_x - 8, lb_y - 24, ou64_run_timer_scale / 1.5)

        -- Render D-PAD Texture
        djui_hud_set_adjusted_color(255, 255, 255, 255)
        djui_hud_set_resolution(RESOLUTION_N64)
        djui_hud_render_texture(d_pad_left_and_right, lb_x + 85, lb_y - 22, 0.075, 0.075)

        -- Render Leaderboard Titles
        djui_hud_set_resolution(RESOLUTION_DJUI)
        djui_hud_set_font(FONT_ALIASED)
        djui_hud_set_adjusted_color(255, 255, 255, 255)

        djui_hud_print_text("Time", lb_x + 316, lb_y + 6, ou64_run_timer_scale)
        djui_hud_render_texture(checkpoint_flag, lb_x + 419, lb_y + 16, 1.0, 1.0)
        local entries_added = 0
        local y_offset = 0
        local y_pad = 24
        local place_index = math_floor((ou64_leaderboard_page * ou64_leaderboard_entries_per_page) + 1)
        local entries_to_skip = place_index - 1
        local leaderboard_index = 1
        local uuids = {} 
        while leaderboard_index <= #ou64_leaderboard and
                entries_added < ou64_leaderboard_entries_per_page do
            if entries_to_skip == 0 then
                local entry_name = string_without_hex(ou64_leaderboard[leaderboard_index].player_name)
                local entry_uuid = ou64_leaderboard[leaderboard_index].player_uuid
                if uuids[entry_uuid] == nil then
                    uuids[entry_uuid] = true
                    entries_added = entries_added + 1
                    local place_str = tostring(place_index)
                    local place_length = djui_hud_measure_text(place_str)
                    local player_name_length = djui_hud_measure_text(entry_name)
                    if #entry_name > 16 then
                        player_name_length = djui_hud_measure_text(string_sub(entry_name, 0, 16))
                    end
                    local run_time_msec = format_msec(ou64_leaderboard[leaderboard_index].run_time_msec)
                    local run_time_length = djui_hud_measure_text(run_time_msec)
                    local checkpoints_used = tostring(ou64_leaderboard[leaderboard_index].checkpoints_used)
                    local checkpoint_length = djui_hud_measure_text(checkpoints_used)
                    local place_pad = 30
                    djui_hud_print_text(place_str, lb_x - (place_length / 2) + place_pad, 40 + lb_y + y_offset, ou64_leaderboard_scale)
                    local player_name = ou64_leaderboard[leaderboard_index].player_name
                    if entry_name == ou64_leaderboard[leaderboard_index].player_name then
                        local cap_color = unpack_color_int(ou64_leaderboard[leaderboard_index].player_cap)
                        local cap_r = 127 + cap_color.r // 2
                        local cap_g = 127 + cap_color.g // 2
                        local cap_b = 127 + cap_color.b // 2
                        player_name = "\\#" .. string_format("%02x", cap_r) .. string_format("%02x", cap_g) .. string_format("%02x", cap_b) .. "\\" .. player_name
                    end
                    local icon_pad = 42
                    local head_x_pad = 18
                    local head_y_pad = 16
                    render_player_head_from_parts(
                        ou64_leaderboard[leaderboard_index].player_model,
                        ou64_leaderboard[leaderboard_index].player_hair,
                        ou64_leaderboard[leaderboard_index].player_skin,
                        ou64_leaderboard[leaderboard_index].player_cap,
                        lb_x + icon_pad + head_x_pad,
                        lb_y + y_pad + head_y_pad + y_offset,
                        1.8, 
                        1.8
                    )
                    local name_pad = 182
                    djui_hud_print_colored_text(player_name, lb_x - (player_name_length / 2) + name_pad, 40 + lb_y + y_offset, ou64_leaderboard_scale, 16)
                    local time_pad = 330
                    djui_hud_print_text(run_time_msec, lb_x - (run_time_length / 2) + time_pad, 40 + lb_y + y_offset, ou64_leaderboard_scale)
                    local checkpoint_pad = 424
                    djui_hud_print_text(string_format("%s", checkpoints_used), lb_x - (checkpoint_length / 2) + checkpoint_pad, 40 + lb_y + y_offset, ou64_leaderboard_scale)
                    y_offset = y_offset + 32
                    place_index = place_index + 1
                end
            else
                entries_to_skip = entries_to_skip - 1
            end
            leaderboard_index = leaderboard_index + 1
        end
    end
end

-- Renders Only Up Flood Leaderboard
function render_flood_leaderboard()
    if ou64_flood_leaderboard == nil and
            not ou64_flood_leaderboard_requesting then
        request_flood_leaderboard()
    elseif ou64_flood_leaderboard ~= nil and
            ou64_flood_leaderboard[_G.ou64_flood_area] ~= nil and
            #ou64_flood_leaderboard[_G.ou64_flood_area] > 0 then
        djui_hud_set_resolution(RESOLUTION_DJUI)

        local anchor_x = 24
        local flood_scoreboard_height = _G.ou64_flood_scoreboard_height ~= nil and _G.ou64_flood_scoreboard_height + 24 or 0
        local anchor_y = flood_scoreboard_height + 24

        -- Background Box
        local leaderboard_height = 32 * ou64_flood_leaderboard_entries_per_page + 46
        djui_hud_set_adjusted_color(0, 0, 0, 128)
        djui_hud_render_rect(anchor_x, anchor_y, 450, leaderboard_height)

        -- Leaderboard Title
        djui_hud_set_font(FONT_MENU)
        djui_hud_set_adjusted_color(250, 255, 32, 255)
        djui_hud_print_text("Leaderboard", anchor_x - 8, anchor_y - 24, ou64_run_timer_scale / 1.5)
        local area_index = _G.ou64_flood_area ~= 0 and _G.ou64_flood_area or 8
        local area = string_format("Area %d", area_index)
        local area_length = djui_hud_measure_text(area) / 1.5
        djui_hud_print_text(area, anchor_x + 450 - area_length - 8, anchor_y - 24, ou64_run_timer_scale / 1.5)

        djui_hud_set_font(FONT_ALIASED)
        djui_hud_set_adjusted_color(255, 255, 255, 255)

        local entries_added = 0 
        local y_offset = 0
        local y_pad = 24
        local place_index = 1
        local leaderboard_index = 1
        local uuids = {} 
        while leaderboard_index <= #ou64_flood_leaderboard[_G.ou64_flood_area] and
                entries_added < ou64_flood_leaderboard_entries_per_page do
            local entry_name = string_without_hex(ou64_flood_leaderboard[_G.ou64_flood_area][leaderboard_index].player_name)
            local entry_uuid = ou64_flood_leaderboard[_G.ou64_flood_area][leaderboard_index].player_uuid
            if uuids[entry_uuid] == nil then
                uuids[entry_uuid] = true
                entries_added = entries_added + 1
                local place_str = tostring(place_index)
                local place_length = djui_hud_measure_text(place_str)
                local player_name_length = djui_hud_measure_text(entry_name)
                local run_time_msec = format_msec(ou64_flood_leaderboard[_G.ou64_flood_area][leaderboard_index].run_time_msec)
                local run_time_length = djui_hud_measure_text(run_time_msec)
                djui_hud_print_text(place_str, 24 + anchor_x - (place_length / 2), y_pad + anchor_y + y_offset, ou64_flood_leaderboard_scale)
                local player_name = ou64_flood_leaderboard[_G.ou64_flood_area][leaderboard_index].player_name
                if entry_name == ou64_flood_leaderboard[_G.ou64_flood_area][leaderboard_index].player_name then
                    local cap_color = unpack_color_int(ou64_flood_leaderboard[_G.ou64_flood_area][leaderboard_index].player_cap)
                    local cap_r = 127 + cap_color.r // 2
                    local cap_g = 127 + cap_color.g // 2
                    local cap_b = 127 + cap_color.b // 2
                    player_name = "\\#" .. string_format("%02x", cap_r) .. string_format("%02x", cap_g) .. string_format("%02x", cap_b) .. "\\" .. player_name
                end
                local icon_pad = 32
                local head_x_pad = 18
                local head_y_pad = 1
                render_player_head_from_parts(
                    ou64_flood_leaderboard[_G.ou64_flood_area][leaderboard_index].player_model,
                    ou64_flood_leaderboard[_G.ou64_flood_area][leaderboard_index].player_hair,
                    ou64_flood_leaderboard[_G.ou64_flood_area][leaderboard_index].player_skin,
                    ou64_flood_leaderboard[_G.ou64_flood_area][leaderboard_index].player_cap,
                    anchor_x + icon_pad + head_x_pad,
                    anchor_y + y_pad + head_y_pad + y_offset,
                    1.8, 
                    1.8
                )
                djui_hud_print_colored_text(player_name, 160 + anchor_x - (player_name_length / 2), y_pad + anchor_y + y_offset, ou64_flood_leaderboard_scale, 16)
                djui_hud_print_text(run_time_msec, 376 + anchor_x - (run_time_length / 2), y_pad + anchor_y + y_offset, ou64_flood_leaderboard_scale)
                y_offset = y_offset + 32
                place_index = place_index + 1
            end
            leaderboard_index = leaderboard_index + 1
        end
    end
end

-- Render Leaderboard (Only Up 64 or Only Up Flood)
hook_event(HOOK_ON_HUD_RENDER, function()
    local m = gMarioStates[0]
    if not ou64_active or
            not ou64_settings.show_leaderboard or
            m.action == ACT_END_PEACH_CUTSCENE or
            m.action == ACT_CREDITS_CUTSCENE or
            m.action == ACT_END_WAVING_CUTSCENE or
            obj_get_first_with_behavior_id(id_bhvActSelector) ~= nil then
        return
    end

    if not ou64_flood_active then
        render_leaderboard()
    else
        render_flood_leaderboard()
    end
end)

-- Mario Update Hook.
--- @param m MarioState
hook_event(HOOK_MARIO_UPDATE, function(m)
    if m.playerIndex ~= 0 then
        return
    end

    if ou64_leaderboard ~= nil and
            #ou64_leaderboard > ou64_leaderboard_entries_per_page then
        local max_pages = math_floor(#ou64_leaderboard / ou64_leaderboard_entries_per_page)
        if bind_next_page(m) then
            local next_page = ou64_leaderboard_page + 1
            if next_page > max_pages then
                next_page = 0
            end
            ou64_leaderboard_page = next_page
        elseif bind_prev_page(m) then
            local next_page = ou64_leaderboard_page - 1
            if next_page < 0 then
                next_page = max_pages
            end
            ou64_leaderboard_page = next_page
        end
    end
end)

-- Packet Bytestring Receive Hook.
--- @param bytestring table
hook_event(HOOK_ON_PACKET_BYTESTRING_RECEIVE, function(bytestring)
    if bytestring ~= nil then
        local packet = ByteReader:new(bytestring)
        local packet_id = packet:u8()
        if packet_id == ou64_packet_ids.send_run_data then
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
        elseif packet_id == ou64_packet_ids.send_flood_run_data then
            -- Read Run Data Packet
            local timestamp_sec = packet:u32()
            local run_time_msec = packet:u32()
            local player_model = packet:u8()
            local player_hair = packet:u32()
            local player_skin = packet:u32()
            local player_cap = packet:u32()
            local flood_area = packet:u8()
            local flood_hardmode = packet:u8()
            local flood_speed = packet:f32()
            local player_uuid = packet:string()
            local coopnet_id = packet:string()
            local player_name = packet:string()

            -- Announce Completed Run
            local is_player_best_time = is_best_flood_time(flood_area, flood_hardmode, player_uuid, run_time_msec)
            local announce_detail = is_player_best_time and "\n      \\#FAFF20\\A personal best!\\#FFFFFF\\" or ""
            djui_chat_message_create(
                string_format("\\#FAFF20\\%s \\#FFFFFF\\escaped \\#FAFF20\\Area %s\\#FFFFFF\\ in %s%s",
                    player_name,
                    flood_area,
                    format_msec(run_time_msec),
                    announce_detail)
            )

            -- Add to Leaderboard
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
                    player_name
                )
            end
        elseif packet_id == ou64_packet_ids.get_leaderboard and
                network_is_server() then
            local return_player_index = packet:u8()
            local clear_packet = ByteWriter:new()
            clear_packet:u8(ou64_packet_ids.clear_leaderboard)
            network_send_bytestring_to(
                return_player_index,
                true,
                clear_packet:serialize()
            )
            local rtn_packet = ByteWriter:new()
            if ou64_leaderboard ~= nil and
                    #ou64_leaderboard > 0 then
                for i, entry in ipairs(ou64_leaderboard) do
                    if rtn_packet:is_empty() then
                        rtn_packet:u8(ou64_packet_ids.return_leaderboard)
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
                    if (i % ou64_leaderboard_entries_per_packet) == 0 then
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
        elseif packet_id == ou64_packet_ids.get_flood_leaderboard and
                network_is_server() then
            local return_player_index = packet:u8()
            local clear_packet = ByteWriter:new()
            clear_packet:u8(ou64_packet_ids.clear_flood_leaderboard)
            network_send_bytestring_to(
                return_player_index,
                true,
                clear_packet:serialize()
            )
            if ou64_flood_leaderboard ~= nil then
                for i, area in ipairs({1, 2, 3, 4, 5, 6, 7, 0}) do
                    local rtn_packet = ByteWriter:new()
                    if ou64_flood_leaderboard[area] ~= nil and
                            #ou64_flood_leaderboard[area] > 0 then
                        for j, entry in ipairs(ou64_flood_leaderboard[area]) do
                            if rtn_packet:is_empty() then
                                rtn_packet:u8(ou64_packet_ids.return_flood_leaderboard)
                            end
                            rtn_packet:u32(entry.run_id)
                            rtn_packet:u32(entry.timestamp_sec)
                            rtn_packet:u32(entry.run_time_msec)
                            rtn_packet:u8(entry.player_model)
                            rtn_packet:u32(entry.player_hair)
                            rtn_packet:u32(entry.player_skin)
                            rtn_packet:u32(entry.player_cap)
                            rtn_packet:u8(entry.flood_area)
                            rtn_packet:u8(entry.flood_hardmode)
                            rtn_packet:f32(entry.flood_speed)
                            rtn_packet:string(entry.player_uuid)
                            rtn_packet:string(entry.coopnet_id)
                            rtn_packet:string(entry.player_name)
                            if (j % ou64_flood_leaderboard_entries_per_packet) == 0 then
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
                end
            end
        elseif packet_id == ou64_packet_ids.clear_leaderboard then
            clear_leaderboard()
        elseif packet_id ==  ou64_packet_ids.clear_flood_leaderboard then
            clear_flood_leaderboard()
        elseif packet_id == ou64_packet_ids.return_leaderboard then
            ou64_leaderboard_requesting = false
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
                    ou64_leaderboard,
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
        elseif packet_id == ou64_packet_ids.return_flood_leaderboard then
            ou64_flood_leaderboard_requesting = false
            while not packet:at_end() do
                local run_id = packet:u32()
                local timestamp_sec = packet:u32()
                local run_time_msec = packet:u32()
                local player_model = packet:u8()
                local player_hair = packet:u32()
                local player_skin = packet:u32()
                local player_cap = packet:u32()
                local flood_area = packet:u8()
                local flood_hardmode = packet:u8()
                local flood_speed = packet:f32()
                local player_uuid = packet:string()
                local coopnet_id = packet:string()
                local player_name = packet:string()
                table.insert(
                    ou64_flood_leaderboard[flood_area],
                    {
                        run_id = run_id,
                        timestamp_sec = timestamp_sec,
                        run_time_msec = run_time_msec,
                        player_model = player_model,
                        player_hair = player_hair,
                        player_skin = player_skin,
                        player_cap = player_cap,
                        flood_area = flood_area,
                        flood_hardmode = flood_hardmode,
                        flood_speed = flood_speed,
                        player_uuid = player_uuid,
                        coopnet_id = coopnet_id,
                        player_name = player_name
                    }
                )
            end
        end
    end
end)