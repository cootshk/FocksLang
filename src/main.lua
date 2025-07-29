local argparse = require("argparse")
local helpers = require("helpers")
local parse = require("parse")

local parser = argparse("focks", "A simple programming language interpreter.")
parser:argument("file", "The Focks source file to execute.", "main.fock"):args(1)
parser:option("-v --version", "Show the version of Focks."):action("store_true")

local args = parser:parse()

if args.version then
	print("Focks version 1.0.0")
	os.exit(0)
end
local filename = args.file or "main.fock"
local file = io.open(filename)

-- check if file exists
if not file then
	print("Error: File " .. filename .. " not found.")
	os.exit(1)
end

print("file start")
local workingLine = ""
---@param line string
for line in file:lines() do
	while helpers.get(line, 1) == " " do
		-- strip leading spaces
		---@type string
		line = line:sub(2)
	end
	if helpers.get(line, -1) == "\\" then
		-- if the line ends with a backslash, continue to the next line
		workingLine = workingLine .. line:sub(1, -2)
		print("incomplete line, continuing: " .. workingLine)
	-- comment markings
	elseif line ~= "" and helpers.get(line, 1) ~= "#" then
		workingLine = workingLine .. line
		-- strip the line here
		parse(workingLine)
		workingLine = ""
	end
end
print("file end")
file:close()
