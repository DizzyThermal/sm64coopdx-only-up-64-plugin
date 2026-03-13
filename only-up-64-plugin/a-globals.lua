---
-- Leaderboard Packet IDs
---
ou64_packet_ids = {
    -- OU64 Packets
    send_run_data = 0,
    get_leaderboard = 1,
    return_leaderboard = 2,
    clear_leaderboard = 3,
    -- OU64 Flood Packets
    send_flood_run_data = 10,
    get_flood_leaderboard = 11,
    return_flood_leaderboard = 12,
    clear_flood_leaderboard = 13,
}

---
-- Active Mods
---
local function mod_active(mod_name)
    for i in pairs(gActiveMods) do
        if string.find(gActiveMods[i].name, mod_name) then return true end
    end

    return false
end

local function mod_active_exact(mod_name)
    for i in pairs(gActiveMods) do
        if gActiveMods[i].name == mod_name then return true end
    end

    return false
end

ou64_plugin_active = true
ou64_active = mod_active_exact("\\#FAFF20\\Only Up 64") or
        mod_active("Only Up 64 v") or
        mod_active("Only Up 64 %(v")
ou64_flood_active = mod_active("Flood")