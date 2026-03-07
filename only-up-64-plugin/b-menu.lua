-- Textures
local l_and_r = get_texture_info("l_and_r")

local function bind_menu(m)
    return (m.controller.buttonDown & L_TRIG) ~= 0 and
        (m.controller.buttonDown & R_TRIG) ~= 0
end

-- Renders L + R Menu Tip Texture
local function render_menu_tip()
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_render_texture(l_and_r, djui_hud_get_screen_width() - 24, djui_hud_get_screen_height() - 10, 0.075, 0.075)
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_MENU)
    djui_hud_set_adjusted_color(1, 147, 105, 255)
    djui_hud_print_text("Menu", djui_hud_get_screen_width() - 94, djui_hud_get_screen_height() - 72, ou64_run_timer_scale / 2)
end

-- Renders Menu
local function render_menu()
    if ou64_menu_show_menu then
        djui_hud_set_resolution(RESOLUTION_DJUI)

        -- Menu Parameters
        local menu = ou64_menus[ou64_menu_index]
        local menu_items = menu ~= nil and #menu.entries or 0

        local center_x = (djui_hud_get_screen_width() / 2)
        local center_y = (djui_hud_get_screen_height() / 2)

        local menu_width = 600
        local menu_item_height = 40
        local selector_x_pad = 3
        local text_y_pad = 3
        local checkbox_x_pad = -30
        local checkbox_y_pad = 10
        local checkbox_dim = 20
        local checkbox_border_width = 1

        local menu_y_pad = 40
        local menu_height = (menu_item_height * menu_items) + menu_y_pad + (menu_item_height / 2)
        local anchor_x = center_x - (menu_width / 2)
        local anchor_y = center_y - (menu_height / 2)

        -- Background Box
        djui_hud_set_adjusted_color(0, 0, 0, 180)
        djui_hud_render_rect(anchor_x, anchor_y, menu_width, menu_height)

        -- Menu Title
        djui_hud_set_font(FONT_MENU)
        djui_hud_set_adjusted_color(1, 147, 105, 255)
        djui_hud_print_text(menu.title, anchor_x - 8, anchor_y - 24, ou64_run_timer_scale / 1.5)

        -- Menu Item Selector
        djui_hud_set_adjusted_color(1, 147, 105, 180)
        djui_hud_render_rect(
            anchor_x + selector_x_pad,
            anchor_y + menu_y_pad + (ou64_menu_selection_index * menu_item_height),
            menu_width - (selector_x_pad * 2),
            menu_item_height
        )

        -- Menu Items
        djui_hud_set_font(FONT_MENU)
        local y_offset = 0
        for i, entry in ipairs(menu.entries) do
            -- Menu Item Alignment
            djui_hud_set_font(FONT_MENU)
            local entry_length = djui_hud_measure_text(entry.text) / 2
            local alignment = entry.align ~= nil and entry.align or (menu.align ~= nil and menu.align or "center")
            local x_pos = alignment == "center" and center_x - (entry_length / 2) or 0
            if alignment == "left" then
                x_pos = center_x - (menu_width / 3)
            end
            local y_pos = anchor_y + menu_y_pad + y_offset

            -- Render Menu Item Text
            djui_hud_set_font(FONT_MENU)
            djui_hud_set_adjusted_color(255, 255, 255, 255)
            djui_hud_print_text(
                entry.text,
                x_pos,
                y_pos + text_y_pad,
                0.5
            )

            -- Render Checkbox (if applicable)
            if entry.action == "setting-toggle" then
                -- Checkbox Border
                djui_hud_set_adjusted_color(1, 147, 105, 255)
                djui_hud_render_rect(
                    x_pos + checkbox_x_pad,
                    y_pos + checkbox_y_pad,
                    checkbox_dim,
                    checkbox_dim
                )
                -- Checkbox Background
                djui_hud_set_adjusted_color(0, 0, 0, 255)
                djui_hud_render_rect(
                    x_pos + checkbox_x_pad + checkbox_border_width,
                    y_pos + checkbox_y_pad + checkbox_border_width,
                    checkbox_dim - (checkbox_border_width * 2),
                    checkbox_dim - (checkbox_border_width * 2)
                )
                -- Checkbox [X]
                if ou64_settings[entry.setting_id] ~= nil and
                        ou64_settings[entry.setting_id] then
                    djui_hud_set_adjusted_color(1, 147, 105, 255)
                    djui_hud_set_font(FONT_RECOLOR_HUD)
                    djui_hud_print_text(
                        "X",
                        x_pos + checkbox_x_pad + checkbox_border_width + 3,
                        y_pos + checkbox_y_pad + checkbox_border_width + 1,
                        1
                    )
                end
            end

            y_offset = y_offset + menu_item_height
        end
    end
