local copy = require "copy"
-- Helpers here are not visible to end users
local string = {
    ---Makes a new string
    ---@param self focksString
    ---@param value string
    new = function(self, value)
        ---@class focksString
        local ret = copy(self)
        ret.value = value
        return ret
    end,
    ---@protected
    ---@type string
    value = "",
    ---@protected
    call = function(self, index)
        return self.value:sub(index, index)
    end,
}
setmetatable(string, {__call=function(self, value) return self:new(value) end})
return {
    string = string
}