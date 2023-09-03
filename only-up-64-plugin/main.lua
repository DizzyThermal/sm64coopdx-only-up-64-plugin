-- name: Only Up 64 Plugin
-- author: DizzyThermal and steven3004
-- description: Only Up 64 Plugin\n\nAdds the following features:\n\n  > Character height visible on the HUD (Y) and Playerlist\n  > Only Up 64 Moveset\n  > Warps (Disabled by Default)

local enable_character_height = true
local enable_only_up_moveset = true

local twirling = false
local twirl_counter = 0
local twirl_count = 10
local animation_counter = 0

-- Actions
ACT_WALL_SLIDE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_KAZE_DIVE_SLIDE = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_DIVING | ACT_FLAG_ATTACKING)
ACT_KAZE_AIR_HIT_WALL = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)

MOD_NAME = "Only Up 64 Beta 1"
function mod_active(mod_name)
    for i in pairs(gActiveMods) do
        if mod_name == gActiveMods[i].name then return true end
    end

    return false
end

function print_character_height()
    m = gMarioStates[0]

    -- Do not show if in the following CUTSCENEs
    if (not enable_character_height
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
    mapPad = 16390
    wallX = 7700

    -- Calculate Character Height
    if mod_active(MOD_NAME) then
        if m.area.index == 7 and m.pos.x > wallX then
            mapPad = mapPad + 32000
        end
        characterHeight = math.floor((mapPad + (32000 * (m.area.index - 1)) + m.pos.y) / 10)
    else
        characterHeight = math.floor(m.pos.y)
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
end

-------------------------------------
--            Wall Slide           --
-- from: mods/extended-moveset.lua --
-------------------------------------
function act_wall_slide(m)
    if not enable_only_up_moveset then return end
    
    if (m.input & INPUT_A_PRESSED) ~= 0 then
        m.vel.y = 52.0
        -- m.faceAngle.y = limit_angle(m.faceAngle.y + 0x8000)
        return set_mario_action(m, ACT_WALL_KICK_AIR, 0)
    end

    -- attempt to stick to the wall a bit. if it's 0, sometimes you'll get kicked off of slightly sloped walls
    mario_set_forward_vel(m, -1.0)

    m.particleFlags = m.particleFlags | PARTICLE_DUST

    play_sound(SOUND_MOVING_TERRAIN_SLIDE + m.terrainSoundAddend, m.marioObj.header.gfx.cameraToObject)
    set_mario_animation(m, MARIO_ANIM_START_WALLKICK)

    if perform_air_step(m, 0) == AIR_STEP_LANDED then
        mario_set_forward_vel(m, 0.0)
        if check_fall_damage_or_get_stuck(m, ACT_HARD_BACKWARD_GROUND_KB) == 0 then
            return set_mario_action(m, ACT_FREEFALL_LAND, 0)
        end
    end

    m.actionTimer = m.actionTimer + 1
    if m.wall == nil and m.actionTimer > 2 then
        mario_set_forward_vel(m, 0.0)
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    return 0
end

function act_wall_slide_gravity(m)
    if not enable_only_up_moveset then return end

    m.vel.y = m.vel.y - 2

    if m.vel.y < -30 then
        m.vel.y = -30
    end
end

function limit_angle(a)
    return (a + 0x8000) % 0x10000 - 0x8000
end

function act_kaze_air_hit_wall(m)

    if m.heldObj ~= 0 then
        mario_drop_held_object(m)
    end

    m.actionTimer = m.actionTimer + 1
    if m.actionTimer <= 1 and (m.input & INPUT_A_PRESSED) ~= 0 then
        m.vel.y = 52.0
        m.faceAngle.y = limit_angle(m.faceAngle.y + 0x8000)
        m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
        return set_mario_action(m, ACT_WALL_KICK_AIR, 0)
    else
        m.faceAngle.y = limit_angle(m.faceAngle.y + 0x8000)
        return set_mario_action(m, ACT_WALL_SLIDE, 0)
    end

    --! Missing return statement (in original C code). The returned value is the result of the call
    -- to set_mario_animation. In practice, this value is nonzero.
    -- This results in this action "cancelling" into itself. It is supposed to
    -- execute three times, each on a separate frame, but instead it executes
    -- three times on the same frame.
    -- This results in firsties only being possible for a single frame, instead
    -- of three.
    return set_mario_animation(m, MARIO_ANIM_START_WALLKICK)
end

function act_kaze_dive_slide(m)
    if (m.input & INPUT_ABOVE_SLIDE) == 0 and ((m.input & INPUT_A_PRESSED) ~= 0 or (m.input & INPUT_B_PRESSED) ~= 0) then
        queue_rumble_data_mario(m, 5, 80)
		if m.actionTimer <= 0 then
			m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
		end
        if m.forwardVel > 0 then
            return set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
        else
            return set_mario_action(m, ACT_BACKWARD_ROLLOUT, 0)
        end
    end

    play_mario_landing_sound_once(m, SOUND_ACTION_TERRAIN_BODY_HIT_GROUND)

    --! If the dive slide ends on the same frame that we pick up on object,
    -- Mario will not be in the dive slide action for the call to
    -- mario_check_object_grab, and so will end up in the regular picking action,
    -- rather than the picking up after dive action.

    if update_sliding(m, 8.0) ~= 0 and is_anim_at_end(m) ~= 0 then
        mario_set_forward_vel(m, 0.0)
        set_mario_action(m, ACT_STOMACH_SLIDE_STOP, 0)
    end

    if mario_check_object_grab(m) ~= 0 then
        mario_grab_used_object(m)
        if m.heldObj ~= 0 then
            m.marioBodyState.grabPos = GRAB_POS_LIGHT_OBJ
        end
        return true
    end

    common_slide_action(m, ACT_STOMACH_SLIDE_STOP, ACT_FREEFALL, MARIO_ANIM_DIVE)
	m.actionTimer = m.actionTimer + 1
    return false
end

function mario_on_set_action(m)
    if not enable_only_up_moveset then return end

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
	
	-- Get sparkles from speed kicks.
	if m.action == ACT_JUMP_KICK and m.forwardVel >= 40 then
        m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
	end
end

function mario_update(m)
    if not enable_only_up_moveset then return end

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
        twirling = true
        twirl_counter = 0
        m.vel.y = 40.0
        set_mario_action(m, ACT_TWIRLING, 0)
    end

    -- Ground Pound Jump (From: mods/extended-moveset.lua)
    if m.action == ACT_GROUND_POUND_LAND and (m.input & INPUT_A_PRESSED) ~= 0 then
        set_mario_action(m, ACT_TRIPLE_JUMP, 0)
    end

    -- Disable Fall Damage
    m.hurtCounter = 0
    m.health = 0x880
end

function frame_check()
    local m = gMarioStates[0]

    twirl_counter = twirl_counter + 1
    if twirling and twirl_counter >= twirl_count then
        twirling = false
        twirl_counter = 0
        set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
    end

    -- Character Heights (Y)
    characterHeight = math.floor(m.pos.y)
    if mod_active(MOD_NAME) then
        mapPad = 16390
        if m.area.index == 7 and m.pos.x > wallX then
            mapPad = mapPad + 32000
        end
        characterHeight = math.floor((mapPad + (32000 * (m.area.index - 1)) + m.pos.y) / 10)
    end

    if enable_character_height then
        gPlayerSyncTable[0].height = characterHeight
        for i = 0, MAX_PLAYERS - 1 do
            network_player_set_description(gNetworkPlayers[i], "Y: " ..tostring(gPlayerSyncTable[i].height), 255, 255, 255, 255)
        end
    end
end

function LevelWarp(msg)
	if not enable_warps then return end

    msg_parts = {}
    for substring in msg:gmatch("%w+") do table.insert(msg_parts, substring) end

    area = 1
	act = 0
    warpId = 10

    if #(msg_parts) > 0 then
      area = tonumber(msg_parts[1])
    end
    if #(msg_parts) > 1 then
      warpId = tonumber(msg_parts[2])
    end

    warp_to_warpnode(gNetworkPlayers[0].currLevelNum, area, act, warpId)

    return true
end

function WarpToggle(msg)
    if not network_is_server() then return end

	if enable_warps == false then
		djui_popup_create("Only Up 64 Plugin: \n\\#00C7FF\\Warps Enabled", 1)
	elseif enable_warps == true then
		djui_popup_create("Only Up 64 Plugin: \n\\#A02200\\Warps Disabled", 1)
	end
	enable_warps = not enable_warps
    return true
end

function HeightToggle(msg)
	if enable_character_height == false then
		djui_popup_create("Only Up 64 Plugin: \n\\#00C7FF\\Y Position Enabled", 1)
	elseif enable_character_height == true then
		djui_popup_create("Only Up 64 Plugin: \n\\#A02200\\Y Position Disabled", 1)
	end
    enable_character_height = not enable_character_height
    return true
end

function MovesetToggle(msg)
	if enable_only_up_moveset == false then
		djui_popup_create("Only Up 64 Plugin: \n\\#00C7FF\\Moveset Enabled", 1)
	elseif enable_only_up_moveset == true then
		djui_popup_create("Only Up 64 Plugin: \n\\#A02200\\Moveset Disabled", 1)
	end
	enable_only_up_moveset = not enable_only_up_moveset
    return true
end

hook_event(HOOK_ON_HUD_RENDER, print_character_height)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_SET_MARIO_ACTION, mario_on_set_action)
hook_event(HOOK_UPDATE, frame_check)

hook_mario_action(ACT_KAZE_AIR_HIT_WALL, { every_frame = act_kaze_air_hit_wall })
hook_mario_action(ACT_KAZE_DIVE_SLIDE,   { every_frame = act_kaze_dive_slide })
hook_mario_action(ACT_WALL_SLIDE,        { every_frame = act_wall_slide, gravity = act_wall_slide_gravity })

hook_chat_command("w", "warp(area, warpNode=10)", LevelWarp)
hook_chat_command('only-up-warps', '- Toggle Only Up 64 Warps [Host Only]', WarpToggle)
hook_chat_command('only-up-height', '- Toggle displaying character height on HUD and player list', HeightToggle)
hook_chat_command('only-up-moveset', '- Toggle Only Up 64 Moveset', MovesetToggle)