local string_format = string.format

function export_start_time()
    local modFs = mod_fs_get() or mod_fs_create()
    local ou64_metrics_start_time_file = modFs:get_file("ou64-metrics-start-time")
    if ou64_metrics_start_time_file == nil then
        ou64_metrics_start_time_file = modFs:create_file("ou64-metrics-start-time", true)
    end
    if ou64_metrics_start_time_file == nil then return end
    
    _G.ou64_metrics_start_time = get_time()
    ou64_metrics_start_time_file:set_text_mode(false)
    ou64_metrics_start_time_file:rewind()
    ou64_metrics_start_time_file:write_integer(_G.ou64_metrics_start_time, INT_TYPE_U32)

    modFs:save()
end

function export_heartbeat()
    local modFs = mod_fs_get() or mod_fs_create()
    local ou64_metrics_heartbeat_file = modFs:get_file("ou64-metrics-heartbeat")
    if ou64_metrics_heartbeat_file == nil then
        ou64_metrics_heartbeat_file = modFs:create_file("ou64-metrics-heartbeat", true)
    end
    if ou64_metrics_heartbeat_file == nil then return end

    ou64_metrics_heartbeat_file:set_text_mode(false)
    ou64_metrics_heartbeat_file:rewind()
    ou64_metrics_heartbeat_file:write_integer(get_time(), INT_TYPE_U32)

    modFs:save()

    _G.ou64_metrics_heartbeat_last_time = get_global_timer()
end

function export_player_count(player_count)
    local modFs = mod_fs_get() or mod_fs_create()
    local ou64_metrics_player_count_file = modFs:get_file("ou64-metrics-player-count")
    if ou64_metrics_player_count_file == nil then
        ou64_metrics_player_count_file = modFs:create_file("ou64-metrics-player-count", true)
    end
    if ou64_metrics_player_count_file == nil then return end

    ou64_metrics_player_count_file:set_text_mode(false)
    ou64_metrics_player_count_file:rewind()
    ou64_metrics_player_count_file:write_integer(player_count, INT_TYPE_U8)

    _G.ou64_metrics_player_count_last_player_count = player_count
    modFs:save()
end

function export_player_list()
    local modFs = mod_fs_get() or mod_fs_create()
    local ou64_metrics_player_list_file = modFs:get_file("ou64-metrics-player-list")
    if ou64_metrics_player_list_file == nil then
        ou64_metrics_player_list_file = modFs:create_file("ou64-metrics-player-list", true)
    end
    if ou64_metrics_player_list_file == nil then return end

    ou64_metrics_player_list_file:set_text_mode(false)
    ou64_metrics_player_list_file:rewind()
    ou64_metrics_player_list_file:erase(ou64_metrics_player_list_file.size)

    local player_list = {}
    local server_local_index = network_player_from_global_index(0).localIndex
    for i = 0, MAX_PLAYERS - 1 do
        if gNetworkPlayers[i].connected and
                (gServerSettings.headlessServer == 0 or i ~= server_local_index) then
            local player_height = gPlayerSyncTable[i].height ~= nil and gPlayerSyncTable[i].height or 0
            local player_run_time = gPlayerSyncTable[i].run_time ~= nil and gPlayerSyncTable[i].run_time or 0
            local player_checkpoints = gPlayerSyncTable[i].checkpoint_count ~= nil and gPlayerSyncTable[i].checkpoint_count or 0
            local player_action = gPlayerSyncTable[i].action ~= nil and gPlayerSyncTable[i].action or 0
            local player_name = gNetworkPlayers[i].name
            if player_name == string_without_hex(player_name) then
                local cap_color = network_player_get_override_palette_color(gNetworkPlayers[i], CAP)
                local cap_r = 127 + cap_color.r // 2
                local cap_g = 127 + cap_color.g // 2
                local cap_b = 127 + cap_color.b // 2
                player_name = "\\#" .. string_format("%02x", cap_r) .. string_format("%02x", cap_g) .. string_format("%02x", cap_b) .. "\\" .. player_name
            end
            table.insert(player_list, {
                player_name = player_name,
                player_height = player_height,
                player_run_time = player_run_time,
                player_checkpoints = player_checkpoints,
                player_action = player_action,
            })
        end
    end
    table.sort(player_list, function(p1, p2)
        if p1.player_height == p2.player_height then
            return p1.player_name:upper() > p2.player_name:upper() 
        else
            return p1.player_height > p2.player_height
        end
    end)

    for i, entry in ipairs(player_list) do
        ou64_metrics_player_list_file:write_string(entry.player_name)
        ou64_metrics_player_list_file:write_integer(entry.player_height, INT_TYPE_U16)
        ou64_metrics_player_list_file:write_integer(entry.player_run_time, INT_TYPE_U32)
        ou64_metrics_player_list_file:write_integer(entry.player_checkpoints, INT_TYPE_U16)
        ou64_metrics_player_list_file:write_integer(entry.player_action, INT_TYPE_U32)
    end

    modFs:save()

    _G.ou64_metrics_player_list_last_time = get_global_timer()
end
