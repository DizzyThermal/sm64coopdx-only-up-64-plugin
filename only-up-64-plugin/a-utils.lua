function djui_hud_set_adjusted_color(r, g, b, a)
    local multiplier = 1
    if is_game_paused() then multiplier = 0.5 end
    djui_hud_set_color(r * multiplier, g * multiplier, b * multiplier, a)
end

function get_highest_player_height()
    -- For Flood Support
    local highest_height = -0x8000
    for i = 0, MAX_PLAYERS - 1 do
        if gNetworkPlayers[i].connected and gMarioStates[i].pos.y > highest_height then
            highest_height = gMarioStates[i].pos.y
        end
    end

    return highest_height
end

function limit_angle(a)
    return (a + 0x8000) % 0x10000 - 0x8000
end

function mod_active(mod_name)
    for i in pairs(gActiveMods) do
        if string.find(gActiveMods[i].name, mod_name) then return true end
    end

    return false
end

-- Menu Functions --
function close_menu()
    MENU_INDEX = 0
    MENU_SELECTION_INDEX = 0
    RETURNED_NEUTRAL = true
    IN_PRACTICE_MENU = false
end

function get_menu_size()
    local menuSize = 0

    for i, entry in ipairs(PRACTICE_MENU) do
        if entry.menuIndex == MENU_INDEX then
            menuSize = menuSize + 1
        end
    end

    return menuSize + 1
end

function get_menu_item()
    for i, entry in ipairs(PRACTICE_MENU) do
        wLevel = entry.level
        wArea = entry.area
        wAct = entry.act
        wNode = entry.node

        if wLevel == WARP_LEVEL
            and wArea == WARP_AREA
            and wAct == WARP_ACT
            and wNode == WARP_NODE then
            return entry
        end
    end

    return nil
end

function last_warp_string()
    local lastWarpString = ""
    local menuItem = get_menu_item()
    if menuItem ~= nil then
        lastWarpString = " [" .. menuItem.text .. "]"
    end

    return lastWarpString
end

function warp_from_menu()
    local menu_size = get_menu_size()

    for i, entry in ipairs(PRACTICE_MENU) do
        if entry.menuIndex == MENU_INDEX
          and entry.menuSelectionIndex == MENU_SELECTION_INDEX % menu_size then
            WARP_LEVEL = entry.level
            WARP_AREA = entry.area
            WARP_ACT = entry.act
            WARP_NODE = entry.node

            if WARP_LEVEL ~= nil and WARP_AREA ~= nil and WARP_ACT ~= nil and WARP_NODE ~= nil then
                warp_to_warpnode(WARP_LEVEL, WARP_AREA, WARP_ACT, WARP_NODE)
            end
        end
    end
end

function render_practice_menu()
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    local menu_size = get_menu_size()

    -- Menu Items
    local menuTexts = {}
    local selectionIndex = 0
    for i, entry in ipairs(PRACTICE_MENU) do
        local menuIndex = entry.menuIndex
        if menuIndex == MENU_INDEX then
            table.insert(menuTexts, entry.text)
            selectionIndex = MENU_SELECTION_INDEX % menu_size
        end
    end

    -- Back/Exit
    backText = "Back"
    if MENU_INDEX == 0 then
        backText = "Exit"
    end

    local scale = 1
    local width = 400
    local x = (djui_hud_get_screen_width() - width) * 0.5

    local y = MENU_ITEM_HEIGHT * 2
    local backOffset = menu_size + 1
    local height = MENU_ITEM_HEIGHT * backOffset

    djui_hud_set_adjusted_color(0, 0, 0, 180)
    djui_hud_render_rect(x - 12, y, width + 24, y + height)
    djui_hud_set_adjusted_color(255, 255, 255, 255)

    -- Print Menu Items
    for i, entry in ipairs(menuTexts) do
        djui_hud_print_text(entry, x + 20, y + (MENU_ITEM_HEIGHT * i), scale)
    end
    -- Print Back/Exit
    djui_hud_print_text(backText, x + 20, y + (MENU_ITEM_HEIGHT * backOffset), scale)

    -- Draw Selector
    local backPad = 0
    if selectionIndex >= menu_size - 1 then
        backPad = MENU_ITEM_HEIGHT
    end
    djui_hud_print_text(">", x, y + (MENU_ITEM_HEIGHT * (selectionIndex + 1)) + backPad, scale)
end

function check_menu_input(m)
    if not OU_ACTIVE or OU_FLOOD_ACTIVE then return end

    if not is_game_paused() and IN_PRACTICE_MENU then
        if m.controller.stickY > 60 and RETURNED_NEUTRAL then
            RETURNED_NEUTRAL = false
            MENU_SELECTION_INDEX = MENU_SELECTION_INDEX - 1
        elseif m.controller.stickY < -60 and RETURNED_NEUTRAL then
            RETURNED_NEUTRAL = false
            MENU_SELECTION_INDEX = MENU_SELECTION_INDEX + 1
        elseif (m.controller.buttonPressed & A_BUTTON) ~= 0 then
            local menu_size = get_menu_size()
            local selectionIndex = MENU_SELECTION_INDEX % menu_size

            print(menu_size .. " : " .. selectionIndex)
            if MENU_INDEX == 0 then
                -- Main Menu
                if selectionIndex == (menu_size - 1) then
                    -- Exit
                    close_menu()
                elseif selectionIndex == 0 then
                    -- Last Warp
                    if WARPED then
                        if WARP_LEVEL ~= nil and WARP_AREA ~= nil and WARP_ACT ~= nil and WARP_NODE ~= nil then
                            warp_to_warpnode(WARP_LEVEL, WARP_AREA, WARP_ACT, WARP_NODE)
                        end
                    end
                    close_menu()
                else
                    -- Enter Submenu
                    MENU_INDEX = selectionIndex
                    MENU_SELECTION_INDEX = 0
                end
            else
                -- Sub Menu
                if selectionIndex == (menu_size - 1) then
                    -- Go Back
                    MENU_INDEX = 0
                    MENU_SELECTION_INDEX = 0
                else
                    -- Last Warp
                    warp_from_menu()
                    close_menu()
                end
            end
        elseif (m.controller.buttonPressed & B_BUTTON) ~= 0 then
            if MENU_INDEX == 0 then
                close_menu()
            else
                MENU_INDEX = 0
                MENU_SELECTION_INDEX = 0
            end
        end
    elseif not is_game_paused() then
        if (m.controller.buttonPressed & X_BUTTON) ~= 0 then
            if not IN_PRACTICE_MENU then
                PracticeMenu()
            else
                close_menu()
            end
        end
    end
    if IN_PRACTICE_MENU
      and m.controller.stickY > -60
      and m.controller.stickY < 60 then
        RETURNED_NEUTRAL = true
    end
end