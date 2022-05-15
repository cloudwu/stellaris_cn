local path1 = "../cn/localisation/english/"
local path2 = "../cn/localisation/simp_chinese/"
local list = require "filelist"

local function convert(filename)
	local f = assert(io.open(path2 .. filename:gsub("_english", "_simp_chinese"), "wb"))
	local replace
	for line in io.lines(path1 .. filename) do
		if not replace then
			local sc_line = line:gsub("l_english:", "l_simp_chinese:")
			f:write(sc_line, "\n")
			replace = true
		else
			f:write(line, "\n")
		end
	end

	f:close()
end

for _,file in ipairs(list) do
	convert(file)
end
