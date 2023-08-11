-- name: Only Up 64 Plugin
-- author: DizzyThermal
-- description: Adds character height visible on the HUD (Y) and  Only Up 64 Moveset.

local enable_character_height = true
local enable_only_up_moveset = true

local twirling = false
local twirl_counter = 0
local animation_counter = 0

-- Actions
ACT_GROUND_POUND_JUMP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_WALL_SLIDE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)

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

    -- Calculate Character Height
    characterHeight = math.floor(m.pos.y)
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

function act_ground_pound_jump(m)
    play_mario_sound(m, SOUND_ACTION_TERRAIN_JUMP, CHAR_SOUND_YAHOO)

    common_air_action_step(m, ACT_JUMP_LAND, MARIO_ANIM_TRIPLE_JUMP,
                           AIR_STEP_CHECK_LEDGE_GRAB | AIR_STEP_CHECK_HANG)

    return 0
end

-------------------------------------
--            Wall Slide           --
-- from: mods/extended-moveset.lua --
-------------------------------------
function act_wall_slide(m)
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
    m.vel.y = m.vel.y - 2

    if m.vel.y < -15 then
        m.vel.y = -15
    end
end

function limit_angle(a)
    return (a + 0x8000) % 0x10000 - 0x8000
end

function act_air_hit_wall(m)
    if m.heldObj ~= 0 then
        mario_drop_held_object(m)
    end

    m.actionTimer = m.actionTimer + 1
    if m.actionTimer <= 1 and (m.input & INPUT_A_PRESSED) ~= 0 then
        m.vel.y = 52.0
        m.faceAngle.y = limit_angle(m.faceAngle.y + 0x8000)
        return set_mario_action(m, ACT_WALL_KICK_AIR, 0)
    elseif m.forwardVel >= 38.0 then
        m.wallKickTimer = 5
        if m.vel.y > 0.0 then
            m.vel.y = 0.0
        end

        m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
        return set_mario_action(m, ACT_BACKWARD_AIR_KB, 0)
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

function mario_on_set_action(m)
    if not enable_only_up_moveset then return end

    if m.action == ACT_GROUND_POUND_JUMP then
        m.vel.y = 65.0
    elseif m.action == ACT_WALL_SLIDE then
        m.vel.y = 0.0
    end
end

function mario_update(m)
    if not enable_only_up_moveset then return end

    -- Ground Pound Dive Out (From: mods/extended-moveset.lua)
    if m.action == ACT_GROUND_POUND and (m.input & INPUT_B_PRESSED) ~= 0 then
        mario_set_forward_vel(m, 10.0)
        m.vel.y = 35.0
        set_mario_action(m, ACT_DIVE, 0)
    end

    -- Ground Pound Twirl
    if m.action == ACT_GROUND_POUND and (m.input & INPUT_A_PRESSED) ~= 0 then
        twirling = true
        twirl_counter = 0
        m.vel.y = 42.0
        set_mario_action(m, ACT_TWIRLING, 0)
    end

    -- Ground Pound Jump (From: mods/extended-moveset.lua)
    if m.action == ACT_GROUND_POUND_LAND and (m.input & INPUT_A_PRESSED) ~= 0 then
        set_mario_action(m, ACT_GROUND_POUND_JUMP, 0)
    end
end

function frame_check()
    local m = gMarioStates[0]

    twirl_counter = twirl_counter + 1
    if twirling and twirl_counter >= 20 then
        twirling = false
        twirl_counter = 0
        set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
        -- set_mario_animation(m, MARIO_ANIM_GENERAL_FALL)
        -- set_anim_to_frame(m, 1)
    end
end

function HeightToggle(msg)
	  if msg == string.lower('On') or msg == '1' then
		    enable_character_height = true
		    return true
	  elseif msg == string.lower('Off') or msg == '0' then
		    enable_character_height = false
		    return true
	  end
end

function MovesetToggle(msg)
	  if msg == string.lower('On') or msg == '1' then
		    enable_only_up_moveset = true
		    return true
	  elseif msg == string.lower('Off') or msg == '0' then
		    enable_only_up_moveset = false
		    return true
	  end
end

hook_event(HOOK_ON_HUD_RENDER, print_character_height)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_SET_MARIO_ACTION, mario_on_set_action)
hook_event(HOOK_UPDATE, frame_check)

hook_mario_action(ACT_AIR_HIT_WALL,      { every_frame = act_air_hit_wall })
hook_mario_action(ACT_GROUND_POUND_JUMP, { every_frame = act_ground_pound_jump })
hook_mario_action(ACT_WALL_SLIDE,        { every_frame = act_wall_slide, gravity = act_wall_slide_gravity })

hook_chat_command('only_up_show_height', 'On|Off - Show character height (Y) on HUD. Default is On.', HeightToggle)
hook_chat_command('only_up_moveset', 'On|Off - Enable Only Up 64 Moveset. Default is On.', MovesetToggle)