end

-- Render Character Height / Menu
hook_event(HOOK_ON_HUD_RENDER, function()
    local m = gMarioStates[0]
    if not ou64_active or
            ou64_flood_active or
            m.action == ACT_END_PEACH_CUTSCENE or
            m.action == ACT_CREDITS_CUTSCENE or
            m.action == ACT_END_WAVING_CUTSCENE or
            obj_get_first_with_behavior_id(id_bhvActSelector) ~= nil then
        return
    end

    if ou64_menu_show_menu then
        m = gMarioStates[0]
        m.freeze = 1 -- TODO: Move?
        render_menu()
    elseif not ou64_spectator_mode then
        render_menu_tip()
    end
end)

-- Cancel inputs when menu open.
--- @param m MarioState
hook_event(HOOK_BEFORE_MARIO_UPDATE, function(m)
    if m.playerIndex ~= 0 then return end

    if ou64_menu_show_menu then
        cancel_inputs(m, (U_CBUTTONS | R_CBUTTONS | L_CBUTTONS | D_CBUTTONS))
    end
end)

-- Sets menu state variables based on MarioState input and menu state.
--- @param m MarioState
hook_event(HOOK_MARIO_UPDATE, function(m)
    if m.playerIndex ~= 0 then return end

    local opening_menu = false
    local menu = ou64_menus[ou64_menu_index]
    if not is_game_paused() and
            ou64_menu_show_menu then
        -- Menu Open --
        if m.controller.stickY > 60 and
                (ou64_menu_stick_returned_neutral or
                    ((get_global_timer() - ou64_menu_last_up) > ou64_menu_repeat_delay)) then
            -- Menu Open: Up
            play_sound(SOUND_MENU_CHANGE_SELECT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
            ou64_menu_stick_returned_neutral = false
            ou64_menu_selection_index = (ou64_menu_selection_index - 1) % #menu.entries
            ou64_menu_last_up = get_global_timer()
        elseif m.controller.stickY < -60 and
                (ou64_menu_stick_returned_neutral or
                    ((get_global_timer() - ou64_menu_last_down) > ou64_menu_repeat_delay)) then
            -- Menu Open: Down
            play_sound(SOUND_MENU_CHANGE_SELECT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
            ou64_menu_stick_returned_neutral = false
            ou64_menu_selection_index = (ou64_menu_selection_index + 1) % #menu.entries
            ou64_menu_last_down = get_global_timer()
        elseif (m.controller.buttonPressed & A_BUTTON) ~= 0 then
            -- Menu Open: A Pressed (Select Entry)
            play_sound(SOUND_MENU_PAUSE, gMarioStates[0].marioObj.header.gfx.cameraToObject)
            local selected_menu_index = ou64_menu_selection_index + 1
            local selected_entry = menu.entries[selected_menu_index]
            local close_menu = true
            if selected_entry.action == "restart-level" then
                exit_spectator_mode(true)
            elseif selected_entry.action == "warp" then
                reset_timer()
                reset_checkpoints()
                if ou64_spectator_mode then
                    exit_spectator_mode(false)
                end
                warp_to_warpnode(selected_entry.level, selected_entry.area, selected_entry.act, selected_entry.node)
            elseif selected_entry.action == "spectator-mode" then
                if are_spectatable_players() then
                    ou64_spectator_mode = not ou64_spectator_mode
                    if not ou64_spectator_mode then
                        exit_spectator_mode(false)
                    end
                end
            elseif selected_entry.action == "setting-toggle" then
                local setting_id = selected_entry.setting_id
                if setting_id == "enable_music"
                        and ou64_active then
                    _G.ou64_enable_music = not _G.ou64_enable_music
                    if _G.ou64_enable_music then
                        _G.ou64_api.ou64_play_music()
                    else
                        _G.ou64_api.ou64_stop_music()
                    end
                    save_plugin_settings()
                elseif setting_id == "enable_checkpoints" then
                    ou64_settings.enable_checkpoints = not ou64_settings.enable_checkpoints
                    reset_checkpoints()
                    save_plugin_settings()
                elseif setting_id == "show_height_meter" then
                    ou64_settings.show_height_meter = not ou64_settings.show_height_meter
                    save_plugin_settings()
                elseif setting_id == "show_character_height" then
                    ou64_settings.show_character_height = not ou64_settings.show_character_height
                    if not ou64_settings.show_character_height then
                        for i = 0, MAX_PLAYERS - 1 do
                            network_player_set_description(gNetworkPlayers[i], "", 255, 255, 255, 255)
                        end
                    end
                    save_plugin_settings()
                elseif setting_id == "enable_moveset" then
                    _G.ou64_plugin_api.settings.enable_moveset = not _G.ou64_plugin_api.settings.enable_moveset
                    save_plugin_settings()
                elseif setting_id == "show_run_timer" then
                    ou64_settings.show_run_timer = not ou64_settings.show_run_timer
                    save_plugin_settings()
                elseif setting_id == "show_leaderboard" then
                    ou64_settings.show_leaderboard = not ou64_settings.show_leaderboard
                    save_plugin_settings()
                end
                close_menu = false
            elseif selected_entry.action == "reset-settings" then
                reset_plugin_settings()
                save_plugin_settings()
                close_menu = false
            elseif selected_entry.action == "menu" then
                ou64_menu_index = selected_entry.menu_id
                ou64_menu_selection_index = 0
                close_menu = false
            end
            if close_menu then
                ou64_menu_index = 0
                ou64_menu_selection_index = 0
                ou64_menu_show_menu = false
            end
        elseif (m.controller.buttonPressed & B_BUTTON) ~= 0 then
            -- Menu Open: B Pressed, Close Menu
            play_sound(SOUND_MENU_PAUSE, gMarioStates[0].marioObj.header.gfx.cameraToObject)
            local selected_menu_index = ou64_menu_selection_index + 1
            local selected_entry = menu.entries[selected_menu_index]
            if selected_entry.prev_menu_id ~= nil then
                ou64_menu_index = selected_entry.prev_menu_id
                if selected_entry.prev_menu_index ~= nil then
                    ou64_menu_selection_index = selected_entry.prev_menu_index
                end
            else
                ou64_menu_index = 0
                ou64_menu_selection_index = 0
                ou64_menu_show_menu = false
                ou64_menu_stick_returned_neutral = true
            end
        end
    elseif not is_game_paused() then
        if bind_menu(m) and
                not ou64_menu_show_menu and
                not ou64_spectator_mode and
                not ou64_menu_state_changed then
            -- Menu Closed: Open Menu if L + R Pressed
            opening_menu = true
            ou64_menu_state_changed = true
            ou64_menu_show_menu = true
            play_sound(SOUND_MENU_PAUSE, gMarioStates[0].marioObj.header.gfx.cameraToObject)
        end
    end
    if bind_menu(m) and
            not opening_menu and
            ou64_menu_show_menu and
            not ou64_menu_state_changed then
        -- Menu Open: Close Menu if L + R Pressed
        ou64_menu_state_changed = true
        ou64_menu_index = 0
        ou64_menu_selection_index = 0
        ou64_menu_show_menu = false
        play_sound(SOUND_MENU_PAUSE, gMarioStates[0].marioObj.header.gfx.cameraToObject)
    end
    if (m.controller.buttonDown & L_TRIG) == 0 or
            (m.controller.buttonDown & R_TRIG) == 0 then
        -- L + R Reset
        ou64_menu_state_changed = false
    end
    if ou64_menu_show_menu and
            m.controller.stickY > -60 and
            m.controller.stickY < 60 then
        -- Menu Open: Neutral on Stick
        ou64_menu_stick_returned_neutral = true
    end

    -- Lock / Unlock Mario depending on Menu State
    m.freeze = ou64_menu_show_menu and 1 or 0
end)

-- Prevent Lakitu/Mario Cam Swap when L_TRIG Down
hook_event(HOOK_ON_CHANGE_CAMERA_ANGLE, function()
    if ou64_menu_show_menu or
            (m.controller.buttonDown & L_TRIG) ~= 0 then
        return false
    end

    return true
end)