--- @class ByteWriter

-- Localize for performance.
local string_pack,string_sub,string_unpack,table_insert =
      string.pack,string.sub,string.unpack,table.insert

local ByteWriter = {}
ByteWriter.__index = ByteWriter

function ByteWriter:new()
    --- @class ByteWriter
    local self = {
        buffer = {},
    }

    setmetatable(self, ByteWriter)
    return self
end

-- Class Functions
function ByteWriter:clear()
    if not self.buffer then return end
    for i = #self.buffer, 1, -1 do
        self.buffer[i] = nil
    end
end

function ByteWriter:serialize()
    local output = table.concat(self.buffer)
    ByteWriter:clear()
    return output
end

function ByteWriter:is_empty()
    if not self.buffer then return true end
    return #self.buffer == 0
end

-- Data Functions
function ByteWriter:bool(value)
    table_insert(self.buffer, string_pack("<B", ((value and 1) or 0)))
end

function ByteWriter:u8(value)
    value = value & 0xFF
    table_insert(self.buffer, string_pack("<B", value))
end

function ByteWriter:s8(value)
    value = ((value + 128) & 0xFF) - 128
    table_insert(self.buffer, string_pack("<b", value))
end

function ByteWriter:u16(value)
    value = value & 0xFFFF
    table_insert(self.buffer, string_pack("<H", value))
end

function ByteWriter:s16(value)
    value = ((value + 0x8000) & 0xFFFF) - 0x8000
    table_insert(self.buffer, string_pack("<h", value))
end

function ByteWriter:u32(value)
    value = value & 0xFFFFFFFF
    table_insert(self.buffer, string_pack("<I4", value))
end

function ByteWriter:s32(value)
    value = ((value + 0x80000000) & 0xFFFFFFFF) - 0x80000000
    table_insert(self.buffer, string_pack("<i4", value))
end

function ByteWriter:u64(value)
    value = value & 0xFFFFFFFFFFFFFFFF
    table_insert(self.buffer, string_pack("<I8", value))
end

function ByteWriter:s64(value)
    value = ((value + 0x8000000000000000) & 0xFFFFFFFFFFFFFFFF) - 0x8000000000000000
    table_insert(self.buffer, string_pack("<i8", value))
end

function ByteWriter:f32(value)
    local s = string_pack("<f", value)
    table_insert(self.buffer, s)
    value, _ = string_unpack("<f", s, 1)
    return value
end

function ByteWriter:f64(value)
    table_insert(self.buffer, string_pack("<d", value))
end

function ByteWriter:vec3(value)
    value[1] = self:f32(value[1])
    value[2] = self:f32(value[2])
    value[3] = self:f32(value[3])
end

function ByteWriter:quat(value)
    value[1] = self:f32(value[1])
    value[2] = self:f32(value[2])
    value[3] = self:f32(value[3])
    value[4] = self:f32(value[4])
end

function ByteWriter:string(value)
    value = string_sub(value, 1, 65535)
    local len = #value
    self:u16(len)
    table_insert(self.buffer, value)
end

return ByteWriter
