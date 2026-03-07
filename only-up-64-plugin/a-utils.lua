local ByteWriter = require('a-bytewriter')

local math_random,math_randomseed,string_format,string_gsub,string_match,string_sub =
      math.random,math.randomseed,string.format,string.gsub,string.match,string.sub

math_randomseed(get_time())

-- Limits the provided angle
--- @param a integer
function limit_angle(a)
    return (a + 0x8000) % 0x10000 - 0x8000
end

-- Returns the name without backslash escapes.
--- @param name string
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

-- Returns a packed integer from the provided color table.
--- @param color table
function pack_color_int(color)
    return color.r << 24 | color.g << 16 | color.b << 8 | 0xFF
end

-- Returns an unpacked color table from the provided color integer.
--- @param color_int integer
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
    local run_id = 0
    if network_is_server() then
        -- Create ModFS and OU64 Leaderboard File Descriptor
        local modFs = mod_fs_get() or mod_fs_create()
        local ou64_leaderboard_file = modFs:get_file("ou64-leaderboard") or modFs:create_file("ou64-leaderboard", true)
        if ou64_leaderboard_file ~= nil then
            -- Determine Next Run ID
            if ou64_leaderboard ~= nil and
                    #ou64_leaderboard > 0 then
                for key, entry in pairs(ou64_leaderboard) do
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

    -- Initialize Leaderboard (if necessary)
    if ou64_leaderboard == nil then
        ou64_leaderboard = {}
    end

    -- Insert into Leaderboard and Sort Leaderboard
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
    table.sort(ou64_leaderboard, function(e1, e2)
        if e1.run_time_msec == e2.run_time_msec then
            return e1.run_id < e2.run_id
        else
            return e1.run_time_msec < e2.run_time_msec
        end
    end)
end

