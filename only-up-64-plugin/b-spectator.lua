-- Localizing for performance.
local is_game_paused,vec3f_copy,mario_drop_held_object,vec3f_set,camera_freeze,camera_unfreeze,allocate_mario_action =
      is_game_paused,vec3f_copy,mario_drop_held_object,vec3f_set,camera_freeze,camera_unfreeze,allocate_mario_action

local l_button = get_texture_info("l_button")
local r_button = get_texture_info("r_button")

ACT_SPECTATOR = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_INVULNERABLE)

-- Determines if a player is spectatable.
--- @param player_index integer
--- @return boolean
local function player_spectatable(player_index)
    -- If the player is not connected, player not spetatable.
    -- If the player is spectating, player not spectatable.
    -- If the server is headless and the player_index is the server, player not spectatable.
    local server_local_index = network_player_from_global_index(0).localIndex
    if not gNetworkPlayers[player_index].connected or
            gPlayerSyncTable[player_index].spectating or
            (gServerSettings.headlessServer == 1 and
                player_index == server_local_index) then
        return false
    end

    return true
end

-- Determines if there are any spectatable players.
--- @return boolean
function are_spectatable_players()
    for i = 1, MAX_PLAYERS - 1 do
        if player_spectatable(i) then
            return true
        end
    end

    return false
end

-- Finds the next spectatable player.
--- @param direction integer
function find_next_player(direction)
    direction = direction ~= nil and (direction >= 0 and 1 or -1) or -1
    local start_camera_index = ou64_camera_index
    ou64_camera_index = (ou64_camera_index + direction) % MAX_PLAYERS
    while not player_spectatable(ou64_camera_index) and
            start_camera_index ~= ou64_camera_index do
        ou64_camera_index = (ou64_camera_index + direction) % MAX_PLAYERS
    end
end

-- Exits spectator mode.
--- @param reset boolean
function exit_spectator_mode(reset)
    reset = reset ~= nil and reset or false
    local np = gNetworkPlayers[0]
    ou64_spectator_mode = false
    m.action = ACT_IDLE
    set_mario_action(m, ACT_IDLE, 0)
    if not reset and
            (ou64_spectator_prev_level ~= np.currLevelNum or
                ou64_spectator_prev_area ~= np.currAreaIndex) then
        ou64_spectator_warping = true
        ou64_spectator_warp_time = get_global_timer()
        warp_to_level(ou64_spectator_prev_level, ou64_spectator_prev_area, _G.ou64_act_id)
    elseif reset then
        warp_to_level(_G.ou64_level_id, 1, _G.ou64_act_id)
    end
    ou64_prev_info_saved = false
end

-- Adds camera information from packet to lLakituStates player array.
--- @param data table
hook_event(HOOK_ON_PACKET_RECEIVE, function(data)
    -- Ignore Packet if not Spectating
    if gMarioStates[0].action ~= ACT_SPECTATOR then return end

    playerIndex = network_local_index_from_global(data.playerIndex)
    vec3f_set(lLakituStates[playerIndex].pos, data.posX, data.posY, data.posZ)
    vec3f_set(lLakituStates[playerIndex].focus, data.focusX, data.focusY, data.focusZ)
    lLakituStates[playerIndex].yaw = data.yaw
    lLakituStates[playerIndex].posHSpeed = data.posHSpeed
    lLakituStates[playerIndex].posVSpeed = data.posVSpeed
    lLakituStates[playerIndex].focHSpeed = data.focHSpeed
    lLakituStates[playerIndex].focVSpeed = data.focVSpeed
end)

-- Unfreeze camera when action changes from ACT_SPECTATOR.
--- @param m MarioState
hook_event(HOOK_ON_SET_MARIO_ACTION, function(m)
    if m.playerIndex ~= 0 then return end

    if m.action ~= ACT_SPECTATOR then
        camera_unfreeze()
        m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags | GRAPH_RENDER_ACTIVE
    end
end)

