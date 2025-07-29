local copy = require("copy")
local builtins = require("builtins")
-- Helpers here are not visible to end users
---@param object any
---@return string
local function type(object)
	if _G.type(object) == "string" then
		return "string"
	elseif _G.type(object) == "table" and object.type then
		return object.type
	else
		return "unknown"
	end
end
local string = {
	---Makes a new string
	---@param self focksString
	---@param value string
	new = function(self, value)
		---@class focksString
		local ret = copy(self)
		ret.value = value
		local metatable = {
			__call = function(self, value)
				local type = type(value)
				if type == "number" then
					return self:call(value)
				elseif type == "string" or type == "focksString" then
					return self .. value
				else
					error("Invalid type for string call: " .. type)
				end
			end,
		}
		setmetatable(metatable, getmetatable(self))
		setmetatable(ret, metatable)
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
local boolean = {
	---Makes a new boolean
	---@param self focksBoolean
	---@param value boolean
	new = function(self, value)
		---@class focksBoolean
		local ret = copy(self)
		ret.value = value
		return ret
	end,
	---@protected
	value = false,
	type = "focksBoolean",
}
setmetatable(boolean, {
	__call = function(self, value)
		return self:new(value)
	end,
	__tostring = function(self)
		return tostring(self.value)
	end,
	__eq = function(self, other)
		if type(other) == "boolean" then
			return self.value == other
		elseif type(other) == "focksBoolean" then
			return self.value == other.value
		else
			return false
		end
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
	type = type,
}
