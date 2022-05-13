local filepath = "../cn/localisation/english"
local scriptpath = "."

local filelist = assert(loadfile(scriptpath .. "/filelist.lua"))()

local check_text = assert(loadfile(scriptpath .. "/check.lua"))()

local function check(filename)
	filename = string.format("%s/%s", filepath, filename)
	local f = assert(io.open(filename), "Can't open " .. filename)
	local text = f:read "a"
	f:close()
	local err = check_text(text)
	if err then
		print("ERR:", filename, err)
	else
		print("OK:", filename)
	end
end

for _, filename in ipairs(filelist) do
	check(filename)
end
