local copy = require("copy")
local builtins = require("builtins")
-- Helpers here are not visible to end users
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
		assert(value ~= nil, "You must pass a value to an integer!")
		---@class focksInt
		local ret = copy(self)
		ret.value = value
		local metatable = {
			__call = function(...)
				error("You cannot call an integer!", 2)
			end,
		}
		setmetatable(metatable, getmetatable(ret))
		setmetatable(ret, metatable)
		return ret
	end,
	---@protected
	---@type integer
	value = nil,
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
	__add = function(self, other)
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
	__mod = function(self, other)
		return tonumber(self) % tonumber(other)
	end,
	__pow = function(self, other)
		return tonumber(self) ^ tonumber(other)
	end,
	__unm = function(self)
		return -tonumber(self)
	end,
	--[[ Not implemented in LuaJIT
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
	]]
	__concat = function(self, other)
		return tostring(self) .. tostring(other) -- other might be not an intlike
	end,
	---@param self num
	---@param other num
	---@return boolean
	__eq = function(self, other)
		if type(self):sub(1, 5) == "focks" then
			---@type integer
			self = self.value
		end
		if type(other):sub(1, 5) == "focks" then
			---@type integer
			other = other.value
		end
		return self == other
	end,
	__lt = function(self, other)
		return tonumber(self) < tonumber(other)
	end,
	__le = function(self, other)
		return tonumber(self) <= tonumber(other)
	end,
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
	int = int,
	boolean = boolean,
	get = get,
}
