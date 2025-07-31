local copy = require("copy")
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
		local metatable = copy(getmetatable(self))
		metatable.__call = function(self, value)
			local type = type(value)
			if type == "number" then
				return self:call(value)
			elseif type == "string" or type == "focksString" then
				return self .. value
			else
				error("Invalid type for string call: " .. type)
			end
		end
		setmetatable(ret, metatable)
		return ret
	end,
	---@protected
	---@type string
	value = "",
	---@protected
	---@param self focksString
	---@param index int
	call = function(self, index)
		if type(index) == "focksInt" then
			index = index.value
		end
		return self.value:sub(index, index)
	end,
	---@protected
	---@type focksObjectTypes
	type = "focksString",
}
setmetatable(string, {
	__call = string.new,
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
	---@protected
	---@type focksObjectTypes
	type = "focksBoolean",
}
setmetatable(boolean, {
	__call = boolean.new,
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
		local metatable = copy(getmetatable(ret))
		metatable.__call = function(...)
			error("You cannot call an integer!", 2)
		end
		setmetatable(metatable, getmetatable(ret))
		setmetatable(ret, metatable)
		return ret
	end,
	---@protected
	---@type integer
	value = 0,
	---@type focksObjectTypes
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

local func = {
	---@param self focksFunction
	---@param value function
	---@return focksFunction
	new = function(self, value)
		---@class focksFunction
		local ret = copy(self)
		ret.value = value
		local metatable = copy(getmetatable(ret))
		metatable.__call = function(self, ...)
			return self.value(...)
		end
		setmetatable(metatable, getmetatable(ret))
		setmetatable(ret, metatable)
		return ret
	end,
	---@protected
	value = function(...)
		error("Not initialized!\nThis is a bug with Focks, you should never be seeing this!", 2)
	end,
	---@protected
	type = "focksFunction",
}
setmetatable(func, {
	__call = func.new,
})

---@param value focksObject|string|integer|boolean|function
---@return focksObject
local function object(value)
	if type(value) == "string" then
		return string(value)
	elseif type(value) == "number" then
		return int(value)
	elseif type(value) == "function" then
		return func(value)
	elseif type(value) == "boolean" then
		return boolean(value)
	elseif type(value):match("focks") then
		---@type focksObject
		return value
	else
		error("Invalid focks object type "..type(value))
	end
end

return {
	string = string,
	int = int,
	boolean = boolean,
	func = func,
	object = object
}
