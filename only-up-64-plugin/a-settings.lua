-- Loads Only Up 64 Plugin settings from ModFS storage.
function load_plugin_settings()
    -- Create ModFS File and Rewind (return if file does not exist)
    local modFs = mod_fs_get() or mod_fs_create()
    local ou64_settings_file = modFs:get_file("ou64-settings")
    if ou64_settings_file == nil then return end
    ou64_settings_file:set_text_mode(false)
    ou64_settings_file:rewind()

    -- Read in plugin settings
    _G.ou64_plugin_api.settings.enable_moveset = ou64_settings_file:is_eof() and true or (ou64_settings_file:read_integer(INT_TYPE_U8) ~= 0)
    ou64_settings.show_character_height = ou64_settings_file:is_eof() and true or (ou64_settings_file:read_integer(INT_TYPE_U8) ~= 0)
    ou64_settings.show_height_meter = ou64_settings_file:is_eof() and true or (ou64_settings_file:read_integer(INT_TYPE_U8) ~= 0)
    ou64_settings.show_leaderboard = ou64_settings_file:is_eof() and true or (ou64_settings_file:read_integer(INT_TYPE_U8) ~= 0)
    ou64_settings.show_run_timer = ou64_settings_file:is_eof() and true or (ou64_settings_file:read_integer(INT_TYPE_U8) ~= 0)
    ou64_settings.enable_checkpoints = ou64_settings_file:is_eof() and true or (ou64_settings_file:read_integer(INT_TYPE_U8) ~= 0)
    _G.ou64_enable_music = ou64_settings_file:is_eof() and true or (ou64_settings_file:read_integer(INT_TYPE_U8) ~= 0)

    -- Configure Music After Load
    if _G.ou64_enable_music then
        _G.ou64_api.ou64_play_music()
    else
        _G.ou64_api.ou64_stop_music()
    end

    ou64_settings_loaded = true
end

-- Writes out Only Up 64 Plugin settings to ModFS storage.
function save_plugin_settings()
    -- Create ModFS File and Rewind (erase file if previous file exists)
    local modFs = mod_fs_get() or mod_fs_create()
    local ou64_settings_file = modFs:get_file("ou64-settings")
    if ou64_settings_file == nil then
        ou64_settings_file = modFs:create_file("ou64-settings", true)
    end
    if ou64_settings_file == nil then return end
    ou64_settings_file:set_text_mode(false)
    ou64_settings_file:rewind()
    ou64_settings_file:erase(ou64_settings_file.size)

    -- Write out plugin settings
    ou64_settings_file:write_integer(_G.ou64_plugin_api.settings.enable_moveset and 1 or 0, INT_TYPE_U8)
    ou64_settings_file:write_integer(ou64_settings.show_character_height and 1 or 0, INT_TYPE_U8)
    ou64_settings_file:write_integer(ou64_settings.show_height_meter and 1 or 0, INT_TYPE_U8)
    ou64_settings_file:write_integer(ou64_settings.show_leaderboard and 1 or 0, INT_TYPE_U8)
    ou64_settings_file:write_integer(ou64_settings.show_run_timer and 1 or 0, INT_TYPE_U8)
    ou64_settings_file:write_integer(ou64_settings.enable_checkpoints and 1 or 0, INT_TYPE_U8)
    ou64_settings_file:write_integer(_G.ou64_enable_music and 1 or 0, INT_TYPE_U8)

    modFs:save()
end

-- Reset Only Up 64 Plugin settings to default values.
function reset_plugin_settings()
    local music_was_playing = _G.ou64_enable_music

    _G.ou64_plugin_api.settings.enable_moveset = true
    ou64_settings.show_character_height = true
    ou64_settings.show_height_meter = true
    ou64_settings.show_leaderboard = true
    ou64_settings.show_run_timer = true
    ou64_settings.enable_checkpoints = true
    _G.ou64_enable_music = true

    -- Start Music if Not Playing before reset
    if not music_was_playing then
        _G.ou64_api.ou64_play_music()
    end
end

-- Load Plugins
hook_event(HOOK_UPDATE, function()
    if not ou64_settings_loaded then
        load_plugin_settings()
    end

    -- Mod Settings Syncing
    if ou64_settings.enable_music ~= _G.ou64_enable_music then
        ou64_settings.enable_music = _G.ou64_enable_music
    end
    if ou64_settings.enable_moveset ~= _G.ou64_plugin_api.settings.enable_moveset then
        ou64_settings.enable_moveset = _G.ou64_plugin_api.settings.enable_moveset
    end
end)