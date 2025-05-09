local path1 = "../cn/localisation/english/"
local path2 = "../cn/localisation/simp_chinese/"

local filelist = require "filelist"

local list = filelist.filelist "../cn/localisation/english/"

local function convert(filename)
	local f = io.open(path1 .. filename, "rb")
	if not f then
		return
	end
	print("Convert " ..filename)
	local wf = assert(io.open(path2 .. filename:gsub("_english", "_simp_chinese"), "wb"))
	local replace
	for line in f:lines() do
		if not replace then
			local sc_line = line:gsub("l_english:", "l_simp_chinese:")
			wf:write(sc_line, "\n")
			replace = true
		else
			wf:write(line, "\n")
		end
	end

	f:close()
	wf:close()
end

for _,file in ipairs(list) do
	convert(file)
end
