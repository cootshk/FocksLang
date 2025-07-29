local copy = require("copy")
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
	---@protected
	type = "focksString",
}
setmetatable(string, {
	__call = function(self, value)
		return self:new(value)
	end,
	__tostring = function(self)
		return self.value
	end,
	__concat = function(self, other)
		return tostring(self) .. tostring(other)
	end,
})
return {
	string = string,
	--- Gets the character at the index of a string
	---@param value str
	---@return string
	get = function(value, index)
		if type(value) == "string" then
			return value:sub(index, index)
		end
		return value.value.sub(index, index)
	end,
	type = function(object)
		if type(object) == "string" then
			return "string"
		elseif type(object) == "table" and object.type then
			return object.type
		else
			return "unknown"
		end
	end,
}
