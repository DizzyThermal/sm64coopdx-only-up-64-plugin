local ByteWriter = require('a-bytewriter')

local math_floor,math_max,math_min,math_random,math_randomseed,string_format,string_gmatch,string_gsub = math.floor,math.max,math.min,math.random,math.randomseed,string.format,string.gmatch,string.gsub

math_randomseed(get_time())

function if_then_else(cond, if_true, if_false)
    if cond then return if_true end
    return if_false
end

function djui_hud_set_adjusted_color(r, g, b, a)
    local multiplier = 1
    if is_game_paused() then multiplier = 0.5 end
    djui_hud_set_color(r * multiplier, g * multiplier, b * multiplier, a)
end

function get_highest_player_height()
    -- For Flood Support
    local highest_height = -0x8000
    for i = 0, MAX_PLAYERS - 1 do
        if gNetworkPlayers[i].connected and gMarioStates[i].pos.y > highest_height then
            highest_height = gMarioStates[i].pos.y
        end
    end

    return highest_height
end

function limit_angle(a)
    return (a + 0x8000) % 0x10000 - 0x8000
end

function string_without_hex(name)
    local s = ''
    local inSlash = false
    for i = 1, #name do
        local c = name:sub(i,i)
        if c == '\\' then
            inSlash = not inSlash
        elseif not inSlash then
            s = s .. c
        end
    end
    return s
end

-- Menu Functions --
function close_menu()
    _G.ou64_practice_menu_index = 0
    _G.ou64_practice_menu_selection_index = 0
    _G.ou64_practice_menu_returned_neutral = true
    _G.ou64_practice_menu_open = false
end

function get_menu_size()
    local menuSize = 0

    for i, entry in ipairs(_G.ou64_practice_menu) do
        if entry.menu_index == _G.ou64_practice_menu_index then
            menuSize = menuSize + 1
        end
    end

    return menuSize + 1
end

function get_menu_item()
    for i, entry in ipairs(_G.ou64_practice_menu) do
        wLevel = entry.level
        wArea = entry.area
        wAct = entry.act
        wNode = entry.node

        if wLevel == _G.ou64_warp_level
            and wArea == _G.ou64_warp_area
            and wAct == _G.ou64_warp_act
            and wNode == _G.ou64_warp_node then
            return entry
        end
    end

    return nil
end

function last_warp_string()
    local lastWarpString = ""
    local menuItem = get_menu_item()
    if menuItem ~= nil then
        lastWarpString = " [" .. menuItem.text .. "]"
    end

    return lastWarpString
end

function warp_from_menu()
    local menu_size = get_menu_size()

    for i, entry in ipairs(_G.ou64_practice_menu) do
        if entry.menu_index == _G.ou64_practice_menu_index and
                entry.menu_selection_index == _G.ou64_practice_menu_selection_index % menu_size then
            _G.ou64_warp_level = entry.level
            _G.ou64_warp_area = entry.area
            _G.ou64_warp_act = entry.act
            _G.ou64_warp_node = entry.node

            if _G.ou64_warp_level ~= nil and
                    _G.ou64_warp_area ~= nil and
                    _G.ou64_warp_act ~= nil and
                    _G.ou64_warp_node ~= nil then
                reset_timer()
                reset_checkpoints()
                warp_to_warpnode(_G.ou64_warp_level, _G.ou64_warp_area, _G.ou64_warp_act, _G.ou64_warp_node)
            end
        end
    end
end

function render_practice_menu()
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    local menu_size = get_menu_size()

    -- Menu Items
    local menuTexts = {}
    local selectionIndex = 0
    for i, entry in ipairs(_G.ou64_practice_menu) do
        local menu_index = entry.menu_index
        if menu_index == _G.ou64_practice_menu_index then
            table.insert(menuTexts, entry.text)
            selectionIndex = _G.ou64_practice_menu_selection_index % menu_size
        end
    end

    -- Back/Exit
    backText = "Back"
    if _G.ou64_practice_menu_index == 0 then
        backText = "Exit"
    end

    local scale = 1
    local width = 400
    local x = (djui_hud_get_screen_width() - width) * 0.5

    local y = _G.ou64_practice_menu_item_height * 2
    local backOffset = menu_size + 1
    local height = _G.ou64_practice_menu_item_height * backOffset

    local anchor_x = x - 10
    local anchor_y = y


    djui_hud_set_adjusted_color(0, 0, 0, 180)
    djui_hud_render_rect(x - 12, y, width + 24, y + height)
    djui_hud_set_adjusted_color(255, 255, 255, 255)

    djui_hud_set_font(FONT_MENU) 
    djui_hud_set_adjusted_color(1, 147, 105, 255)
    djui_hud_print_text("Practice Menu", anchor_x - 8, anchor_y - 24, _G.ou64_run_timer_scale / 1.5)

    djui_hud_set_font(FONT_ALIASED)
    djui_hud_set_adjusted_color(255, 255, 255, 255)
    -- Print Menu Items
    for i, entry in ipairs(menuTexts) do
        djui_hud_print_text(entry, x + 20, y + (_G.ou64_practice_menu_item_height * i), scale)
    end
    -- Print Back/Exit
    djui_hud_print_text(backText, x + 20, y + (_G.ou64_practice_menu_item_height * backOffset), scale)

    -- Draw Selector
    local backPad = 0
    if selectionIndex >= menu_size - 1 then
        backPad = _G.ou64_practice_menu_item_height
    end
    djui_hud_print_text(">", x, y + (_G.ou64_practice_menu_item_height * (selectionIndex + 1)) + backPad, scale)
