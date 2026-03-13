
local COL_BED = smlua_collision_util_get("bed_collision")
local E_MODEL_BED = smlua_model_util_get_id("bed_geo")

define_custom_obj_fields({
    oBedStrength = "s32",
})
local ou64_arcade_beds = {
    [1] = {
        { x = 6399, y = -16402, z = -4552, a = 0x0000, strength = 110 },    -- Start
        { x = 2306, y = -15690, z = -1022, a = -0x2000, strength = 200 },   -- Bridge Pillar
        { x = -563, y = -11140, z = -1445, a = -0x2000, strength = 165 },   -- Fountain
        { x = -4354, y = -9898, z = -2013, a = -0x2000, strength = 145 },   -- Castle
        { x = -3534, y = -6675, z = 134, a = 0x2000, strength = 150 },      -- Ice Platform (Upper)
        { x = -5174, y = -7135, z = -828, a = 0x4000, strength = 100 },     -- Ice Platform (Lower)
        { x = -2318, y = -4128, z = 972, a = 0x0000, strength = 145 },      -- HMC Pillars
        { x = -1872, y = -1815, z = 2170, a = 0x0000, strength = 125 },     -- Pyramid (Bottom)
        { x = -1671, y = -515, z = 3973, a = 0x0000, strength = 135 },      -- Pyramid (Top)
        { x = -1162, y = 1690, z = 5325, a = -0x2000, strength = 200 },     -- Pyramid Pillar
        { x = -1391, y = 5260, z = 1715, a = 0x0000, strength = 189 },      -- Air
        { x = -2844, y = 8000, z = -1501, a = 0x0000, strength = 162 },     -- "M"
        { x = -3575, y = 11660, z = -4242, a = 0x0000, strength = 190 },    -- Whomp's Platform
        { x = -1224, y = 15295, z = -790, a = 0x0000, strength = 140 },     -- Star
    },
    [2] = {
        { x = 1844, y = -15400, z = -1836, a = -0x6000, strength = 175 },   -- Start to Triforce
        { x = -3234, y = -13750, z = -3216, a = -0x2000, strength = 190 },  -- Triforce to Bongo
        { x = -2609, y = -11500, z = 1847, a = 0x4000, strength = 90 },     -- Bongo to Bongo
        { x = 2310, y = -9120, z = -841, a = -0x6000, strength = 130 },     -- Bongo to N64
        { x = 1831, y = -7235, z = -2707, a = -0x6000, strength = 140 },    -- N64 to Moon
        { x = -3772, y = -3420, z = -3564, a = 0x0000, strength = 160 },    -- Sword to Stone
        { x = -3611, y = 0, z = 541, a = 0x0000, strength = 210 },          -- Stone to Tree
        { x = 539, y = 4540, z = 2180, a = 0x0000, strength = 200 },        -- Tree to Goron
        { x = 3154, y = 6750, z = -3912, a = 0x0000, strength = 80 },       -- Goron to Platform
        { x = -1045, y = 7200, z = -4200, a = 0x0000, strength = 150 },     -- Platform to Platform
        { x = -4666, y = 8900, z = -330, a = 0x0000, strength = 80 },       -- Platform to Cave
        { x = -5375, y = 9500, z = 1700, a = 0x0000, strength = 110 },      -- Cave to Majora
        { x = -3851, y = 10950, z = 52, a = 0x0000, strength = 130 },       -- Majora to Chest
        { x = -5000, y = 13680, z = -1265, a = 0x0000, strength = 110 },    -- Chest to Chest
    },
    [3] = {
        { x = -4642, y = -16150, z = 1939, a = 0x4000, strength = 170 },    -- Start
        { x = -2409, y = -14550, z = 4372, a = 0x4000, strength = 120 },    -- Bulbasaur
        { x = -176, y = -13026, z = 5219, a = -0x2000, strength = 160 },    -- Bulbasaur to Metapod
        { x = 1756, y = -10546, z = 4099, a = 0x0000, strength = 230 },     -- Metapod to Onyx
        { x = -3322, y = -7129, z = 294, a = 0x2000, strength = 90 },       -- Onyx
        { x = -3312, y = -6838, z = -1994, a = -0x2000, strength = 120 },   -- Onyx
        { x = -1304, y = -5601, z = -3692, a = 0x2000, strength = 240 },    -- Onyx to Squirtle
        { x = 3422, y = -600, z = -916, a = 0x0000, strength = 200 },       -- Squirtle to Dratini
        { x = 2855, y = 2400, z = 2292, a = 0x0000, strength = 160 },       -- Dratini to Parasect
        { x = 1303, y = 5590, z = 5917, a = 0x0000, strength = 160 },       -- Parasect to Vaporeon
        { x = -1171, y = 8200, z = 5578, a = 0x0000, strength = 160 },      -- Vaporeon
        { x = -3537, y = 10767, z = 5144, a = 0x0000, strength = 70 },      -- Vaporeon to Porygon
        { x = -5017, y = 10889, z = 5085, a = 0x0000, strength = 70 },      -- Porygon
        { x = -6559, y = 12570, z = 5151, a = 0x0000, strength = 185 },     -- Porygon to Nidoqueen
    },
    [4] = {
        { x = -4279, y = -15199, z = 1504, a = 0x0000, strength = 100 },    -- Start
        { x = -3387, y = -14150, z = 928, a = 0x0000, strength = 160 },     -- Tower
        { x = -4171, y = -9529, z = -1195, a = 0x2000, strength = 160 },    -- Saffron Towers
        { x = -2061, y = -5952, z = -1439, a = 0x4000, strength = 140 },    -- Saffron Towers to Captain Falcon
        { x = 421, y = -4769, z = -281, a = 0x0000, strength = 160 },       -- Captain Falcon
        { x = 1037, y = -1970, z = 3151, a = 0x0000, strength = 140 },      -- Captain Falcon to Metal Cavern
        { x = 1791, y = -30, z = 4949, a = 0x4000, strength = 220 },        -- Metal Cavern to Great Fox
        { x = 4626, y = 3654, z = 3058, a = 0x2000, strength = 270 },       -- Great Fox to Barrel
        { x = -863, y = 7901, z = -1900, a = 0x0000, strength = 160 },      -- Barrel to Fan
        { x = -2470, y = 10428, z = -3614, a = 0x0000, strength = 230 },    -- Fan to Luigi
    },
    [5] = {},
    [6] = {},
    [7] = {},
    [8] = {},
}

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
    if ou64_flood_active and
            ou64_settings.enable_arcade_mode then
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