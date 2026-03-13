-- Localize for performance.
local string_sub,string_match =
      string.sub,string.match

-- Textures
checkpoint_flag = get_texture_info("checkpoint-flag")

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

-- Sets the HUD color multiplied dependent on the pause status.
--- @param r integer - red
--- @param g integer - green
--- @param b integer - blue
--- @param a integer - alpha
function djui_hud_set_adjusted_color(r, g, b, a)
    local multiplier = is_game_paused() and 0.5 or 1
    djui_hud_set_color(
        r * multiplier,
        g * multiplier,
        b * multiplier,
        a
    )
end

-- Renders recolored player heads - modified from EmilyEmmi's Shine Thief
-- https://discord.com/channels/752682015614173235/755907254318006362/1146275236325625897
--- @param index integer
--- @param x integer
--- @param y integer
--- @param scale_x number
--- @param scale_y number
function render_player_head(index, x, y, scale_x, scale_y)
    local head_hud = get_texture_info("hud_head_recolor")

    local parts = {
        SKIN,
        HAIR,
        CAP,
    }
    local m = gMarioStates[index]
    local np = gNetworkPlayers[index]

    local alpha = (m.health <= 0xff or is_game_paused()) and 100 or 255
    local tile_y = m.character.type
    for i = 1, #parts do
        local part = parts[i]
        if tile_y == 2 and
                part == HAIR then
            part = GLOVES
        end
        local color = network_player_get_override_palette_color(np, part)

        djui_hud_set_color(color.r, color.g, color.b, alpha)
        djui_hud_render_texture_tile(head_hud, x, y, scale_x, scale_y, (i - 1) * 16, tile_y * 16, 16, 16)
    end

    djui_hud_set_color(255, 255, 255, alpha)
    djui_hud_render_texture_tile(head_hud, x, y, scale_x, scale_y, #parts * 16, tile_y * 16, 16, 16)
    djui_hud_render_texture_tile(head_hud, x, y, scale_x, scale_y, (#parts + 1) * 16, tile_y * 16, 16, 16)
end

-- Renders recolored player heads from provided model/hair/skin/cap - modified from EmilyEmmi's Shine Thief
-- https://discord.com/channels/752682015614173235/755907254318006362/1146275236325625897
--- @param model integer
--- @param hair integer
--- @param skin integer
--- @param cap integer
--- @param x integer
--- @param y integer
--- @param scale_x number
--- @param scale_y number
function render_player_head_from_parts(model, hair, skin, cap, x, y, scale_x, scale_y)
    local head_hud = get_texture_info("hud_head_recolor")
    local alpha = (m.health <= 0xff or is_game_paused()) and 100 or 255
    local tile_y = model

    local skin_color = unpack_color_int(skin)
    djui_hud_set_color(skin_color.r, skin_color.g, skin_color.b, alpha)
    djui_hud_render_texture_tile(head_hud, x, y, scale_x, scale_y, (1 - 1) * 16, tile_y * 16, 16, 16)
    local hair_color = unpack_color_int(hair)
    djui_hud_set_color(hair_color.r, hair_color.g, hair_color.b, alpha)
    djui_hud_render_texture_tile(head_hud, x, y, scale_x, scale_y, (2 - 1) * 16, tile_y * 16, 16, 16)
    local cap_color = unpack_color_int(cap)
    djui_hud_set_color(cap_color.r, cap_color.g, cap_color.b, alpha)
    djui_hud_render_texture_tile(head_hud, x, y, scale_x, scale_y, (3 - 1) * 16, tile_y * 16, 16, 16)

    djui_hud_set_color(255, 255, 255, alpha)
    djui_hud_render_texture_tile(head_hud, x, y, scale_x, scale_y, 3 * 16, tile_y * 16, 16, 16)
    djui_hud_render_texture_tile(head_hud, x, y, scale_x, scale_y, 4 * 16, tile_y * 16, 16, 16)
end