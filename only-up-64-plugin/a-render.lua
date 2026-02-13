local math_abs,math_max,math_min,string_format,string_match,string_sub = math.abs,math.max,math.min,string.format,string.match,string.sub

local height_meter = get_texture_info("height-meter")
local checkpoint_flag = get_texture_info("checkpoint-flag")

function djui_hud_print_colored_text(string, x, y, scale, limit)
    local total_space = 0

    local escaping = false
    local char_idx = 1
    local characters_rendered = 0
    while char_idx <= #string do
        local c = string_sub(string, char_idx, char_idx)
        if c == "\\" then
            if not escaping then
                local char_pointer = char_idx + 1
                while char_pointer < #string and
                        string_sub(string, char_pointer, char_pointer) ~= "\\" do
                    char_pointer = char_pointer + 1
                end
                local substring = string_sub(string, char_idx + 1, char_pointer - 1)
                local hex_match = (string_match(substring, "^#?%x%x%x$") or string_match(substring, "^#?%x%x%x%x%x%x$"))
                if hex_match ~= nil then
                    local r = #hex_match == 7 and string_sub(hex_match, 2, 3) or string_sub(hex_match, 2, 2)
                    local g = #hex_match == 7 and string_sub(hex_match, 4, 5) or string_sub(hex_match, 3, 3)
                    local b = #hex_match == 7 and string_sub(hex_match, 6, 7) or string_sub(hex_match, 4, 4)
                    if #r == 1 then
                        r = r .. r
                        g = g .. g
                        b = b .. b
                    end
                    djui_hud_set_color(
                        tonumber(r, 16),
                        tonumber(g, 16),
                        tonumber(b, 16),
                        255
                    )
                else
                    escaping = true
                end
                char_idx = char_pointer + 1
            elseif escaping then
                escaping = false
            end
        else
            djui_hud_print_text(c, (x + total_space) * scale, y, scale)
            total_space = total_space + djui_hud_measure_text(c)
            characters_rendered = characters_rendered + 1
            if limit ~= nil and characters_rendered >= limit then
                djui_hud_print_text("...", (x + total_space) * scale, y, scale)
                djui_hud_set_color(255, 255, 255, 255)
                return
            end
        char_idx = char_idx + 1
        end
    end

    djui_hud_set_color(255, 255, 255, 255)
end

function render_character_height()
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_HUD)

    local character_height = gPlayerSyncTable[0].height
    if character_height == nil then return end

    local screen_height = djui_hud_get_screen_height()
    local screen_width = djui_hud_get_screen_width()

    -- Update Player List Descriptions with Player Heights
    if _G.ou64_show_character_height and
            not _G.ou64_flood_active then
        for i = 0, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].currLevelNum == _G.ou64_level_id then
                network_player_set_description(gNetworkPlayers[i], "Y: " .. tostring(gPlayerSyncTable[i].height), 255, 255, 255, 255)
            else
                network_player_set_description(gNetworkPlayers[i], "", 255, 255, 255, 255)
            end
        end
    end

    if not _G.ou64_active or
            gNetworkPlayers[0].currLevelNum == _G.ou64_level_id then
        -- Render Character Height (Y Value) 
        negative_height = character_height < 0 and true or false
        if negative_height then
            character_height = math_abs(character_height)
        end
        dist_num = tonumber(string_format('%.0f', character_height))
        text_length = djui_hud_measure_text(tostring(dist_num))

        local x_value = _G.ou64_active and 30 or 50
        local y_value = _G.ou64_active and 4 or (screen_height - 58)
        djui_hud_print_text(
            string_format("Y %.0f", character_height),
            (screen_width - x_value - text_length),
            y_value,
            _G.ou64_character_height_scale
        )
        if negative_height then
            djui_hud_set_color(246, 190, 0, 255)
            djui_hud_render_texture(
                get_texture_info("minus"),
                (screen_width - x_value - text_length + _G.ou64_character_height_x_pad_negative),
                (y_value + _G.ou64_character_height_y_pad_negative),
                (_G.ou64_character_height_scale * 1.3), (_G.ou64_character_height_scale * 1.3)
            )
        end
    end
