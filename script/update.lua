local en_old = "../en3.3/localisation/english/"
local en_new = "../en/localisation/english/"
local cn_old = "../cn3.3/localisation/english/"
local cn_new = "../cn3.4/localisation/simp_chinese/"
local cn_target = "../cn/localisation/english/"

local command = (...) or "help"

local mode = {}

function mode.help()
	local cmdlist = {}
	for k in pairs(mode) do
		table.insert(cmdlist, k)
	end
	print("Command : ", table.concat(cmdlist, " "))
end

local function readfile(filename, dict, ident)
	ident = ident or " "
	local pat = "^" .. ident .. [[([%w%._%-']+):(%d*) (.*)]]
	local f = io.open(filename, "rb")
	if not f then
		return
	end
	for line in f:lines() do
		local key,dig,value = line:match(pat)
		if key then
			dict[key] = { d = dig , v = value, filename = filename }
		end
	end
	f:close()
end

local function readall(path, list)
	local r = {}
	for _, filename in ipairs(list) do
		filename = path .. filename
		readfile(filename, r)
	end
	return r
end

local function sort_items(items)
	local r = {}
	for k,v in pairs(items) do
		table.insert(r, {
			k = k,
			filename = v.filename,
			english = v.english,
			d = v.d,
			v = v.v or v.chinese,
			ref = v.ref,
		})
	end
	table.sort(r, function(a,b)
		if a.filename == b.filename then
			return a.k < b.k
		else
			return a.filename < b.filename
		end
	end)
	return r
end

local function output_diff(filename, s)
	local handle = assert(io.open(filename, "wb"))
	local function output(s)
		handle:write(s, "\n")
	end
	local freadall
	for _, v in ipairs(s) do
		if v.filename ~= f then
			f = v.filename
			output("")
			output("## " .. f)
			output("")
		end
		if v.english then
			output("# " .. v.english)
		end
		if v.ref then
			output(string.format("# %s:%s %s", v.k, v.d, v.ref))
		end
		output(string.format("%s:%s %s", v.k, v.d, v.v))
	end
	handle:close()
end

local function split_words(text)
	local r = {}
	for v in text:gmatch "[%w%[%]%._\\]+" do
		table.insert(r, v)
	end
	return r
end

local function english_diff(e1, e2)
	local t1 = split_words(e1)	-- new text
	local t2 = split_words(e2)	-- old text
	local i = 1
	while t1[i] do
		if t1[i] ~= t2[i] then
			if t1[i] == t2[i+1] then
				-- word removed
				table.insert(t1, i, string.format("{%s:}",t2[i]))
			elseif t1[i+1] == t2[i] then
				-- word inserted
				t1[i] = string.format("{:%s}", t1[i])
				if t2[i] then
					table.insert(t2, i, "")
				end
			else
				t1[i] = string.format("{%s:%s}", t2[i], t1[i])
			end
		end
		i = i + 1
	end
	return table.concat(t1, " ")
end

local terms = {
	{ "恒星基地" , "太空基地" },
	{ "恒星系" , "星系" },
	{ "泛星系",  "泛银河" },
	{ "星系理事会",  "银河理事会" },
	{ "星系议案", "银河议案" },
	{ "整个星系", "整个银河" },
	{ "全星系", "银河" },
	{ "星系法", "银河法" },
	{ "星系视图", "银河视图" },
	{ "星海", "银河" },
	{ "星_系" , "星系" },
	{ "重力井" , "引力井" },
	{ "农业区划", "农业区" },
	{ "工业区划", "工业区" },
	{ "贸易区划", "贸易区" },
	{ "采矿区划", "矿业区" },
	{ "居住区划", "居住区" },
	{ "区划", "地区" },
	{ "区段", "区块" },
	{ "傻逼", "蠢货" },
	{ "唯心主义", "精神主义" },
	{ "唯物主义", "物质主义" },
	{ "虚境", "天幕" },
	{ "缇扬奇", "天凯" },
	{ "位面之魇", "次元恶魔" },
	{ "异星天然气", "奇异瓦斯" },
	{ "易爆微粒", "高爆粉尘" },
	{ "海军容量", "军舰容量" },
	{ "海军", "舰队" },
	{ "飞升天赋",  "飞升特典" },
	{ "国民理念", "公民性" },
	{ "失落帝国", "堕落帝国" },
	{ "盖亚", "盖娅" },
--	{ "宣称", "领土主张" },
	{ "宿敌", "劲敌" },
	{ "赛博勒克斯", "赛博霸王" },
	{ "策展人", "典藏研究所" },
	{ "雪拉企业", "旭然集团" },
	{ "里甘", "瑞甘" },
	{ "穆塔根", "穆塔钢" },
}

local function term_fix(s)
	for _, t in ipairs(terms) do
		s = s:gsub(t[1], t[2])
	end
	return s
end

function mode.diff()
	local filelist = require "filelist"
	local english_old = readall(en_old, filelist)
	local english_new = readall(en_new, filelist)
	local chinese_old = readall(cn_old, filelist)
	local cnlist = require "cnfilelist"
	local chinese_new = readall(cn_new, cnlist)

	local items = {}

	for k,v in pairs(english_new) do
		local eold = english_old[k]
		if not eold then
			-- new item
			if chinese_new[k] then
				items[k] = {
					d = v.d,
					english = "[NEW] " .. v.v,
					filename = v.filename,
					chinese = term_fix(chinese_new[k].v),
				}
			else
				-- use english text
				v.english = "[ENGLISH]"
				items[k] = v
			end
		elseif v.v == eold.v then
			-- english text not change
		else
			items[k] = {
				d = v.d,
				english = "[CHANGE] " .. english_diff(v.v, eold.v),
				filename = v.filename,
				chinese = term_fix(chinese_new[k].v),
				ref = chinese_old[k].v,
			}
		end
	end

	local sorted = sort_items(items)
	output_diff("diff.txt", sorted)
end

local function patch_file(filename, chinese, patch)
	local fullname = en_new .. filename
	local f = io.open(cn_target .. filename, "wb")
	for line in io.lines(fullname) do
		local key,dig,value = line:match [[^ ([%w%._%-']+):(%d*) (.*)]]
		if not key then
			f:write(line, "\n")
		else
			local item = assert(patch[key] or chinese[key], line)
			f:write(" ", key , ":", dig, " ", item.v, "\n")
		end
	end
	f:close()
end

function mode.patch()
	local filelist = require "filelist"
	local chinese = readall(cn_old, filelist)
	local patch = {}
	readfile("diff.txt", patch, "")
	for _, filename in ipairs(filelist) do
		patch_file(filename, chinese, patch)
	end
end

local function sync(filename, dict)
	local fullname = cn_target .. filename
	local syncname = cn_target .. filename .. ".sync"
	local f = io.open(syncname, "wb")
	local diff = 0
	for line in io.lines(fullname) do
		local key,dig,value = line:match [[^ ([%w%._%-']+):(%d*) (.*)]]
		if not key then
			f:write(line, "\n")
		else
			local okey = key:gsub("(%a+)%d", "%11")
			if okey and dict[okey] then
				if value ~= dict[okey].v then
					diff = diff + 1
					print(value , ">", dict[okey].v)
					value = dict[okey].v
				end
			end
			f:write(" ", key , ":", dig, " ", value, "\n")
		end
	end
	f:close()
	if diff == 0 then
		os.remove(syncname)
	else
		os.remove(fullname)
		os.rename(syncname, fullname)
	end
end

function mode.syncname()
	local filelist = require "filelist"
	local dict = readall(cn_target, filelist)
	for _, v in ipairs(filelist) do
		local n = v:match "name_list_%a+(%d)"
		if n and n ~="1" then
			sync(v, dict)
		end
	end
end

mode[command]()
