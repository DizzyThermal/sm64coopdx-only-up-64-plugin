-- Moveset Custom Actions

ACT_WALL_SLIDE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_KAZE_DIVE_SLIDE = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_DIVING | ACT_FLAG_ATTACKING)
ACT_KAZE_AIR_HIT_WALL = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)

-- Wall slide gravity function.
--- @param m MarioState
local function act_wall_slide_gravity(m)
    if not _G.ou64_plugin_api.settings.enable_moveset then return end

    m.vel.y = m.vel.y - 2

    if m.vel.y < -30 then
        m.vel.y = -30
    end
end

-- Wall slide (originally from: sm64ex-coop/mods/extended-moveset.lua)
--- @param m MarioState
local function act_wall_slide(m)
    if not _G.ou64_plugin_api.settings.enable_moveset then return end

    if (m.input & INPUT_A_PRESSED) ~= 0 then
        m.vel.y = 52.0
        return set_mario_action(m, ACT_WALL_KICK_AIR, 0)
    end

    -- Attempt to stick to the wall a bit. if it's 0, sometimes you'll get kicked off of slightly sloped walls
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
---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
hook_mario_action(ACT_WALL_SLIDE, { every_frame = act_wall_slide, gravity = act_wall_slide_gravity })

-- Kaze air hit wall action.
--- @param m MarioState
local function act_kaze_air_hit_wall(m)
    if m.heldObj ~= 0 then
        mario_drop_held_object(m)
    end

    m.actionTimer = m.actionTimer + 1
    if (m.input & INPUT_A_PRESSED) ~= 0 and
            m.actionTimer <= 1 then
        m.vel.y = 52.0
        m.faceAngle.y = limit_angle(m.faceAngle.y + 0x8000)
        m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
        return set_mario_action(m, ACT_WALL_KICK_AIR, 0)
    else
        m.faceAngle.y = limit_angle(m.faceAngle.y + 0x8000)
        return set_mario_action(m, ACT_WALL_SLIDE, 0)
    end
end
---@diagnostic disable-next-line: missing-fields, missing-parameter, param-type-mismatch
hook_mario_action(ACT_KAZE_AIR_HIT_WALL, { every_frame = act_kaze_air_hit_wall })

-- Kaze dive slide action.
--- @param m MarioState
local function act_kaze_dive_slide(m)
    if (m.input & INPUT_ABOVE_SLIDE) == 0 and
            ((m.input & INPUT_A_PRESSED) ~= 0 or
                (m.input & INPUT_B_PRESSED) ~= 0) then
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
---@diagnostic disable-next-line: missing-fields, missing-parameter, param-type-mismatch
hook_mario_action(ACT_KAZE_DIVE_SLIDE, { every_frame = act_kaze_dive_slide })

-- Set Mario Action Hook.
--- @param m MarioState
hook_event(HOOK_ON_SET_MARIO_ACTION, function(m)
    if not _G.ou64_plugin_api.settings.enable_moveset then return end

    if m.action == ACT_WALL_SLIDE then
        m.vel.y = 0.0
    elseif m.action == ACT_AIR_HIT_WALL then
		return set_mario_action(m, ACT_KAZE_AIR_HIT_WALL, 0)
    elseif m.action == ACT_DIVE_SLIDE then
		return set_mario_action(m, ACT_KAZE_DIVE_SLIDE, 0)
    elseif m.action == ACT_KAZE_AIR_HIT_WALL and
            (m.input & INPUT_A_PRESSED) ~= 0 then
        m.vel.y = 52.0
        m.faceAngle.y = limit_angle(m.faceAngle.y + 0x8000)
        m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
        return set_mario_action(m, ACT_WALL_KICK_AIR, 0)
    end

    -- Get Sparkles from Speed Kicks.
    if m.action == ACT_JUMP_KICK and
            m.forwardVel >= 40 then
        m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
    end
end)

-- Mario Update Hook.
--- @param m MarioState
hook_event(HOOK_MARIO_UPDATE, function(m)
    if not _G.ou64_plugin_api.settings.enable_moveset or
            m.playerIndex ~= 0 then
        return
    end

    -- Ground Pound Dive Out (From: mods/extended-moveset.lua)
    if m.action == ACT_GROUND_POUND and
            (m.input & INPUT_B_PRESSED) ~= 0 then
        if (m.input & INPUT_NONZERO_ANALOG) ~= 0 then
            m.faceAngle.y = m.intendedYaw
        end
        mario_set_forward_vel(m, 10.0)
        m.vel.y = 35.0
        set_mario_action(m, ACT_DIVE, 0)
    end

    -- Ground Pound Twirl
    if m.action == ACT_GROUND_POUND and
            (m.input & INPUT_A_PRESSED) ~= 0 then
        ou64_moveset_twirling = true
        ou64_moveset_twirl_counter = 0
        m.vel.y = 40.0
        set_mario_action(m, ACT_TWIRLING, 0)
    end

    -- Ground Pound Jump (From: mods/extended-moveset.lua)
    if m.action == ACT_GROUND_POUND_LAND and
            (m.input & INPUT_A_PRESSED) ~= 0 then
        set_mario_action(m, ACT_TRIPLE_JUMP, 0)
    end

    -- Instant Turn
    if m.action == ACT_WALKING and
            analog_stick_held_back(m) ~= 0 and
            m.forwardVel > 0 and
            m.forwardVel < 16 and
            (m.input & INPUT_NONZERO_ANALOG) ~= 0 then
        m.faceAngle.y = m.intendedYaw
    end
end)

-- Update Hook.
hook_event(HOOK_UPDATE, function()
    local m = gMarioStates[0]

    -- Twirl Counter
    ou64_moveset_twirl_counter = ou64_moveset_twirl_counter + 1
    if ou64_moveset_twirling
            and ou64_moveset_twirl_counter >= ou64_moveset_twirl_count then
        ou64_moveset_twirling = false
        ou64_moveset_twirl_counter = 0
        set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
    end
end)