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
-- All of these *really* should be moved to a new file
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
	---@return focksBoolean
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
local int = {
	---@param self focksInt
	---@param value integer
	---@return focksInt
	new = function(self, value)
		---@class focksInt
		local ret = copy(self)
		ret.value = value
		return ret
	end,
	---@protected
	---@type integer
	value = 0,
	type = "focksInt",
}
setmetatable(int, {
	---@param value integer
	---@return focksInt
	__call = function(self, value)
		return self:new(value)
	end,
	---@param self focksInt
	---@return string
	__tostring = function(self)
		return tostring(self.value)
	end,
	__tonumber = function(self)
		return tonumber(tostring(self))
	end,
	-- lua(tm)
	-- the number "class" doesn't contain a metatable, so I can't just write a __index implementation
	__add = function (self, other)
		return tonumber(self) + tonumber(other)
	end,
	__sub = function(self, other)
		return tonumber(self) - tonumber(other)
	end,
	__mul = function(self, other)
		return tonumber(self) * tonumber(other)
	end,
	__div = function(self, other)
		return tonumber(self) / tonumber(other)
	end,
	__mod = function (self, other)
		return tonumber(self) % tonumber(other)
	end,
	__pow = function(self, other)
		return tonumber(self) ^ tonumber(other)
	end,
	__unm = function (self)
		return -tonumber(self)
	end,
	__idiv = function(self, other)
		return tonumber(self) // tonumber(other)
	end,
	__band = function(self, other)
		return tonumber(self) & tonumber(other)
	end,
	__bor = function (self, other)
		return tonumber(self) | tonumber(other)
	end,
	__bxor = function (self, other)
		return tonumber(self) ~ tonumber(other)
	end,
	__bnot =function (self)
		return ~tonumber(self)
	end,
	__shl = function (self, other)
		return tonumber(self) << tonumber(other)
	end,
	__shr = function (self, other)
		return tonumber(self) >> tonumber(other)
	end,
	__concat = function (self, other)
		return other .. tonumber(self) -- other might be not an intlike
	end
})
--- Gets the character at the index of a string
---@param value str
---@param index integer
---@return string
local get = function(value, index)
	if type(value) == "string" then
		return value:sub(index, index)
	end
	return value.value.sub(index, index)
end
_G.string.get = get
return {
	string = string,
	get = get,
	type = type,
}