end

function render_checkpoint_tip()
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_ALIASED)

    local tip_text = checkpoint_text()
    if _G.ou64_checkpoint_placed and
            not _G.ou64_checkpoint_used then
        tip_text = teleport_text()
    end

    local width = djui_hud_measure_text(tip_text) * _G.ou64_checkpoint_tip_scale
    local x = djui_hud_get_screen_width() / 2 - (width / 2)
    local y = djui_hud_get_screen_height() - (_G.ou64_checkpoint_tip_height * 2) - _G.ou64_checkpoint_tip_y_offset
    djui_hud_set_adjusted_color(0, 0, 0, 128)
    djui_hud_render_rect(x - _G.ou64_checkpoint_tip_x_pad, y - _G.ou64_checkpoint_tip_y_pad, width + (_G.ou64_checkpoint_tip_x_pad * 2), _G.ou64_checkpoint_tip_height + (_G.ou64_checkpoint_tip_y_pad * 2))
    djui_hud_set_adjusted_color(255, 255, 255, 255)
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_print_text(tip_text, x, y, _G.ou64_checkpoint_tip_scale)
end

function render_height_meter()
	djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    if _G.ou64_flood_active and
            (_G.ou64_flood_area == nil or _G.ou64_flood_levels[_G.ou64_flood_area] == nil) then
        return
    end

    local players = {}
    local top_height = not _G.ou64_flood_active and 
        _G.ou64_top_height or
            (_G.ou64_flood_levels[_G.ou64_flood_area].goal_pos.y - _G.ou64_flood_levels[_G.ou64_flood_area].start_pos.y)
    local server_local_index = network_player_from_global_index(0).localIndex
    for i = 0, MAX_PLAYERS - 1 do
        if gNetworkPlayers[i].connected and
                (gServerSettings.headlessServer == 0 or i ~= server_local_index) and
                (gNetworkPlayers[i].currLevelNum == _G.ou64_level_id or
                    gNetworkPlayers[i].currLevelNum == _G.ou64_end_level_id) then
            local character_height = 0
            if gPlayerSyncTable[i].height ~= nil then
                character_height = not _G.ou64_flood_active and 
                    gPlayerSyncTable[i].height or
                        gMarioStates[i].pos.y - _G.ou64_flood_levels[_G.ou64_flood_area].start_pos.y
            end
            local percent_done = character_height / top_height * 100.0
            percent_done = math_max(percent_done, 0)
            percent_done = math_min(percent_done, 100)
            table.insert(players, {
                localIndex = i,
                name = string_without_hex(gNetworkPlayers[i].name),
                percent_done = percent_done,
            })
        end
    end

    table.sort(players, function(p1, p2)
		if p1.percent_done == p2.percent_done then
			return p1.name:upper() > p2.name:upper()
		else
			return p1.percent_done < p2.percent_done
		end
	end)

	-- Height Meter
	local heightX = djui_hud_get_screen_width() - 52
	local heightY = 140
	local heightHeight = 584
	local alpha = if_then_else(is_game_paused(), 100, 255)
	r, g, b, a = 255, 255, 255, alpha
	djui_hud_set_adjusted_color(r, g, b, alpha)
	djui_hud_render_texture(height_meter, heightX + 5, heightY, 6.0, 6.0)
	for i, player in ipairs(players) do
        if player ~= nil and
                gNetworkPlayers[player.localIndex].connected and
                (gServerSettings.headlessServer == 0 or player.localIndex ~= server_local_index) then
            -- Draw Player Head on Height Meter
			local pDone = 0
			pDone = math_max(player.percent_done, 0)
			pDone = math_min(pDone, 100)
			render_player_head(player.localIndex, heightX + 3, heightY + heightHeight - 10 - (heightHeight * pDone / 100), 2, 2)
		end
	end
end