-- Updates camera parameters to match parameters of player being spectated.
--- @param m MarioState
local function update_camera(m)
    if m.playerIndex ~= 0 or ou64_camera_index == 0 then return end

    vec3f_copy(gLakituState.pos, lLakituStates[ou64_camera_index].pos)
    vec3f_copy(gLakituState.focus, lLakituStates[ou64_camera_index].focus)
    gLakituState.yaw = lLakituStates[ou64_camera_index].yaw
    gLakituState.posHSpeed = lLakituStates[ou64_camera_index].posHSpeed
    gLakituState.posVSpeed = lLakituStates[ou64_camera_index].posVSpeed
    gLakituState.focHSpeed = lLakituStates[ou64_camera_index].focHSpeed
    gLakituState.focVSpeed = lLakituStates[ou64_camera_index].focVSpeed
end

-- ACT_SPECTATOR Action Loop
-- TODO: Finish Reviewing Logic
--- @param m MarioState
---@diagnostic disable-next-line: missing-parameter
hook_mario_action(ACT_SPECTATOR, function(m)
    if m.playerIndex ~= 0 then return end

    -- Reset MarioState Parameters
    mario_drop_held_object(m)
    m.squishTimer = 0
    m.faceAngle.x = 0
    m.faceAngle.z = 0

    -- Make Mario Invisible
    --set_mario_animation(m, MARIO_ANIM_SLEEP_IDLE)
    --m.marioBodyState.eyeState = MARIO_EYES_CLOSED
    m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags & ~GRAPH_RENDER_ACTIVE

    -- Spectate next player
    if ou64_camera_index == 0 then
        find_next_player(1)
    end
    if (not is_game_paused() and
            (m.controller.buttonDown & R_TRIG) ~= 0 and
            not ou64_r_button_pressed) or
                not ou64_camera_index then
        ou64_r_button_pressed = true
        find_next_player(1)
        if ou64_camera_index == 0 then
            find_next_player(1)
        end
    elseif (not is_game_paused() and
            (m.controller.buttonDown & L_TRIG) ~= 0 and
            not ou64_l_button_pressed) or
                not ou64_camera_index then
        ou64_l_button_pressed = true
        find_next_player(-1)
        if ou64_camera_index == 0 then
            find_next_player(-1)
        end
    end

    if ou64_camera_index == 0 then
        exit_spectator_mode(false)
        return
    end

    local np = gNetworkPlayers[0]
    local camera_np = gNetworkPlayers[ou64_camera_index]
    if np.currLevelNum ~= camera_np.currLevelNum or
            np.currAreaIndex ~= camera_np.currAreaIndex then
        -- Warp to same area as the target player
        warp_to_level(camera_np.currLevelNum, camera_np.currAreaIndex, _G.ou64_act_id)
    end

    camera_freeze()
    update_camera(m)
end)

-- Renders spectator HUD elements.
-- TODO: Review RESOLUTION/FONT Positioning 
hook_event(HOOK_ON_HUD_RENDER, function()
    local m = gMarioStates[0]
    if not ou64_spectator_mode or
            lLakituStates[ou64_camera_index] == nil or
            m.action == ACT_END_PEACH_CUTSCENE or
            m.action == ACT_CREDITS_CUTSCENE or
            m.action == ACT_END_WAVING_CUTSCENE or
            obj_get_first_with_behavior_id(id_bhvActSelector) ~= nil then
        return
    end

    -- HUD Parameters
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_MENU)

    local center_x = (djui_hud_get_screen_width() / 2)
    local button_scale = 0.14
    local button_x_pad = 6
    local button_y_pad = 4
    local button_width = 128 * button_scale
    local player_name = gNetworkPlayers[ou64_camera_index].name
    local stripped_name = string_without_hex(player_name)
    local text_scale = 0.2
    local text_x_pad = -4
    local text_y_pad = 2
    local text_width = djui_hud_measure_text(stripped_name) * text_scale
    local letterbox_height = 18
    local colored_name = get_colored_name(player_name, ou64_camera_index)
    local y = (djui_hud_get_screen_height() - letterbox_height)

    -- Draw Bottom Letterbox
    djui_hud_set_adjusted_color(0, 0, 0, 200)
    djui_hud_render_rect(0, y, djui_hud_get_screen_width(), letterbox_height)

    -- Draw Player Name
    djui_hud_set_adjusted_color(255, 255, 255, 255)
    djui_hud_print_colored_text(colored_name, (center_x / text_scale) - (text_width / text_scale / 2) + text_x_pad, y + text_y_pad, text_scale)

    -- Draw L + R Buttons
    djui_hud_render_texture(l_button, center_x - button_width - (text_width / 2) - button_x_pad, y + button_y_pad, button_scale, button_scale)
    djui_hud_render_texture(r_button, center_x + (text_width / 2) + button_x_pad, y + button_y_pad, button_scale, button_scale)
