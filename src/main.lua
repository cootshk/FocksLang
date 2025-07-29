local argparse = require "argparse"
local parse = require "parse"

local parser = argparse("focks", "A simple programming language interpreter.")
parser:argument("file", "The Focks source file to execute.", "main.fock"):args(1)
parser:option("-v --version", "Show the version of Focks."):action("store_true")

local args = parser:parse()

if args.version then
	print "Focks version 1.0.0"
	os.exit(0)
end
local filename = args.file or "main.fock"
local file = io.open(filename)

-- check if file exists
if not file then
	print("Error: File " .. filename .. " not found.")
	os.exit(1)
end

---@type string
local code = "\n" .. file:read "a" .. "\n"
file:close()

print("file start")
for line in code:gmatch "[^\n]+" do
    -- comment markings
	if line ~= "" and line:sub(1,1) ~= "#" then
        -- strip the line here
        parse(line)
    end
end
print("file end")
