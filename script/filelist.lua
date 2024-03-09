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

local function readlist(filename)
	local list = {}
	local f = assert(io.open(filename))
	for line in f:lines() do
		table.insert(list, line)
	end
	f:close()
	return list
end

local function appendlist(list, append, prefix)
	for _, v in ipairs(append) do
		table.insert(list, prefix .. v)
	end
	return list
end

function M.filelist(listfile)
	listfile = listfile or {
		"filelist.txt",
		["name_lists/"] = "name_lists.txt",
		["random_names/"] = "random_names.txt",
	}
	local r = {}
	for k,v in pairs(listfile) do
		local list = readlist(v)
		if type(k) == "number" then
			appendlist(r, list, "")
		else
			local list = readlist(v)
			appendlist(r, list, k)
		end
	end
	return r
end

return M