end)

-- Mario Update Hook
hook_event(HOOK_MARIO_UPDATE, function(m)
    if m.playerIndex ~= 0 then return end

    -- Reset L + R button states
    ou64_l_button_pressed = (m.controller.buttonDown & L_TRIG) ~= 0
    ou64_r_button_pressed = (m.controller.buttonDown & R_TRIG) ~= 0

    -- Exit spectator mode if [B] pressed.
    if ou64_spectator_mode and
            (m.controller.buttonDown & B_BUTTON) ~= 0 then
        m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags & GRAPH_RENDER_ACTIVE
        exit_spectator_mode(false)
    end

    -- Set spectating state
    gPlayerSyncTable[0].spectating = ou64_spectator_mode

    -- Enter spectating mode if flag set, but not currently spectating.
    if ou64_spectator_mode and
            m.action ~= ACT_SPECTATOR then
        if not ou64_prev_info_saved then
            -- Save position information to warp back after exiting spectator mode.
            local np = gNetworkPlayers[0]
            ou64_spectator_prev_level = np.currLevelNum
            ou64_spectator_prev_area = np.currAreaIndex
            ou64_spectator_prev_pos_x = m.pos.x
            ou64_spectator_prev_pos_y = m.pos.y
            ou64_spectator_prev_pos_z = m.pos.z
            ou64_spectator_prev_face_angle_y = m.faceAngle.y
            ou64_prev_info_saved = true
        end
        m.area.camera.cutscene = 0
        -- find_next_player(1)
        -- if ou64_camera_index == 0 then
        --     find_next_player(1)
        -- end
        m.action = ACT_SPECTATOR
    end

    -- Exited spectator mode and warped.
    -- Move Mario back to previous location after 1 frame.
    if ou64_spectator_warping and
            (get_global_timer() - ou64_spectator_warp_time) > 1 then
        m.pos.x = ou64_spectator_prev_pos_x
        m.pos.y = ou64_spectator_prev_pos_y
        m.pos.z = ou64_spectator_prev_pos_z
        m.faceAngle.y = ou64_spectator_prev_face_angle_y
        m.vel.x = 0
        m.vel.y = 0
        m.vel.z = 0
        m.forwardVel = 0

        m.marioObj.oIntangibleTimer = 0
        m.hurtCounter = 0
        m.healCounter = 31
        m.invincTimer = 15

        set_mario_action(m, ACT_IDLE, 0)
        m.statusForCamera.action = ACT_IDLE

        local cam = m.area.camera
        soft_reset_camera(cam)

        ou64_spectator_warping = false
    end

    -- Send camera information if not spectating.
    if not ou64_spectator_mode then
        network_send(true, {
            playerIndex = network_global_index_from_local(0),
            posX = gLakituState.pos.x,
            posY = gLakituState.pos.y,
            posZ = gLakituState.pos.z,
            focusX = gLakituState.focus.x,
            focusY = gLakituState.focus.y,
            focusZ = gLakituState.focus.z,
            yaw = gLakituState.yaw,
            posHSpeed = gLakituState.posHSpeed,
            posVSpeed = gLakituState.posVSpeed,
            focHSpeed = gLakituState.focHSpeed,
            focVSpeed = gLakituState.focVSpeed,
        })
    end
end)

--- @param m MarioState
--- @param o Object
hook_event(HOOK_ALLOW_INTERACT, function(m, o)
    if m.action == ACT_SPECTATOR or
            (o.header.gfx.node.flags & GRAPH_RENDER_ACTIVE) == 0 then
        return false
    end

    return true
end)
