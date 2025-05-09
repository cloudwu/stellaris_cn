local M = {}

local function readfile(filename)
	if _G._VERBOSE then
		print("Open", filename)
	end
	local f = io.open(filename, "rb")
	if not f then
		print("Can't open ", filename)
		return {}
	end
	local dict = {}
	local linen = 1
	for line in f:lines() do
		local key,dig,value = line:match("^ ?([%w%._%-]+):(%d*) (.*)")
		if key then
			dict[key] = { d = dig , v = value , filename = filename , line = linen}
		end
		linen = linen + 1
	end
	f:close()
	return dict
end

function M.readlist(path, list, replace)
	if replace then
		local from,to = next(replace)
		local rlist = {}
		for _, v in ipairs(list) do
			table.insert(rlist, (v:gsub(from, to)))
		end
		list = rlist
	end
	local dict = {}
	for _, file in ipairs(list) do
		local filename = path .. file
		local r = readfile(filename)
		for k,v in pairs(r) do
			dict[k] = v
		end
	end
	return dict
end

function M.filelist(dir)
	local h = io.popen ("cd " .. dir .. "&& ls *.yml name_lists/*.yml random_names/*.yml")
	local list = h:read "a"
	h:close()
	local r = {}
	for filename in list:gmatch "[^\r\n]+" do
		r[#r+1] = filename
	end
	return r
end

return M
