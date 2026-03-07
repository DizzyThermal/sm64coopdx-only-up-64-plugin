-- Localize for performance.
local math_floor,string_format,string_gmatch =
      math.floor,string.format,string.gmatch

function standing_on_start_timer(m)
    if m.playerIndex ~= 0 then
       return false
    end

    return m.area.index == 1 and
        not ou64_checkpoint_warping and
        not ou64_spectator_warping and
        m.pos.x > 5000 and m.pos.x < 6300 and
        m.pos.y > -16270 and m.pos.y < -15000 and
        m.pos.z > -6300 and m.pos.z < -4900
end

function standing_on_end_timer(m)
    if m.playerIndex ~= 0 then
       return false
    end

    return m.area.index == 0 and
        m.pos.x > -2200 and m.pos.x < -1900 and
        m.pos.y > 13250 and
        m.pos.z > -1400 and m.pos.z < -1000
end

function time_string_to_msec(time_string)
    local time_parts = {}
    for part in string_gmatch(time_string, "([^:]+)") do
        table.insert(time_parts, part)
    end

    local hours, minutes, seconds_millis
    if #time_parts == 3 then
        -- HH:MM:SS.ms
        hours = tonumber(time_parts[1])
        minutes = tonumber(time_parts[2])
        seconds_millis = time_parts[3]
    elseif #time_parts == 2 then
        -- MM:SS.ms
        hours = 0
        minutes = tonumber(time_parts[1])
        seconds_millis = time_parts[2]
    else
        -- Invalid Format
        return nil
    end

    local second_parts = {}
    for part in string_gmatch(seconds_millis, "([^%.]+)") do
        table.insert(second_parts, part)
    end

    local seconds = tonumber(second_parts[1])
    local millis = tonumber(second_parts[2])

    return (hours * 3600000) + (minutes * 60000) + (seconds * 1000) + millis
end

function delta_to_sec(delta)
    return math_floor(delta / 30)
end

function delta_to_msec(delta)
    return math_floor(delta / 30 * 1000)
end

function format_msec(total_msec)
    local total_seconds = math_floor(total_msec / 1000)
    local millis = total_msec % 1000
    local seconds = total_seconds % 60
    local total_minutes = math_floor(total_seconds / 60)
    local minutes = total_minutes % 60
    local hours = math_floor(total_minutes / 60)

    if hours > 0 then
        return string_format("%d:%02d:%02d.%02d", hours, minutes, seconds, millis)
    else
        return string_format("%d:%02d.%02d", minutes, seconds, millis)
    end
end

function format_time(delta)
    local total_seconds = delta / 30

    local hours = math_floor(total_seconds / 3600)
    local minutes = math_floor((total_seconds % 3600) / 60)
    local seconds = math_floor(total_seconds % 60)
    local millis = math_floor((total_seconds % 1) * 100)
    if hours > 0 then
        return string_format("%d:%02d:%02d.%02d", hours, minutes, seconds, millis)
    else
        return string_format("%02d:%02d.%02d", minutes, seconds, millis)
    end
end