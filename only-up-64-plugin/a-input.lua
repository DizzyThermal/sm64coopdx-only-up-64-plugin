function bind_cp(m)
    if _G.OmmEnabled == true then
        return (m.controller.buttonDown & L_TRIG) ~= 0 and (m.controller.buttonPressed & D_JPAD) ~= 0
    else
        return (m.controller.buttonPressed & D_JPAD) ~= 0
    end
end

function bind_tp(m)
    if _G.OmmEnabled == true then
        return (m.controller.buttonDown & L_TRIG) ~= 0 and (m.controller.buttonPressed & U_JPAD) ~= 0
    else
        return (m.controller.buttonPressed & U_JPAD) ~= 0
    end
end

function bind_debug(m)
    return (m.controller.buttonPressed & R_JPAD) ~= 0
end
