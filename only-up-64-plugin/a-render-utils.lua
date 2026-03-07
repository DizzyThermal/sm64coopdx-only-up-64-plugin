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