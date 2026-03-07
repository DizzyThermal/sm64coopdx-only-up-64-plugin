local COL_BED = smlua_collision_util_get("bed_collision")

local function bhv_bed_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oCollisionDistance = 150
    o.collisionData = COL_BED
    obj_scale(o, 0.85)
end
local function bhv_bed_loop(o)
    local m = nearest_mario_state_to_object(o)
    if m.marioObj.platform == o then
        m.vel.y = o.oBedStrength
        set_mario_action(m, ACT_VERTICAL_WIND, 0)
    end
    load_object_collision_model()
end
id_bhvBed = hook_behavior(nil, OBJ_LIST_SURFACE, true, bhv_bed_init, bhv_bed_loop)

hook_event(HOOK_ON_WARP, function()
    if not ou64_flood_active then
        ou64_warped = true
    elseif ou64_settings.enable_arcade_mode then
        -- Spawn Beds
        local area = m.area.index
        for i, bed in ipairs(ou64_arcade_beds[area]) do
            spawn_non_sync_object(
                id_bhvBed,
                E_MODEL_BED,
                bed.x, bed.y, bed.z,
                --- @param o Object
                function(o)
                    o.oFaceAnglePitch = 0
                    o.oFaceAngleYaw = bed.a
                    o.oFaceAngleRoll = 0
                    ---@diagnostic disable-next-line: inject-field
                    o.oBedStrength = bed.strength
                end
            )
        end
    end

    return true
end)