local function bhv_checkpoint_flag_init(obj)
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj.oAnimations = gObjectAnimations.koopa_flag_seg6_anims_06001028
    obj_init_animation(obj, 0)
    cur_obj_scale(0.2)
    cur_obj_hide()
end

local function bhv_checkpoint_flag_loop(obj)
    if not _G.ou64_enable_checkpoints or
            not _G.ou64_checkpoint_placed or
            gMarioStates[0].area.index ~= _G.ou64_checkpoint_area then
        cur_obj_hide()
    else
        obj_set_pos(obj, _G.ou64_checkpoint_x, _G.ou64_checkpoint_y, _G.ou64_checkpoint_z)
        cur_obj_unhide()
    end
end

id_bhvCheckpointFlag = hook_behavior(nil, OBJ_LIST_LEVEL, true, bhv_checkpoint_flag_init, bhv_checkpoint_flag_loop)

function checkpoint_text()
    return "Press DPAD-DOWN while stationary to place a checkpoint"
end

function teleport_text()
    return "Press DPAD-UP to teleport to checkpoint"
end

function reset_checkpoints()
    _G.ou64_checkpoint_x = 0
    _G.ou64_checkpoint_y = 0
    _G.ou64_checkpoint_z = 0
    _G.ou64_checkpoint_area = 1
    _G.ou64_checkpoint_placed = false
    _G.ou64_checkpoint_used = false
    _G.ou64_checkpoint_count = 0
    gPlayerSyncTable[0].checkpoint_count = 0
end
