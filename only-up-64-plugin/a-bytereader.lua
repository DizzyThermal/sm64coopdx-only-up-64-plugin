--- @class ByteReader

local string_sub,string_unpack = string.sub,string.unpack

local ByteReader = {}
ByteReader.__index = ByteReader

function ByteReader:new(bytestring)
    --- @class ByteReader
    local self = {
        data   = bytestring,
        offset = 1,
    }
    return setmetatable(self, ByteReader)
end

--- Class Functions ---
local function deserialize(self, fmt)
    local v; v, self.offset = string_unpack(fmt, self.data, self.offset)
    return v
end

function ByteReader:at_end()
    return self.offset >= #self.data
end

--- Data Functions ---
function ByteReader:bool() return self:u8() ~= 0           end  ---@return boolean
function ByteReader:u8()   return deserialize(self, "<B")  end  ---@return integer
function ByteReader:s8()   return deserialize(self, "<b")  end  ---@return integer
function ByteReader:u16()  return deserialize(self, "<H")  end  ---@return integer
function ByteReader:s16()  return deserialize(self, "<h")  end  ---@return integer
function ByteReader:u32()  return deserialize(self, "<I4") end  ---@return integer
function ByteReader:s32()  return deserialize(self, "<i4") end  ---@return integer
function ByteReader:u64()  return deserialize(self, "<I8") end  ---@return integer
function ByteReader:s64()  return deserialize(self, "<i8") end  ---@return integer
function ByteReader:f32()  return deserialize(self, "<f")  end  ---@return number
function ByteReader:f64()  return deserialize(self, "<d")  end  ---@return number

function ByteReader:vec3(out_vec)
    out_vec[1] = deserialize(self, "<f")
    out_vec[2] = deserialize(self, "<f")
    out_vec[3] = deserialize(self, "<f")
end

function ByteReader:quat(out_quat)
    out_quat[1] = deserialize(self, "<f")
    out_quat[2] = deserialize(self, "<f")
    out_quat[3] = deserialize(self, "<f")
    out_quat[4] = deserialize(self, "<f")
end

function ByteReader:string()
    local len = self:u16()
    local str = string_sub(self.data, self.offset, self.offset + len - 1)
    self.offset = self.offset + len
    return str
end

return ByteReader
