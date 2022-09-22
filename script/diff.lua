local en35_path = "../en/localisation/english/"
local cn34_path = "../cn3.4/"
local en34_path = "../en3.4/"
local diff_path = "../diff/"
local cn35_path = "../cn3.5/"
local output_path = "../cn/localisation/english/"

local function readfile(filename)
	local f = io.open(filename, "rb")
	if not f then
		print("Can't open ", filename)
		return {}
	end
	local dict = {}
	for line in f:lines() do
		local key,dig,value = line:match("^ ([%w%._%-]+):(%d*) (.*)")
		if key then
			dict[key] = { d = dig , v = value }
		end
	end
	f:close()
	return dict
end

local function new_diff(name)
	local file = { __name = name }
	function file:write(...)
		self.__file = assert(io.open(self.__name, "wb"))
		function file:write(...)
			return self.__file:write(...)
		end
		self:write(...)
	end
	function file:close()
		if self.__file then
			self.__file:close()
		end
	end

	return file
end

local function diff_icon(new, old, c)
	local text = new:gsub("£([%w_|]+)£%s*", "£%1 ")
	local old_text = old:gsub("£([%w_|]+)%s*", "£%1 ")
	if text == old_text then
		-- Only icon changed
		return c:gsub("£([%w_|]+)", "£%1£")
	end
end

local function diff(filename, dict)
	local f = new_diff(diff_path .. filename .. ".diff")
	local cnf = io.open(output_path .. filename, "wb")
	for line in io.lines(en35_path .. filename) do
		local key,dig,value = line:match("^ ([%w%._%-]+):(%d*) (.*)")
		if key then
			local en34 = dict.en34[key]
			local cn34 = dict.cn34[key]
			local cn35 = dict.cn35[key]
			if not en34 then
				-- new item
				f:write("ADD ", key, ":", dig, " " , value, "\n")
				if cn35 then
					f:write("CN2 ", key, ":", dig, " ", cn35.v, "\n")
				end
				if cn35 then
					cnf:write(" ", key, ":", dig, " ", cn35.v, "\n")
				else
					cnf:write(line, "\n")
				end
			else
				if value == en34.v then
					-- english not change
					local v
					if cn34 then
						v = cn34.v
					else
						v = cn35.v
					end
					cnf:write(" ", key, ":", dig, " ", v, "\n")
				else
					f:write("NEW ", key, ":", dig, " ", value, "\n")
					f:write("OLD ", key, ":", en34.d, " ", en34.v, "\n")
					local ct = diff_icon(value, en34.v, cn34.v)
					if ct then
						-- only icon changes
						f:write(" ", key, ":", dig, " ", ct, "\n")
					else
						f:write("CN  ", key, ":", dig, " ", cn34.v, "\n")
						if cn35 then
							f:write("CN2 ", key, ":", dig, " ", cn35.v, "\n")
						end
						-- use english
						cnf:write(line, "\n")
						cnf:write("#", key, ":", dig, " ", cn35.v, "\n")
						cnf:write("#", key, ":", dig, " ", cn34.v, "\n")
					end
				end
			end
		else
			cnf:write(line, "\n")
		end
	end

	f:close()
	cnf:close()
end

local filelist = require "filelist"

local function readlist(path, list)
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

local function readcn(path, list)
	local cn_list = {}
	for _, v in ipairs(list) do
		table.insert(cn_list, (v:gsub("_english", "_simp_chinese")))
	end
	local dict = readlist(path, cn_list)
	for _, file in ipairs(cn_list) do
		local filename = path .. file
		local r = readfile(filename)
		for k,v in pairs(r) do
			dict[k] = v
		end
	end
	return dict
end

local dict = {
	cn35 = readcn(cn35_path, filelist.en),
	en34 = readlist(en34_path, filelist.en34),
	cn34 = readlist(cn34_path, filelist.en34),
}

for _,file in ipairs(filelist.en) do
	diff(file, dict)
end
