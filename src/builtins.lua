-- All builtins here are exposed to end users
local objects = require("objects")
local old = require("globals")

---@type table, string, focksObject
local memory = {
-- GENERAL
	---@param arg focksObject
	print = function(arg)
		print(arg.value)
	end,
	---@param arg focksObject
	write = function(arg)
		io.write(arg.value)
	end,
	---@param arg focksObject
	---@return str
	read = function(arg)
		_G.MEMORY.write(arg)
		---@type focksString
		local input = io.read()
		if not input then
			error("Error reading input!")
		end
		return objects.string(input)
	end,
	---@param arg focksString
	set = function(arg)
		if not type(arg):match("tring", 2) then
			error("You can only use strings as variable names!")
		end
		---@param arg2 focksObject
		return function(arg2)
			local old_value
			pcall(function()
				old_value = MEMORY[arg.value]
			end)
			MEMORY[arg.value] = arg2
			return old_value
		end
	end,
	get = function(arg1)
		return MEMORY[arg1.value]
	end,
-- STRING
	str = function(arg)
		return tostring(arg) or error("Invalid string: " .. tostring(arg))
	end,
	concat = function(arg1)
		return function(arg2)
			return arg1 .. arg2
		end
	end,
	---@param arg1 focksString
	---@return function
	contains = function(arg1)
		---@param arg2 focksObject
		---@return boolean
		return function(arg2)
			if type(arg1) == "focksString" then
				if string.find(arg1.value, tostring(arg2), 1, true) then
					return true
				end
			end
			return false
		end
	end,
	ansi = {
		esc = "\x1b",
		-- format
		bold = "\x1b[1m",
		unbold = "\x1b[22m",
		dim = "\x1b[2m",
		undim = "\x1b[22m", -- ansi thing
		italic = "\x1b[3m",
		unitalic = "\x1b[23m",
		underline = "\x1b[4m",
		uline = "\x1b[4m", -- alias
		ununderline = "\x1b[24m",
		nouline = "\x1b[24m",
		blink = "\x1b[5m",
		unblink = "\x1b[25m",
		noblink = "\x1b[25m",
		inverse = "\x1b[7m",
		uninverse = "\x1b[27m",
		hidden = "\x1b[8m",
		invisible = "\x1b[8m",
		unhidden = "\x1b[28m",
		visible = "\x1b[28m",
		strikethrough = "\x1b[9m",
		unstrikethrough = "\x1b[29m",
		-- foreground
		black = "\x1b[;30m",
		red = "\x1b[;31m",
		green = "\x1b[;32m",
		yellow = "\x1b[;33m",
		blue = "\x1b[;34m",
		magenta = "\x1b[;35m",
		cyan = "\x1b[;36m",
		white = "\x1b[;37m",
		default = "\x1b[;39m",
		-- background
		black_bg = "\x1b[;40m",
		bg_black = "\x1b[;400m",
		red_bg = "\x1b[;41m",
		bg_red = "\x1b[;41m",
		green_bg = "\x1b[;42m",
		bg_green = "\x1b[;42m",
		yellow_bg = "\x1b[;43m",
		bg_yellow = "\x1b[;43m",
		blue_bg = "\x1b[;44m",
		bg_blue = "\x1b[;44m",
		magenta_bg = "\x1b[;45m",
		bg_magenta = "\x1b[;45m",
		cyan_bg = "\x1b[;46m",
		bg_cyan = "\x1b[;46m",
		white_bg = "\x1b[;47m",
		bg_white = "\x1b[;47m",
		default_bg = "\x1b[;49m",
		bg_default = "\x1b[;49m",
	},
-- INTEGER
	int = function(arg)
		return tonumber(arg) or error("Invalid integer: " .. tostring(arg))
	end,
	---@param arg1 focksInt
	add = function(arg1)
		---@param arg2 focksInt
		---@return integer
		return function(arg2)
			return arg1 + arg2
		end
	end,
	---@param arg1 focksInt
	sub = function(arg1)
		---@param arg2 focksInt
		---@return integer
		return function(arg2)
			return arg1 - arg2
		end
	end,
	mul = function(arg1)
		---@param arg2 focksInt
		---@return integer
		return function(arg2)
			return arg1 * arg2
		end
	end,
	div = function(arg1)
		---@param arg2 focksInt
		---@return integer
		return function(arg2)
			if arg2 == 0 then
				error("Division by zero!")
			end
			return math.floor(arg1 / arg2)
		end
	end,
-- RANDOM
	random = {
		---@param arg1 focksInt
		---@return function
		int = function(arg1)
			---@param arg2 focksInt
			---@return integer
			return function(arg2)
				log("Random # between "..arg1.value.." and "..arg2.value)
				return math.random(arg1.value, arg2.value)
			end
		end,
		choice = function(arg)
			return arg.value[math.random(1, #arg.value)]
		end,
	},
-- LITERALS
	-- these are also literals in lua lmao
	["true"] = true,
	["false"] = false,
	_VERSION = VERSION,
	_LUA_VERSION = _VERSION,
}
local out = {}
setmetatable(out, {
	---@param self table
	---@param key str
	__index = function(self, key)
		if type(key) == "string" then
			error("Variable "..key.." is not defined!")
		elseif type(key) == "focksString" then
			return self[key.value]
		end
	end,
	__newindex = function (self, k, v)
		rawset(self, k, objects.object(v))
	end
})
local parse_table
---Recursively adds items to the memory table from table.
---@param table table The table to read items from
---@param appended_name string? The name to append to table keys (default: "")
function parse_table(table, appended_name)
	appended_name = appended_name or ""
	for k, v in pairs(table) do
		if type(v) == "table" then
			parse_table(v, "."..k)
		else
			out[(appended_name.."."..k):sub(2)] = v
		end
	end
end
parse_table(memory)
return out
