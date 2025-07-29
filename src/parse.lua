local lineNum = 0
---@type table, string, function
_G.MEMORY = require "builtins"
local builtins = require "builtins"
local helpers = require "helpers"

---Gets the name of the first function
---@param line string
---@return string
local function get_function_name(line)
    return line:gmatch("[^ ]+")()
end
---@param line string
---@return string
local function get_function_args(line)
    return line:sub(#get_function_name(line)+2)
end
---Calls the function, recursively calling input argument functions right to left
---@param func string
---@param argument string
---@return any?
local function call_function(func, argument)
    ---@type any
    local arg = argument
    if argument:sub(1,1) == "\"" then
        local end_quote = argument:find("\"", 2, true)
        if not end_quote then
            error("Unmatched quote!")
        end
        ---@type focksString
        arg = helpers.string(argument:sub(2, end_quote-1))
    end
    MEMORY[func](arg)

end
---@param line string
return function (line)
    lineNum = lineNum + 1
    print("Line " .. lineNum .. " (" .. line .. ").")
    call_function(get_function_name(line), get_function_args(line))
end