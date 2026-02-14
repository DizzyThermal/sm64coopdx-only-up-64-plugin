local math_random,string_format = math.random,string.format

-- Server Promotions Configuration
_G.server_promotions_show_promotions = true
_G.server_promotions_server_name = "\\#019369\\Dizzy's Abyss\\#ffffff\\"
_G.server_promotions_interval_sec = 240
_G.server_promotions_motd_delay_sec = 4
_G.server_promotions_messages = {
    "\\#FAFF20\\Please report Flood bugs to \\#E01F2D\\DizzyThermal\\#FAFF20\\!",
--    "\\#faff20\\Leaderboard: \\#019369\\dizzysabyss.com\\#ffffff\\",
}
_G.server_promotions_connect_time = get_time()
_G.server_promotions_motd_message = string_format("Welcome to %s - Enjoy Your Stay!", _G.server_promotions_server_name)
_G.server_promotions_motd_shown = false
_G.server_promotions_last_promotion_time = _G.server_promotions_connect_time + _G.server_promotions_motd_delay_sec
_G.server_promotions_last_message_index = math_random(1, #(_G.server_promotions_messages))

-- Server Promotions Commands
hook_chat_command("server-promotions", "- Toggles server promotions", function()
    _G.server_promotions_show_promotions = not _G.server_promotions_show_promotions
    if _G.server_promotions_show_promotions then
        djui_popup_create("Server Promotions: \n\\#00C7FF\\Enabled", 1)
    else
        djui_popup_create("Server Promotions: \n\\#A02200\\Disabled", 1)
    end
    return true
end)

-- Server Promotions Functions
function render_promotions()
    if not _G.server_promotions_motd_shown
      and get_time() - _G.server_promotions_connect_time > _G.server_promotions_motd_delay_sec then
        -- Show Server MOTD (Connect Message)
        djui_chat_message_create(_G.server_promotions_motd_message)
        _G.server_promotions_motd_shown = true
    end
    if _G.server_promotions_show_promotions then
        -- Show a random server promotion (never shows two in a row)
        if get_time() - _G.server_promotions_last_promotion_time > _G.server_promotions_interval_sec then
            _G.server_promotions_last_promotion_time = get_time()
            random_index = math_random(1, #(_G.server_promotions_messages))
            while random_index == _G.server_promotions_last_message_index and #(_G.server_promotions_messages) > 1 do
               random_index = math_random(1, #(_G.server_promotions_messages))
            end
            _G.server_promotions_last_message_index = random_index
            djui_chat_message_create(_G.server_promotions_messages[_G.server_promotions_last_message_index])
        end
    end
end
