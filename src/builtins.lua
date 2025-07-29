---@type table, string, function
return {
    print = function(arg)
        print(arg)
    end,
    set = function(arg)
        return function(arg2)
            MEMORY[arg] = arg2
        end
    end,
}