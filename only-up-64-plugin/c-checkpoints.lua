-- Textures
local d_pad_down = get_texture_info("d_pad_down")
local d_pad_up = get_texture_info("d_pad_up")

-- Checkpoint State
local ou64_checkpoint_placed = false
local ou64_checkpoint_used = false
local ou64_checkpoint_x = 0
local ou64_checkpoint_y = 0
local ou64_checkpoint_z = 0
local ou64_checkpoint_face_angle_y = 0
local ou64_checkpoint_cam_pos_x = 0
local ou64_checkpoint_cam_pos_y = 0
local ou64_checkpoint_cam_pos_z = 0
local ou64_checkpoint_cam_focus_x = 0
local ou64_checkpoint_cam_focus_y = 0
local ou64_checkpoint_cam_focus_z = 0
local ou64_checkpoint_cam_yaw = 0
local ou64_checkpoint_area = 1
local ou64_checkpoint_warp_time = 0

-- Checkpoint State (Global)
ou64_checkpoint_count = 0
gPlayerSyncTable[0].checkpoint_count = 0
ou64_checkpoint_flag_obj = nil
ou64_checkpoint_warping = false

local function bhv_checkpoint_flag_init(obj)
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj.oAnimations = gObjectAnimations.koopa_flag_seg6_anims_06001028
    obj_init_animation(obj, 0)
    cur_obj_scale(0.2)
    cur_obj_hide()
end

local function bhv_checkpoint_flag_loop(obj)
    if not ou64_settings.enable_checkpoints or
            not ou64_checkpoint_placed or
            gMarioStates[0].area.index ~= ou64_checkpoint_area then
        cur_obj_hide()
    else
        obj_set_pos(obj, ou64_checkpoint_x, ou64_checkpoint_y, ou64_checkpoint_z)
        cur_obj_unhide()
    end
end

id_bhvCheckpointFlag = hook_behavior(nil, OBJ_LIST_LEVEL, true, bhv_checkpoint_flag_init, bhv_checkpoint_flag_loop)

function reset_checkpoints()
    ou64_checkpoint_x = 0
    ou64_checkpoint_y = 0
    ou64_checkpoint_z = 0
    ou64_checkpoint_face_angle_y = 0
    ou64_checkpoint_lak_pos_x = 0
    ou64_checkpoint_lak_pos_y = 0
    ou64_checkpoint_lak_pos_z = 0
    ou64_checkpoint_lak_focus_x = 0
    ou64_checkpoint_lak_focus_y = 0
    ou64_checkpoint_lak_focus_z = 0
    ou64_checkpoint_lak_yaw = 0
    ou64_checkpoint_lak_pos_h_speed = 0
    ou64_checkpoint_lak_pos_v_speed = 0
    ou64_checkpoint_lak_foc_h_speed = 0
    ou64_checkpoint_lak_foc_v_speed = 0
    ou64_checkpoint_warping = false
    ou64_checkpoint_warp_time = 0
    ou64_checkpoint_area = 1
    ou64_checkpoint_placed = false
    ou64_checkpoint_used = false
    ou64_checkpoint_count = 0
    gPlayerSyncTable[0].checkpoint_count = 0
end

local function teleport(m)
    if ou64_settings.enable_checkpoints then
        if ou64_checkpoint_placed then
            if ou64_checkpoint_area ~= m.area.index then
                -- Warp to Correct Area
                m.area.index = ou64_checkpoint_area
                ou64_checkpoint_warping = true
                ou64_checkpoint_warp_time = get_global_timer()
                warp_to_level(_G.ou64_level_id, m.area.index, _G.ou64_act_id)
            end

            m.pos.x = ou64_checkpoint_x
            m.pos.y = ou64_checkpoint_y
            m.pos.z = ou64_checkpoint_z
            m.faceAngle.y = ou64_checkpoint_face_angle_y
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
            soft_reset_camera(m.area.camera)

            cam.pos.x = ou64_checkpoint_cam_pos_x
            cam.pos.y = ou64_checkpoint_cam_pos_y
            cam.pos.z = ou64_checkpoint_cam_pos_z
            cam.focus.x = ou64_checkpoint_cam_focus_x
            cam.focus.y = ou64_checkpoint_cam_focus_y
            cam.focus.z = ou64_checkpoint_cam_focus_z
            cam.yaw = ou64_checkpoint_cam_yaw

            play_sound(SOUND_ACTION_TELEPORT, m.marioObj.header.gfx.cameraToObject)
            ou64_checkpoint_used = true
        else
            play_sound(SOUND_GENERAL_MOVING_IN_SAND, m.marioObj.header.gfx.cameraToObject)
        end
    end
end

