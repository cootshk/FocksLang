-- All builtins here are exposed to end users

---@type table, string, function
return {
	print = function(arg)
		print(arg.value)
		return arg -- daisy chained
	end,
	set = function(arg)
		return function(arg2)
			MEMORY[arg] = arg2
			return arg2 -- also daisy chained
		end
	end,
	["true"] = true,
	["false"] = false,
	null = nil,
}