end

function check_menu_input(m)
    if not _G.ou64_active or _G.ou64_flood_active then return end

    if not is_game_paused() and _G.ou64_practice_menu_open then
        if m.controller.stickY > 60 and _G.ou64_practice_menu_returned_neutral then
            _G.ou64_practice_menu_returned_neutral = false
            _G.ou64_practice_menu_selection_index = _G.ou64_practice_menu_selection_index - 1
            play_sound(SOUND_MENU_CHANGE_SELECT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
        elseif m.controller.stickY < -60 and _G.ou64_practice_menu_returned_neutral then
            _G.ou64_practice_menu_returned_neutral = false
            _G.ou64_practice_menu_selection_index = _G.ou64_practice_menu_selection_index + 1
            play_sound(SOUND_MENU_CHANGE_SELECT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
        elseif (m.controller.buttonPressed & A_BUTTON) ~= 0 then
            local menu_size = get_menu_size()
            local selectionIndex = _G.ou64_practice_menu_selection_index % menu_size

            if _G.ou64_practice_menu_index == 0 then
                -- Main Menu
                if selectionIndex == (menu_size - 1) then
                    -- Exit
                    play_sound(SOUND_MENU_PAUSE, gMarioStates[0].marioObj.header.gfx.cameraToObject)
                    close_menu()
                elseif selectionIndex == 0 then
                    -- Last Warp
                    if _G.ou64_warped then
                        if _G.ou64_warp_level ~= nil and _G.ou64_warp_area ~= nil and _G.ou64_warp_act ~= nil and _G.ou64_warp_node ~= nil then
                            reset_timer()
                            reset_checkpoints()
                            warp_to_warpnode(_G.ou64_warp_level, _G.ou64_warp_area, _G.ou64_warp_act, _G.ou64_warp_node)
                        end
                    end
                    close_menu()
                else
                    -- Enter Submenu
                    _G.ou64_practice_menu_index = selectionIndex
                    _G.ou64_practice_menu_selection_index = 0
                    play_sound(SOUND_MENU_PAUSE, gMarioStates[0].marioObj.header.gfx.cameraToObject)
                end
            else
                -- Sub Menu
                if selectionIndex == (menu_size - 1) then
                    -- Go Back
                    _G.ou64_practice_menu_index = 0
                    _G.ou64_practice_menu_selection_index = 0
                    play_sound(SOUND_MENU_PAUSE, gMarioStates[0].marioObj.header.gfx.cameraToObject)
                else
                    -- Last Warp
                    warp_from_menu()
                    close_menu()
                end
            end
        elseif (m.controller.buttonPressed & B_BUTTON) ~= 0 then
            if _G.ou64_practice_menu_index == 0 then
                _G.ou64_practice_menu_index = 0
                _G.ou64_practice_menu_selection_index = 0
                play_sound(SOUND_MENU_PAUSE, gMarioStates[0].marioObj.header.gfx.cameraToObject)
                close_menu()
            else
                _G.ou64_practice_menu_index = 0
                _G.ou64_practice_menu_selection_index = 0
            end
        end
    elseif not is_game_paused() then
        if (m.controller.buttonPressed & X_BUTTON) ~= 0 then
            if not _G.ou64_practice_menu_open then
                PracticeMenu()
            else
                close_menu()
            end
        end
    end
    if _G.ou64_practice_menu_open
      and m.controller.stickY > -60
      and m.controller.stickY < 60 then
        _G.ou64_practice_menu_returned_neutral = true
    end
end

function pack_color_int(color)
    return color.r << 24 | color.g << 16 | color.b << 8 | 0xFF
end

function unpack_color_int(color_int)
    local r = (color_int >> 24) & 0xFF
    local g = (color_int >> 16) & 0xFF
    local b = (color_int >> 8) & 0xFF
    local a = color_int & 0xFF

    return {
        r = r,
        g = g,
        b = b,
        a = a,
    }
end

-- Timer Functions
function standing_on_start_timer(m)
    if m.playerIndex ~= 0 then
       return false
    end

    return m.area.index == 1 and
        m.pos.x > 5000 and m.pos.x < 6300 and
        m.pos.y > -16270 and m.pos.y < -15000 and
        m.pos.z > -6300 and m.pos.z < -4900
end

function standing_on_end_timer(m)
    if m.playerIndex ~= 0 then
       return false
    end

    return m.area.index == 0 and
        m.pos.x > -2200 and m.pos.x < -1900 and
        m.pos.y > 13250 and
        m.pos.z > -1400 and m.pos.z < -1000
end

function time_string_to_msec(time_string)
    local time_parts = {}
    for part in string_gmatch(time_string, "([^:]+)") do
        table.insert(time_parts, part)
    end

    local hours, minutes, seconds_millis
    if #time_parts == 3 then
        -- HH:MM:SS.ms
        hours = tonumber(time_parts[1])
        minutes = tonumber(time_parts[2])
        seconds_millis = time_parts[3]
    elseif #time_parts == 2 then
        -- MM:SS.ms
        hours = 0
        minutes = tonumber(time_parts[1])
        seconds_millis = time_parts[2]
    else
        -- Invalid Format
        return nil
    end

    local second_parts = {}
    for part in string_gmatch(seconds_millis, "([^%.]+)") do
        table.insert(second_parts, part)
    end

    local seconds = tonumber(second_parts[1])
    local millis = tonumber(second_parts[2])

    return (hours * 3600000) + (minutes * 60000) + (seconds * 1000) + millis
end

function delta_to_sec(delta)
    return math_floor(delta / 30)
end

function delta_to_msec(delta)
    return math_floor(delta / 30 * 1000)
end

function format_msec(total_msec)
    local total_seconds = math_floor(total_msec / 1000)
    local millis = total_msec % 1000
    local seconds = total_seconds % 60
    local total_minutes = math_floor(total_seconds / 60)
    local minutes = total_minutes % 60
    local hours = math_floor(total_minutes / 60)

    if hours > 0 then
        return string_format("%d:%02d:%02d.%02d", hours, minutes, seconds, millis)
    else
        return string_format("%02d:%02d.%02d", minutes, seconds, millis)
    end
end

function format_time(delta)
    local total_seconds = delta / 30

    local hours = math_floor(total_seconds / 3600)
    local minutes = math_floor((total_seconds % 3600) / 60)
    local seconds = math_floor(total_seconds % 60)
    local millis = math_floor((total_seconds % 1) * 100)
    if hours > 0 then
        return string_format("%d:%02d:%02d.%02d", hours, minutes, seconds, millis)
    else
        return string_format("%02d:%02d.%02d", minutes, seconds, millis)
    end
end

-- Leaderboard Functions
function uuid()
    -- Generates a "random" UUID
    local uuid4_template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string_gsub(uuid4_template, '[xy]', function (c)
        local v = (c == 'x') and math_random(0, 0xf) or math_random(8, 0xb)
        return string_format('%x', v)
    end)
end

function get_ou64_id()
    -- Create ModFS and OU64 ID File Descriptor
    local modFs = mod_fs_get() or mod_fs_create()
    local ou64_id_file = modFs:get_file("ou64-id")

    local ou64_id = uuid()
    if ou64_id_file == nil then
        -- File Doesn't Exist, Create New OU64 ID File
        ou64_id_file = modFs:create_file("ou64-id", true)
        if ou64_id_file == nil then return ou64_id end
        ou64_id_file:set_text_mode(false)
        ou64_id_file:write_string(ou64_id)
        modFs:save()
    else
        -- File Exists, Read OU64 ID
        ou64_id_file:set_text_mode(false)
        ou64_id_file:rewind()
        ou64_id = ou64_id_file:read_string()
        if ou64_id == "ou64-id" or #ou64_id ~= 36 then
            modFs:delete_file("ou64-id")
            modFs:save()
            return get_ou64_id()
        end
    end

    return ou64_id
end

function add_to_leaderboard(
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
    local run_id = -1
    if network_is_server() then
        -- Create ModFS and OU64 Leaderboard File Descriptor
        local modFs = mod_fs_get() or mod_fs_create()
        local ou64_leaderboard_file = modFs:get_file("ou64-leaderboard") or modFs:create_file("ou64-leaderboard", true)
        if ou64_leaderboard_file ~= nil then
            -- Determine Next Run ID
            if _G.ou64_leaderboard ~= nil and
                    #_G.ou64_leaderboard > 0 then
                for key, entry in pairs(_G.ou64_leaderboard) do
                    if entry.run_id >= run_id then
                        run_id = entry.run_id + 1
                    end
                end
            end

            -- Append Run to Leaderboard
            ou64_leaderboard_file:set_text_mode(false)
            ou64_leaderboard_file:seek(0, FILE_SEEK_END)
            ou64_leaderboard_file:write_integer(run_id, INT_TYPE_U32)
            ou64_leaderboard_file:write_integer(timestamp_sec, INT_TYPE_U32)
            ou64_leaderboard_file:write_integer(run_time_msec, INT_TYPE_U32)
            ou64_leaderboard_file:write_integer(checkpoints_used, INT_TYPE_U16)
            ou64_leaderboard_file:write_integer(player_model, INT_TYPE_U8)
            ou64_leaderboard_file:write_integer(player_hair, INT_TYPE_U32)
            ou64_leaderboard_file:write_integer(player_skin, INT_TYPE_U32)
            ou64_leaderboard_file:write_integer(player_cap, INT_TYPE_U32)
            ou64_leaderboard_file:write_string(player_uuid)
            ou64_leaderboard_file:write_string(coopnet_id)
            ou64_leaderboard_file:write_string(player_name)
            modFs:save()
        end
    end

    -- Insert into Leaderboard and Sort Leaderboard
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
    table.sort(_G.ou64_leaderboard, function(e1, e2)
        if e1.run_time_msec == e2.run_time_msec then
            return e1.run_id < e2.run_id
        else
            return e1.run_time_msec < e2.run_time_msec
        end
    end)
end

function request_leaderboard()
	if network_is_server() then
        _G.ou64_leaderboard = get_leaderboard()
    elseif not _G.ou64_leaderboard_requesting then
        _G.ou64_leaderboard_requesting = true
        local packet = ByteWriter:new()
        packet:u8(_G.ou64_packet_ids.get_leaderboard)
        packet:u8(gNetworkPlayers[0].globalIndex)
        network_send_bytestring_to(
            network_player_from_global_index(0).localIndex,
            true,
            packet:serialize()
        )
    end
end

function get_leaderboard()
    local leaderboard = {}

    -- Create ModFS and OU64 Leaderboard File Descriptor
    local modFs = mod_fs_get() or mod_fs_create()
    local ou64_leaderboard_file = modFs:get_file("ou64-leaderboard")
    if ou64_leaderboard_file == nil then return end

    -- Print Leaderboard
    ou64_leaderboard_file:set_text_mode(false)
    ou64_leaderboard_file:rewind()
    while not ou64_leaderboard_file:is_eof() do
        local run_id = ou64_leaderboard_file:read_integer(INT_TYPE_U32)
        local timestamp_sec = ou64_leaderboard_file:read_integer(INT_TYPE_U32)
        local run_time_msec = ou64_leaderboard_file:read_integer(INT_TYPE_U32)
        local checkpoints_used = ou64_leaderboard_file:read_integer(INT_TYPE_U16)
        local player_model = ou64_leaderboard_file:read_integer(INT_TYPE_U8)
        local player_hair = ou64_leaderboard_file:read_integer(INT_TYPE_U32)
        local player_skin = ou64_leaderboard_file:read_integer(INT_TYPE_U32)
        local player_cap = ou64_leaderboard_file:read_integer(INT_TYPE_U32)
        local player_uuid = ou64_leaderboard_file:read_string()
        local coopnet_id = ou64_leaderboard_file:read_string()
        local player_name = ou64_leaderboard_file:read_string()
        table.insert(
            leaderboard,
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

    table.sort(leaderboard, function(e1, e2)
        if e1.run_time_msec == e2.run_time_msec then
            return e1.run_id < e2.run_id
        else
            return e1.run_time_msec < e2.run_time_msec
        end
    end)

    return leaderboard
end

function clear_leaderboard()
    if _G.ou64_leaderboard ~= nil then
        for i = #_G.ou64_leaderboard, 1, -1 do
            _G.ou64_leaderboard[i] = nil
        end
    else
        _G.ou64_leaderboard = {}
    end
end

function is_best_time(player_uuid, run_time_msec)
    local is_best = true
    local player_in_board = false
    for i, entry in ipairs(_G.ou64_leaderboard) do
        if player_uuid == entry.player_uuid then
            player_in_board = true
            if run_time_msec > entry.run_time_msec then
                is_best = false
            end
        end
    end

    if not player_in_board then
        is_best = true
    end

    return is_best
end
