local lineNum = 0
---@type table, string, function
_G.MEMORY = require "builtins"

---Gets the name of the first function
---@param line string
---@return string
local function get_function_name(line)
    return line:gmatch("[^ ]+")()
end
---Calls the function, recursively calling input argument functions right to left
---@param func string
---@param argument string
---@return any?
local function call_function(func, argument)
    print("Calling ".. func .. " with " .. argument)

end
---@param line string
return function (line)
    lineNum = lineNum + 1
    print("Line " .. lineNum .. " (" .. line .. ").")
    call_function(get_function_name(line), line:sub(#line-#get_function_name(line)-1))
end