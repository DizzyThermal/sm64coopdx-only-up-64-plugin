-- name: Only Up 64 Plugin v1.7
-- author: DizzyThermal and steven3004
-- description: Only Up 64 Plugin\n\nAdds the following features:\n\n  > Character height visible on the HUD (Y) and Playerlist\n  > Only Up 64 Moveset\n  > Warp Menu (Disabled by Default)

-- Active Mods
OU_ACTIVE = mod_active("Only Up 64 v")
OU_FLOOD_ACTIVE = mod_active("Only Up 64 Flood")

-- Render Character Height / Menu
hook_event(HOOK_ON_HUD_RENDER, function()
    m = gMarioStates[0]

    -- Do not show if in the following CUTSCENEs
    if (not ENABLE_CHARACTER_HEIGHT
      or m.action == ACT_END_PEACH_CUTSCENE
      or m.action == ACT_CREDITS_CUTSCENE
      or m.action == ACT_END_WAVING_CUTSCENE
      or obj_get_first_with_behavior_id(id_bhvActSelector) ~= nil) then return end

    -- Character Height Screen Location
    djui_hud_set_resolution(RESOLUTION_N64)
    screenHeight = djui_hud_get_screen_height()
    screenWidth = djui_hud_get_screen_width()
    scale = 1
    xPad = 50
    yPad = 58
    xNegativePad = 16
    yNegativePad = 3

    -- Calculate Character Height
    characterHeight = math.floor(m.pos.y)
    if OU_FLOOD_ACTIVE and m.health < 0xFF then
        characterHeight = get_highest_player_height()
    end

    if OU_ACTIVE then
        areaIndex = m.area.index - 1
        if areaIndex < 0 then
            areaIndex = 7
        end
        characterHeight = math.floor((MAP_PAD + (32000 * areaIndex) + characterHeight) / 10)
    end

    negative = false
    if characterHeight < 0 then
        negative = true
        characterHeight = math.abs(characterHeight)
    end
    distNum = tonumber(string.format('%.0f', characterHeight))
    textLength = djui_hud_measure_text(tostring(distNum))

    -- Print Text
    djui_hud_set_font(FONT_HUD)
    djui_hud_print_text(string.format("Y  %.0f", characterHeight), (screenWidth - xPad - textLength), (screenHeight - yPad), scale)

    if negative then
        djui_hud_set_color(246, 190, 0, 255)
        djui_hud_render_texture(get_texture_info("minus"), (screenWidth - xPad - textLength + xNegativePad), (screenHeight - yPad + yNegativePad), (scale * 1.3), (scale * 1.3))
    end

    -- Render Practice Menu
    if IN_PRACTICE_MENU then render_practice_menu() end
end)

-- Mario Update Hook --
hook_event(HOOK_MARIO_UPDATE, function(m)
    if not ENABLE_ONLY_UP_MOVESET then return end

    if m.playerIndex ~= 0 then return end

    -- Ground Pound Dive Out (From: mods/extended-moveset.lua)
    if m.action == ACT_GROUND_POUND and (m.input & INPUT_B_PRESSED) ~= 0 then
        if (m.input & INPUT_NONZERO_ANALOG) ~= 0 then
            m.faceAngle.y = m.intendedYaw
        end
        mario_set_forward_vel(m, 10.0)
        m.vel.y = 35.0
        set_mario_action(m, ACT_DIVE, 0)
    end

    -- Ground Pound Twirl
    if m.action == ACT_GROUND_POUND and (m.input & INPUT_A_PRESSED) ~= 0 then
        TWIRLING = true
        TWIRL_COUNTER = 0
        m.vel.y = 40.0
        set_mario_action(m, ACT_TWIRLING, 0)
    end

    -- Ground Pound Jump (From: mods/extended-moveset.lua)
    if m.action == ACT_GROUND_POUND_LAND and (m.input & INPUT_A_PRESSED) ~= 0 then
        set_mario_action(m, ACT_TRIPLE_JUMP, 0)
    end

    -- Instant Turn
    if m.action == ACT_WALKING
      and analog_stick_held_back(m) ~= 0
      and m.forwardVel > 0
      and m.forwardVel < 16
      and m.input & INPUT_NONZERO_ANALOG ~= 0 then
        m.faceAngle.y = m.intendedYaw
        --set_mario_action(m, ACT_FINISH_TURNING_AROUND, 0)
        print("Setting action")
    end
end)

-- On Set Mario Action Hook --
hook_event(HOOK_ON_SET_MARIO_ACTION, function(m)
    if not ENABLE_ONLY_UP_MOVESET then return end

    if m.action == ACT_WALL_SLIDE then
        m.vel.y = 0.0
    elseif m.action == ACT_AIR_HIT_WALL then
		return set_mario_action(m, ACT_KAZE_AIR_HIT_WALL, 0)
    elseif m.action == ACT_DIVE_SLIDE then
		return set_mario_action(m, ACT_KAZE_DIVE_SLIDE, 0)
    elseif m.action == ACT_KAZE_AIR_HIT_WALL and (m.input & INPUT_A_PRESSED) ~= 0 then
        m.vel.y = 52.0
        m.faceAngle.y = limit_angle(m.faceAngle.y + 0x8000)
        m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
        return set_mario_action(m, ACT_WALL_KICK_AIR, 0)
    end

    -- Get Sparkles from Speed Kicks.
    if m.action == ACT_JUMP_KICK and m.forwardVel >= 40 then
        m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
    end
end)

