-- Localize for performance.
local math_abs,math_floor,math_max,math_min,string_format =
      math.abs,math.floor,math.max,math.min,string.format

-- Textures
local height_meter = get_texture_info("height-meter")

-- Character Height Parameters
local ou64_character_height_scale = 1
local ou64_character_height_x_pad_negative = 13
local ou64_character_height_y_pad_negative = 3
local ou64_map_pad = 16390
ou64_top_height = 25380

local function render_character_height()
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_HUD)

    local character_height = gPlayerSyncTable[0].height
    if character_height == nil then return end

    local screen_height = djui_hud_get_screen_height()
    local screen_width = djui_hud_get_screen_width()

    -- Update Player List Descriptions with Player Heights
    if ou64_settings.show_character_height and
            not ou64_flood_active then
        for i = 0, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].currLevelNum == _G.ou64_level_id then
                network_player_set_description(gNetworkPlayers[i], "Y: " .. tostring(gPlayerSyncTable[i].height), 255, 255, 255, 255)
            else
                network_player_set_description(gNetworkPlayers[i], "", 255, 255, 255, 255)
            end
        end
    end

    if not ou64_active or
            gNetworkPlayers[0].currLevelNum == _G.ou64_level_id then
        -- Render Character Height (Y Value) 
        negative_height = character_height < 0 and true or false
        if negative_height then
            character_height = math_abs(character_height)
        end
        local x_value = ou64_active and 30 or 50
        local y_value = ou64_active and 4 or (screen_height - 58)
        local y_height = character_height
        if ou64_spectator_mode then
            y_height = gPlayerSyncTable[ou64_camera_index].height
        end
        y_height = y_height ~= nil and y_height or 0
        dist_num = tonumber(string_format('%.0f', y_height))
        text_length = djui_hud_measure_text(tostring(dist_num))
        djui_hud_print_text(
            string_format("Y %.0f", y_height),
            (screen_width - x_value - text_length),
            y_value,
            ou64_character_height_scale
        )
        if negative_height then
            djui_hud_set_color(246, 190, 0, 255)
            djui_hud_render_texture(
                get_texture_info("minus"),
                (screen_width - x_value - text_length + ou64_character_height_x_pad_negative),
                (y_value + ou64_character_height_y_pad_negative),
                (ou64_character_height_scale * 1.3), (ou64_character_height_scale * 1.3)
            )
        end
    end
end

local function render_height_meter()
	djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    local players = {}
    local top_height = not ou64_flood_active and 
        ou64_top_height or
            (_G.ou64_flood_levels[_G.ou64_flood_area].goal_pos.y - _G.ou64_flood_levels[_G.ou64_flood_area].start_pos.y)
    local server_local_index = network_player_from_global_index(0).localIndex
    for i = 0, MAX_PLAYERS - 1 do
        local spectating = gPlayerSyncTable[i].spectating ~= nil and gPlayerSyncTable[i].spectating or false
        if gNetworkPlayers[i].connected and
                (gServerSettings.headlessServer == 0 or i ~= server_local_index) and
                (gNetworkPlayers[i].currLevelNum == _G.ou64_level_id or
                    gNetworkPlayers[i].currLevelNum == _G.ou64_end_level_id) and
                    not spectating then
            local character_height = 0
            if gPlayerSyncTable[i].height ~= nil then
                character_height = not ou64_flood_active and 
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
	local alpha = is_game_paused() and 100 or 255
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

-- Render Character Height
hook_event(HOOK_ON_HUD_RENDER, function()
    m = gMarioStates[0]

    if m.action == ACT_END_PEACH_CUTSCENE or
            m.action == ACT_CREDITS_CUTSCENE or
            m.action == ACT_END_WAVING_CUTSCENE or
            obj_get_first_with_behavior_id(id_bhvActSelector) ~= nil then return end

    -- Render Character Height on HUD (Y Value)
    if ou64_settings.show_character_height and
            not ou64_flood_active then
        render_character_height()
    end

    -- Player Height Meter
    if ou64_settings.show_height_meter and
            ou64_active and
            (not ou64_flood_active or
                not ou64_flood_in_lobby) and
            (not ou64_flood_active or
                _G.ou64_flood_area ~= nil) and
            (not ou64_flood_active or
                _G.ou64_flood_levels[_G.ou64_flood_area] ~= nil) then
        render_height_meter()
    end
end)

-- Update Character Height
hook_event(HOOK_UPDATE, function()
    local m = gMarioStates[0]

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