local function checkpoint(m)
    local stationary = (m.action & ACT_FLAG_STATIONARY) ~= 0
    local ledge_grabbing = m.action == ACT_LEDGE_GRAB

    if ou64_settings.enable_checkpoints then
        if stationary and
                not ledge_grabbing and
                not standing_on_start_timer(m) and
                not (ou64_checkpoint_x == m.pos.x and 
                    ou64_checkpoint_y == m.pos.y and
                    ou64_checkpoint_z == m.pos.z) then
            local cam = m.area.camera
            ou64_checkpoint_x = m.pos.x
            ou64_checkpoint_y = m.pos.y
            ou64_checkpoint_z = m.pos.z
            ou64_checkpoint_face_angle_y = m.faceAngle.y
            ou64_checkpoint_cam_pos_x = cam.pos.x
            ou64_checkpoint_cam_pos_y = cam.pos.y
            ou64_checkpoint_cam_pos_z = cam.pos.z
            ou64_checkpoint_cam_focus_x = cam.focus.x
            ou64_checkpoint_cam_focus_y = cam.focus.y
            ou64_checkpoint_cam_focus_z = cam.focus.z
            ou64_checkpoint_cam_yaw = cam.yaw
            ou64_checkpoint_area = m.area.index
            ou64_checkpoint_placed = true
            ou64_checkpoint_count = ou64_checkpoint_count + 1
            gPlayerSyncTable[0].checkpoint_count = ou64_checkpoint_count

            play_sound(SOUND_GENERAL_BIG_CLOCK, m.marioObj.header.gfx.cameraToObject)
        else
            play_sound(SOUND_GENERAL_MOVING_IN_SAND, m.marioObj.header.gfx.cameraToObject)
        end
    end
end

-- Determines if checkpoint bind is pressed (accounting for OMM)
--- @param m MarioState
local function bind_cp(m)
    ---@diagnostic disable-next-line: undefined-field
    if _G.OmmEnabled == true then
        return (m.controller.buttonDown & L_TRIG) ~= 0 and
            (m.controller.buttonPressed & D_JPAD) ~= 0
    else
        return (m.controller.buttonPressed & D_JPAD) ~= 0
    end
end

-- Determines if teleport bind is pressed (accounting for OMM)
--- @param m MarioState
local function bind_tp(m)
    ---@diagnostic disable-next-line: undefined-field
    if _G.OmmEnabled == true then
        return (m.controller.buttonDown & L_TRIG) ~= 0 and
            (m.controller.buttonPressed & U_JPAD) ~= 0
    else
        return (m.controller.buttonPressed & U_JPAD) ~= 0
    end
end

hook_event(HOOK_MARIO_UPDATE, function(m)
    if m.playerIndex ~= 0 or
            ou64_flood_active or
            not ou64_settings.enable_checkpoints then
        return
    end

    -- Checkpoint / Teleport on Input
    if ou64_active and
            not ou64_menu_show_menu then
        if bind_cp(m) then
            checkpoint(m)
        elseif bind_tp(m) then
            teleport(m)
        end
    end

    -- If warped to different area, teleport again to correct location.
    if ou64_checkpoint_warping and
            (get_global_timer() - ou64_checkpoint_warp_time) > 1 then
        ou64_checkpoint_warping = false
        teleport(m)
    end
end)

hook_event(HOOK_ON_HUD_RENDER, function()
    local m = gMarioStates[0]
    if not ou64_active or
            ou64_flood_active or
            not ou64_settings.enable_checkpoints or
            ou64_spectator_mode or
            ou64_menu_show_menu or
            (ou64_checkpoint_placed and
                ou64_checkpoint_used) or
            m.action == ACT_END_PEACH_CUTSCENE or
            m.action == ACT_CREDITS_CUTSCENE or
            m.action == ACT_END_WAVING_CUTSCENE or
            obj_get_first_with_behavior_id(id_bhvActSelector) ~= nil then
        return
    end

    -- Checkpoint Tip Parameters
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_ALIASED)
    local tip_text = "Press         while stationary to place a checkpoint"
    local d_pad_texture = d_pad_down
    if ou64_checkpoint_placed and
            not ou64_checkpoint_used then
        tip_text = "Press         to teleport to checkpoint"
        d_pad_texture = d_pad_up
    end
    local tip_scale = 1.5
    local tip_height = 60
    local tip_x_pad = 18
    local tip_y_pad = 2
    local tip_width = djui_hud_measure_text(tip_text) * tip_scale
    local tip_x = djui_hud_get_screen_width() / 2 - (tip_width / 2)
    local tip_y = djui_hud_get_screen_height() - tip_height - 16

    -- Text Parameters
    local text_y_pad = 5

    -- D-PAD Parameters
    local d_pad_x_pad = 79
    local d_pad_y_pad = -2
    local d_pad_scale = 0.5

    -- Render Background
    djui_hud_set_adjusted_color(0, 0, 0, 128)
    djui_hud_render_rect(tip_x - tip_x_pad, tip_y - tip_y_pad, tip_width + (tip_x_pad * 2), tip_height + (tip_y_pad * 2))

    -- Render Checkpoint Tip
    djui_hud_set_adjusted_color(255, 255, 255, 255)
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_print_text(tip_text, tip_x, tip_y + text_y_pad, tip_scale)

    -- Render D-PAD Texture
    djui_hud_render_texture(d_pad_texture, tip_x + d_pad_x_pad, tip_y + d_pad_y_pad, d_pad_scale, d_pad_scale)
end)

hook_event(HOOK_ON_SYNC_VALID, function()
    local m = gMarioStates[0]
    ou64_checkpoint_flag_obj = spawn_non_sync_object(
        id_bhvCheckpointFlag,
        E_MODEL_KOOPA_FLAG,
        m.pos.x, m.pos.y, m.pos.z,
        ---@diagnostic disable-next-line: param-type-mismatch
        nil
    )
end)