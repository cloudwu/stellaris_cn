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

local list =  readlist "filelist.txt"

appendlist(list, readlist "name_lists.txt", "name_lists/")
appendlist(list, readlist "random_names.txt", "random_names/")

return {
	en = list,
	en34 = readlist "filelist34.txt",
}


