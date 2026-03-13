local ByteWriter = require('a-bytewriter')

local math_random,string_format,string_gsub =
      math.random,string.format,string.gsub

---
-- Input Utils
---

-- Limits the provided angle
--- @param a integer
function limit_angle(a)
    return (a + 0x8000) % 0x10000 - 0x8000
end

-- Cancels Inputs for the Provided MarioState.
--- @param m MarioState - the MarioState to cancel inputs against.
--- @param inputs number - the input flags to cancel (i.e., (L_TRIG | R_TRIG))
function cancel_inputs(m, inputs)
    m.controller.buttonPressed = m.controller.buttonPressed & ~inputs
    m.controller.buttonDown = m.controller.buttonDown & ~inputs
end

---
-- Color Utils
---

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

---
-- UUID Utils
---

-- Generates a "random" UUID4 string.
function uuid()
    local uuid4_template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string_gsub(uuid4_template, '[xy]', function (c)
        local v = (c == 'x') and math_random(0, 0xf) or math_random(8, 0xb)
        return string_format('%x', v)
    end)
end

-- Gets (or creates) the user's OU64 ID (UUID4).
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