-- render_player_head - modified from EmilyEmmi's Shine Thief
-- https://discord.com/channels/752682015614173235/755907254318006362/1146275236325625897
function render_player_head(index, x, y, scaleX, scaleY)
    local HEAD_HUD = get_texture_info("hud_head_recolor")

    local PART_ORDER = {
        SKIN,
        HAIR,
        CAP,
    }
    local m = gMarioStates[index]
    local np = gNetworkPlayers[index]

    local alpha = if_then_else(m.health <= 0xff or is_game_paused(), 100, 255)
    local tileY = m.character.type
    for i = 1, #(PART_ORDER) do
        local part = PART_ORDER[i]
        if tileY == 2 and part == HAIR then
            part = GLOVES
        end
        local color = network_player_get_override_palette_color(np, part)

        djui_hud_set_color(color.r, color.g, color.b, alpha)
        djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (i-1)*16, tileY*16, 16, 16)
    end

    djui_hud_set_color(255, 255, 255, alpha)
    djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (#PART_ORDER)*16, tileY*16, 16, 16)

    djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (#PART_ORDER+1)*16, tileY*16, 16, 16)
end

function render_leaderboard()
    if _G.ou64_leaderboard == nil and
            not _G.ou64_leaderboard_requesting then
        request_leaderboard()
    elseif _G.ou64_leaderboard ~= nil and
            #_G.ou64_leaderboard > 0 then
        djui_hud_set_resolution(RESOLUTION_DJUI)

        local anchor_x = 10
        local anchor_y = 24

        -- Background Box
        local leaderboard_height = 32 * _G.ou64_leaderboard_entries_per_page + 46
        djui_hud_set_adjusted_color(0, 0, 0, 128)
        djui_hud_render_rect(anchor_x, anchor_y, 420, leaderboard_height)

        -- Leaderboard Title
        djui_hud_set_font(FONT_MENU)
        djui_hud_set_adjusted_color(1, 147, 105, 255)
        djui_hud_print_text("Leaderboard", anchor_x - 8, anchor_y - 24, _G.ou64_run_timer_scale / 1.5)

        djui_hud_set_font(FONT_ALIASED)
        djui_hud_set_adjusted_color(255, 255, 255, 255)

        djui_hud_print_text("Time", anchor_x + 276, anchor_y + 6, _G.ou64_run_timer_scale)
        djui_hud_render_texture(checkpoint_flag, anchor_x + 385, anchor_y + 16, 1.0, 1.0)
        local entries_added = 0 
        local y_offset = 0
        local place_index = 1
        local leaderboard_index = 1
        local uuids = {} 
        while leaderboard_index <= #_G.ou64_leaderboard and
                entries_added < _G.ou64_leaderboard_entries_per_page do
            local entry_name = string_without_hex(_G.ou64_leaderboard[leaderboard_index].player_name)
            local entry_uuid = _G.ou64_leaderboard[leaderboard_index].player_uuid
            if uuids[entry_uuid] == nil then
                uuids[entry_uuid] = true
                entries_added = entries_added + 1
                local place_str = tostring(place_index)
                local place_length = djui_hud_measure_text(place_str)
                local player_name_length = djui_hud_measure_text(entry_name)
                local run_time_msec = format_msec(_G.ou64_leaderboard[leaderboard_index].run_time_msec)
                local run_time_length = djui_hud_measure_text(run_time_msec)
                local checkpoints_used = tostring(_G.ou64_leaderboard[leaderboard_index].checkpoints_used)
                local checkpoint_length = djui_hud_measure_text(checkpoints_used)
                djui_hud_print_text(place_str, 18 + anchor_x - (place_length / 2), 40 + anchor_y + y_offset, _G.ou64_leaderboard_scale)
                local player_name = _G.ou64_leaderboard[leaderboard_index].player_name
                if entry_name == _G.ou64_leaderboard[leaderboard_index].player_name then
                    local cap_color = unpack_color_int(_G.ou64_leaderboard[leaderboard_index].player_cap)
                    local cap_r = 127 + cap_color.r // 2
                    local cap_g = 127 + cap_color.g // 2
                    local cap_b = 127 + cap_color.b // 2
                    player_name = "\\#" .. string_format("%02x", cap_r) .. string_format("%02x", cap_g) .. string_format("%02x", cap_b) .. "\\" .. player_name
                end
                djui_hud_print_colored_text(player_name, 130 + anchor_x - (player_name_length / 2), 40 + anchor_y + y_offset, _G.ou64_leaderboard_scale, 14)
                djui_hud_print_text(run_time_msec, 292 + anchor_x - (run_time_length / 2), 40 + anchor_y + y_offset, _G.ou64_leaderboard_scale)
                djui_hud_print_text(string_format("%s", checkpoints_used), 390 + anchor_x - (checkpoint_length / 2), 40 + anchor_y + y_offset, _G.ou64_leaderboard_scale)
                y_offset = y_offset + 32
                place_index = place_index + 1
            end
            leaderboard_index = leaderboard_index + 1
        end
    end
end

function render_run_timer()
    djui_hud_set_resolution(RESOLUTION_DJUI)

    local anchor_x = 10
    local leaderboard_visible = _G.ou64_leaderboard ~= nil and #_G.ou64_leaderboard > 0 and _G.ou64_show_leaderboard
    local anchor_y = leaderboard_visible and 258 or 24
    local top_height = _G.ou64_top_height

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
    djui_hud_render_rect(anchor_x, anchor_y, 420, timer_height)

    -- Current Run Title
    djui_hud_set_font(FONT_MENU)
    djui_hud_set_adjusted_color(1, 147, 105, 255)
    djui_hud_print_text("Current Runs", anchor_x - 8, anchor_y - 24, _G.ou64_run_timer_scale / 1.5)

    -- Run Timer / Checkpoint Count
    djui_hud_set_adjusted_color(255, 255, 255, 255)
    djui_hud_set_font(FONT_ALIASED)
    djui_hud_print_text("Time", anchor_x + 276, anchor_y + 6, _G.ou64_run_timer_scale)
    djui_hud_render_texture(checkpoint_flag, anchor_x + 385, anchor_y + 16, 1.0, 1.0)

    local time_string = "00:00.00"
    local checkpoints_used = "0"
    if _G.ou64_run_timer_running then
        local time_elapsed = get_global_timer() - _G.ou64_run_timer_start_time
        time_string = format_time(time_elapsed)
        checkpoints_used = string_format("%s", _G.ou64_checkpoint_count)
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

    local height = gPlayerSyncTable[0].height ~= nil and gPlayerSyncTable[0].height or 0
    local percent_done = height / top_height * 100.0
    percent_done = math_max(percent_done, 0)
    percent_done = string.format("%.0f", math_min(percent_done, 100)) .. "%"
    djui_hud_print_text(percent_done, 34 + anchor_x - (djui_hud_measure_text(percent_done) / 2), 40 + anchor_y, _G.ou64_leaderboard_scale)
    djui_hud_print_colored_text(player_name, 130 + anchor_x - (name_length / 2), 40 + anchor_y, _G.ou64_leaderboard_scale, 14)
    djui_hud_print_text(string_format("%s", time_string), 292 + anchor_x - djui_hud_measure_text(time_string) / 2, 40 + anchor_y, _G.ou64_run_timer_scale)
    djui_hud_print_text(string_format("%s", checkpoints_used), 390 + anchor_x - djui_hud_measure_text(checkpoints_used) / 2, 40 + anchor_y, _G.ou64_run_timer_scale)

    local y_offset = 0
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
        local percent_done = entry.height / top_height * 100.0
        percent_done = math_max(percent_done, 0)
        percent_done = string.format("%.0f", math_min(percent_done, 100)) .. "%"
        djui_hud_print_text(percent_done, 34 + anchor_x - (djui_hud_measure_text(percent_done) / 2), 72 + anchor_y + y_offset, _G.ou64_leaderboard_scale)
        djui_hud_print_colored_text(entry_name, 130 + anchor_x - (name_length / 2), 72 + anchor_y + y_offset, _G.ou64_leaderboard_scale, 14)
        djui_hud_print_text(entry.run_time_str, 292 + anchor_x - (run_time_length / 2), 72 + anchor_y + y_offset, _G.ou64_leaderboard_scale)
        djui_hud_print_text(checkpoints, 390 + anchor_x - (checkpoint_length / 2), 72 + anchor_y + y_offset, _G.ou64_leaderboard_scale)
        y_offset = y_offset + 32
    end
end