function add_to_flood_leaderboard(
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
    local run_id = 0
    if network_is_server() then
        -- Create ModFS and OU64 Leaderboard File Descriptor
        local leaderboard_file_name = string.format("ou64-leaderboard-flood-%s", flood_area)
        local modFs = mod_fs_get() or mod_fs_create()
        local ou64_leaderboard_file = modFs:get_file(leaderboard_file_name) or modFs:create_file(leaderboard_file_name, true)
        if ou64_leaderboard_file ~= nil then
            -- Determine Next Run ID
            if ou64_flood_leaderboard ~= nil and
                    ou64_flood_leaderboard[flood_area] ~= nil and
                    #ou64_flood_leaderboard[flood_area] > 0 then
                for key, entry in pairs(ou64_flood_leaderboard[flood_area]) do
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
            ou64_leaderboard_file:write_integer(player_model, INT_TYPE_U8)
            ou64_leaderboard_file:write_integer(player_hair, INT_TYPE_U32)
            ou64_leaderboard_file:write_integer(player_skin, INT_TYPE_U32)
            ou64_leaderboard_file:write_integer(player_cap, INT_TYPE_U32)
            ou64_leaderboard_file:write_integer(flood_area, INT_TYPE_U8)
            ou64_leaderboard_file:write_integer(flood_hardmode, INT_TYPE_U8)
            ou64_leaderboard_file:write_number(flood_speed, FLOAT_TYPE_F32)
            ou64_leaderboard_file:write_string(player_uuid)
            ou64_leaderboard_file:write_string(coopnet_id)
            ou64_leaderboard_file:write_string(player_name)
            modFs:save()
        end
    end

    -- Insert into Leaderboard and Sort Leaderboard
    if ou64_flood_leaderboard == nil then
        ou64_flood_leaderboard = {
            [1] = {},
            [2] = {},
            [3] = {},
            [4] = {},
            [5] = {},
            [6] = {},
            [7] = {},
            [0] = {},
        }
    elseif ou64_flood_leaderboard[flood_area] == nil then
        ou64_flood_leaderboard[flood_area] = {}
    end
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
    table.sort(ou64_flood_leaderboard[flood_area], function(e1, e2)
        if e1.run_time_msec == e2.run_time_msec then
            return e1.run_id < e2.run_id
        else
            return e1.run_time_msec < e2.run_time_msec
        end
    end)
end

function request_leaderboard()
	if network_is_server() then
        ou64_leaderboard = get_leaderboard(true)
    elseif not ou64_leaderboard_requesting then
        ou64_leaderboard_requesting = true
        local packet = ByteWriter:new()
        packet:u8(ou64_packet_ids.get_leaderboard)
        packet:u8(gNetworkPlayers[0].globalIndex)
        network_send_bytestring_to(
            network_player_from_global_index(0).localIndex,
            true,
            packet:serialize()
        )
    end
end

function request_flood_leaderboard()
    if network_is_server() then
        ou64_flood_leaderboard = get_flood_leaderboard()
    elseif not ou64_leaderboard_requesting then
        ou64_flood_leaderboard_requesting = true
        local packet = ByteWriter:new()
        packet:u8(ou64_packet_ids.get_flood_leaderboard)
        packet:u8(gNetworkPlayers[0].globalIndex)
        network_send_bytestring_to(
            network_player_from_global_index(0).localIndex,
            true,
            packet:serialize()
        )
    end
end

function get_leaderboard(unique_only)
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

    if leaderboard ~= nil and
            #leaderboard > 0 and
            unique_only ~= nil and
            unique_only then
        local uuid_indices = {}
        for i, entry in ipairs(leaderboard) do
            local player_uuid = entry.player_uuid
            if not uuid_indices[player_uuid] then
                uuid_indices[player_uuid] = i
            end
        end
        for i = #leaderboard, 1, -1 do
            local entry = leaderboard[i]
            local player_uuid = entry.player_uuid
            if uuid_indices[player_uuid] ~= i then
                table.remove(leaderboard, i)
            end
        end
    end

    return leaderboard
end

function get_flood_leaderboard()
    local leaderboard = {
        [1] = {},
        [2] = {},
        [3] = {},
        [4] = {},
        [5] = {},
        [6] = {},
        [7] = {},
        [0] = {},
    }

    for i, entry in ipairs({1, 2, 3, 4, 5, 6, 7, 0}) do
        -- Create ModFS and OU64 Leaderboard File Descriptor
        local modFs = mod_fs_get() or mod_fs_create()
        local leaderboard_file_name = string.format("ou64-leaderboard-flood-%s", entry)
        local ou64_leaderboard_file = modFs:get_file(leaderboard_file_name)
        if ou64_leaderboard_file ~= nil then
            ou64_leaderboard_file:set_text_mode(false)
            ou64_leaderboard_file:rewind()
            while not ou64_leaderboard_file:is_eof() do
                local run_id = ou64_leaderboard_file:read_integer(INT_TYPE_U32)
                local timestamp_sec = ou64_leaderboard_file:read_integer(INT_TYPE_U32)
                local run_time_msec = ou64_leaderboard_file:read_integer(INT_TYPE_U32)
                local player_model = ou64_leaderboard_file:read_integer(INT_TYPE_U8)
                local player_hair = ou64_leaderboard_file:read_integer(INT_TYPE_U32)
                local player_skin = ou64_leaderboard_file:read_integer(INT_TYPE_U32)
                local player_cap = ou64_leaderboard_file:read_integer(INT_TYPE_U32)
                local flood_area = ou64_leaderboard_file:read_integer(INT_TYPE_U8)
                local flood_hardmode = ou64_leaderboard_file:read_integer(INT_TYPE_U8)
                local flood_speed = ou64_leaderboard_file:read_number(FLOAT_TYPE_F32)
                local player_uuid = ou64_leaderboard_file:read_string()
                local coopnet_id = ou64_leaderboard_file:read_string()
                local player_name = ou64_leaderboard_file:read_string()
                table.insert(
                    leaderboard[entry],
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

            table.sort(leaderboard[entry], function(e1, e2)
                if e1.run_time_msec == e2.run_time_msec then
                    return e1.run_id < e2.run_id
                else
                    return e1.run_time_msec < e2.run_time_msec
                end
            end)
        end
    end

    return leaderboard
end

function clear_leaderboard()
    if ou64_leaderboard ~= nil then
        for i = #ou64_leaderboard, 1, -1 do
            ou64_leaderboard[i] = nil
        end
    else
        ou64_leaderboard = {}
    end
end

function clear_flood_leaderboard()
    if ou64_flood_leaderboard ~= nil then
        for i, entry in ipairs({1, 2, 3, 4, 5, 6, 7, 0}) do
            if ou64_flood_leaderboard[entry] ~= nil then
                for j = #ou64_flood_leaderboard[entry], 1, -1 do
                    ou64_flood_leaderboard[entry][j] = nil
                end
            end
        end
    else
        ou64_flood_leaderboard = {
            [1] = {},
            [2] = {},
            [3] = {},
            [4] = {},
            [5] = {},
            [6] = {},
            [7] = {},
            [0] = {},
        }
    end
end

function is_best_time(player_uuid, run_time_msec)
    local is_best = true
    local player_in_board = false
    for i, entry in ipairs(ou64_leaderboard) do
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

function is_best_flood_time(flood_area, hardmode, player_uuid, run_time_msec)
    local is_best = true
    local player_in_board = false
    if ou64_flood_leaderboard ~= nil and
            ou64_flood_leaderboard[flood_area] ~= nil and
            #ou64_flood_leaderboard[flood_area] > 0 then
        for i, entry in ipairs(ou64_flood_leaderboard[flood_area]) do
            if entry.hardmode == hardmode and
                    player_uuid == entry.player_uuid then
                player_in_board = true
                if run_time_msec > entry.run_time_msec then
                    is_best = false
                end
            end
        end
    end

    if not player_in_board then
        is_best = true
    end

    return is_best
end

-- Cancels Inputs for the Provided MarioState.
--- @param m MarioState - the MarioState to cancel inputs against.
--- @param inputs number - the input flags to cancel (i.e., (L_TRIG | R_TRIG))
function cancel_inputs(m, inputs)
    m.controller.buttonPressed = m.controller.buttonPressed & ~inputs
    m.controller.buttonDown = m.controller.buttonDown & ~inputs
end

-- Injects hex colors into the player's name, defaulting to their cap color.
--- @param player_name string - the player's name to colorize.
--- @param player_index integer - the player's local index (for cap color lookup).
function get_colored_name(player_name, player_index)
    local colored_name = player_name
    local stripped_name = string_without_hex(player_name)
    if player_name == stripped_name then
        -- No color in name, add cap color as player name's color
        local cap_color = network_player_get_override_palette_color(gNetworkPlayers[player_index], CAP)
        if cap_color ~= nil then
            local cap_r = 127 + cap_color.r // 2
            local cap_g = 127 + cap_color.g // 2
            local cap_b = 127 + cap_color.b // 2
            colored_name = "\\#" .. string_format("%02x", cap_r) .. string_format("%02x", cap_g) .. string_format("%02x", cap_b) .. "\\" .. colored_name
        end
    end

    return colored_name
end

-- Prints text with hex-encoded color (i.e., \\#FF0000\\Ma\\#DD0000\\ri\\#BB0000\\o)
--- @param text string
--- @param x integer
--- @param y integer
--- @param scale number
--- @param limit integer
function djui_hud_print_colored_text(text, x, y, scale, limit)
    local total_space = 0

    local escaping = false
    local char_idx = 1
    local characters_rendered = 0
    local string_length = #(string_without_hex(text))
    while char_idx <= #text do
        local c = string_sub(text, char_idx, char_idx)
        if c == "\\" then
            if not escaping then
                local char_pointer = char_idx + 1
                while char_pointer < #text and
                        string_sub(text, char_pointer, char_pointer) ~= "\\" do
                    char_pointer = char_pointer + 1
                end
                local substring = string_sub(text, char_idx + 1, char_pointer - 1)
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
            if limit ~= nil and
                    string_length > limit and
                    characters_rendered >= limit - 3 then
                djui_hud_print_text("...", (x + total_space) * scale, y, scale)
                djui_hud_set_color(255, 255, 255, 255)
                return
            end
        char_idx = char_idx + 1
        end
    end

    djui_hud_set_color(255, 255, 255, 255)
end
