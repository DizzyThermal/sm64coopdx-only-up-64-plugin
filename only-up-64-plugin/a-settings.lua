function load_plugin_settings()
    local modFs = mod_fs_get() or mod_fs_create()
    local ou64_settings_file = modFs:get_file("ou64-settings")
    if ou64_settings_file == nil then return end

    ou64_settings_file:set_text_mode(false)
    ou64_settings_file:rewind()

    _G.ou64_enable_moveset = (ou64_settings_file:read_integer(INT_TYPE_U8) ~= 0)
    _G.ou64_show_character_height = (ou64_settings_file:read_integer(INT_TYPE_U8) ~= 0)
    _G.ou64_show_height_meter = (ou64_settings_file:read_integer(INT_TYPE_U8) ~= 0)
    _G.ou64_show_leaderboard = (ou64_settings_file:read_integer(INT_TYPE_U8) ~= 0)
    _G.ou64_show_run_timer = (ou64_settings_file:read_integer(INT_TYPE_U8) ~= 0)
end

function save_plugin_settings()
    local modFs = mod_fs_get() or mod_fs_create()
    local ou64_settings_file = modFs:get_file("ou64-settings")
    if ou64_settings_file == nil then
        ou64_settings_file = modFs:create_file("ou64-settings", true)
    end
    if ou64_settings_file == nil then return end

    ou64_settings_file:set_text_mode(false)
    ou64_settings_file:rewind()
    ou64_settings_file:erase(ou64_settings_file.size)

    ou64_settings_file:write_integer(_G.ou64_enable_moveset and 1 or 0, INT_TYPE_U8)
    ou64_settings_file:write_integer(_G.ou64_show_character_height and 1 or 0, INT_TYPE_U8)
    ou64_settings_file:write_integer(_G.ou64_show_height_meter and 1 or 0, INT_TYPE_U8)
    ou64_settings_file:write_integer(_G.ou64_show_leaderboard and 1 or 0, INT_TYPE_U8)
    ou64_settings_file:write_integer(_G.ou64_show_run_timer and 1 or 0, INT_TYPE_U8)

    modFs:save()
end

function reset_plugin_settings()
    _G.ou64_enable_moveset = true
    _G.ou64_show_character_height = true
    _G.ou64_show_height_meter = true
    _G.ou64_show_leaderboard = true
    _G.ou64_show_run_timer = true
end
