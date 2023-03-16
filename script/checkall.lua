local filepath = "../cn/localisation/english"
local scriptpath = "."

local filelist = require "filelist"

local list = filelist.filelist()

local check_text = assert(loadfile(scriptpath .. "/check.lua"))()

local function check(filename)
	filename = string.format("%s/%s", filepath, filename)
	local f = io.open(filename, "rb")
	if not f then
		print("Can't open " .. filename)
		return
	end
	local text = f:read "a"
	f:close()
	local err = check_text(text)
	if err then
		print("ERR:", filename, err)
	else
		print("OK:", filename)
	end
end

for _, filename in ipairs(list) do
	check(filename)
end