-- Update Hook --
hook_event(HOOK_UPDATE, function()
    local m = gMarioStates[0]

    TWIRL_COUNTER = TWIRL_COUNTER + 1
    if TWIRLING and TWIRL_COUNTER >= TWIRL_COUNT then
        TWIRLING = false
        TWIRL_COUNTER = 0
        set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
    end

    if ENABLE_CHARACTER_HEIGHT and not OU_FLOOD_ACTIVE then
        -- Character Heights (Y)
        characterHeight = math.floor(m.pos.y)
        if OU_ACTIVE then
            areaIndex = m.area.index - 1
            if areaIndex < 0 then
                areaIndex = 7
            end
            characterHeight = math.floor((MAP_PAD + (32000 * areaIndex) + m.pos.y) / 10)
        end

        gPlayerSyncTable[0].height = characterHeight
        for i = 0, MAX_PLAYERS - 1 do
            network_player_set_description(gNetworkPlayers[i], "Y: " ..tostring(gPlayerSyncTable[i].height), 255, 255, 255, 255)
        end
    end

    -- Lock / Unlock Mario depending on Practice Menu State
    m.freeze = IN_PRACTICE_MENU and 1 or 0

    -- Menu Selection
    check_menu_input(m)
end)

-- Character Height --
function HeightToggle()
	ENABLE_CHARACTER_HEIGHT = not ENABLE_CHARACTER_HEIGHT
    if ENABLE_CHARACTER_HEIGHT then
		djui_popup_create("Only Up 64 Plugin: \n\\#00C7FF\\Y Position Enabled", 1)
	else
		djui_popup_create("Only Up 64 Plugin: \n\\#A02200\\Y Position Disabled", 1)
        for i = 0, MAX_PLAYERS - 1 do
            network_player_set_description(gNetworkPlayers[i], "", 255, 255, 255, 255)
        end
	end
    return true
end
hook_chat_command('only-up-height', '- Toggle Character height on HUD and Player List', HeightToggle)

-- Only Up 64 Moveset --
function MovesetToggle()
	ENABLE_ONLY_UP_MOVESET = not ENABLE_ONLY_UP_MOVESET
    if ENABLE_ONLY_UP_MOVESET then
		djui_popup_create("Only Up 64 Plugin: \n\\#00C7FF\\Moveset Enabled", 1)
	else
		djui_popup_create("Only Up 64 Plugin: \n\\#A02200\\Moveset Disabled", 1)
	end
    return true
end
hook_chat_command('only-up-moveset', '- Toggle Only Up 64 Moveset', MovesetToggle)

-- Warp Menu for Practice --
function PracticeMenu()
    if not gGlobalSyncTable.enable_warps then
        djui_popup_create("Only Up 64 Plugin: \n\\#A02200\\Warps Not Enabled!", 1)
        return true
    end

    IN_PRACTICE_MENU = true
    PRACTICE_MENU[1].text = "Last Warp" .. last_warp_string()
    return true
end
function WarpToggle()
    gGlobalSyncTable.enable_warps = not gGlobalSyncTable.enable_warps
    if gGlobalSyncTable.enable_warps then
        djui_popup_create("Only Up 64 Plugin: \n\\#00C7FF\\Warps Enabled", 1)
    else
        djui_popup_create("Only Up 64 Plugin: \n\\#A02200\\Warps Disabled", 1)
    end
    return true
end
if OU_ACTIVE and not OU_FLOOD_ACTIVE then
    function PracticeMenu()
        if not gGlobalSyncTable.enable_warps then
            djui_popup_create("Only Up 64 Plugin: \n\\#A02200\\Warps Not Enabled!", 1)
            return true
        end

        IN_PRACTICE_MENU = true
        PRACTICE_MENU[1].text = "Last Warp" .. last_warp_string()
        play_sound(SOUND_MENU_PAUSE, gMarioStates[0].marioObj.header.gfx.cameraToObject)
        return true
    end
    hook_chat_command("only-up-practice", "- [X] Warp Menu (Must be Enabled)", PracticeMenu)

    if network_is_server() or network_is_moderator() then
        hook_chat_command('only-up-warps', '- Toggle Warps [Mod Only]', WarpToggle)
    end
end
hook_event(HOOK_ON_WARP, function() WARPED = true end)

-- Mario Action Hooks
---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
hook_mario_action(ACT_KAZE_AIR_HIT_WALL, { every_frame = act_kaze_air_hit_wall })
---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
hook_mario_action(ACT_KAZE_DIVE_SLIDE, { every_frame = act_kaze_dive_slide })
---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
hook_mario_action(ACT_WALL_SLIDE, { every_frame = act_wall_slide, gravity = act_wall_slide_gravity })