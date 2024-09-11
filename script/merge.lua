local filelist = require "filelist"

local root = "../"
--_VERBOSE = true

local list = filelist.filelist()

local function readlist(path, ...)
	return filelist.readlist(root .. path .. "/", ...)
end

local data = {
	official_cn = readlist("3.13/simp_chinese", list, { ["_english"] = "_simp_chinese" }),
	cloudwu_cn = readlist("3.11/cn/localisation/english", list),
	en_last = readlist("3.11/en/localisation/english", list),
	en_current = readlist("3.13/english", list),
}

local function english_only(en, s)
	en = en:gsub("%$[%w_]+%$", "")
	en = en:gsub("[\"%s]", "")
	if en == "" then
		return true
	end
	if s then
		for p, c in utf8.codes(s) do
			if c >= 0x4e00 then
				return false
			end
		end
		return true
	end
end

local function is_alias(v)
	return v:sub(1,2) == '"$' and v:sub(-2) == '$"'
end

local function tags(s)
	local r = {}
	local n = 1
	for k in s:gmatch "%b[]" do
		r[n] = k
		n = n + 1
	end
	return r
end

local function diff_tags(a,b, key)
	if a:gsub("%b[]", "[]") == b:gsub("%b[]", "[]") then
		-- 只有 tag 变化
		local tag_a = tags(a)
		local tag_b = tags(b)
		local r = {}
		for i = 1, #tag_a do
			if tag_a[i] ~= tag_b[i] then
				local o = r[tag_a[i]]
				r[tag_a[i]] = tag_b[i]
				if o then
					assert(o == tag_b[i])
				end
			else
				if r[tag_a[i]] ~= nil then
					-- tag 变化无法处理
					return
				end
			end
		end
		return r
	end
end

local function fix_tags(s, diff)
	return (s:gsub("%b[]", function (tag)
		return diff[tag] or tag
	end))
end

local ARTICLE = {
	a = true,
	an = true,
	the = true,
}

local function small_changes(a, b)
	local function split(s)
		local r = {}
		local n = 1
		for w in s:gmatch("[^%s\"%.%,]+") do
			r[n] = w
			n = n + 1
		end
		return r
	end
	local w1 = split(a)
	local w2 = split(b)
	local i = 1
	local j = 1
	while i <= #w1 do
		local aa = w1[i]
		local bb = w2[j]
		if bb == nil then
			-- 新句子被截断
			return false
		end
		if aa == bb then
			i = i + 1
			j = j + 1
		elseif ARTICLE[aa] then
			-- 忽略冠词
			i = i + 1
		elseif ARTICLE[bb] then
			j = j + 1
		else
			-- 去掉复数
			aa = aa:gsub("(e?s?)$", "")
			bb = bb:gsub("(e?s?)$", "")
			aa = aa:lower()
			bb = bb:lower()
			if aa == bb then
				i = i + 1
				j = j + 1
			else
				return false
			end
		end
	end
	if j >= #w2 then
		return true
	else
		-- 追加句子
		return false
	end
end

local terms = {
	{ "恒星基地" , "太空基地" },
	{ "恒星系" , "星系" },
	{ "星系地图", "银河地图" },
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
	{ "泽珞", "卓尘" },
	{ "肃正协议", "紧急预案" },
	{ "星系舞台", "银河舞台" },
	{ "陆军将领", "将军" },
	{ "居住站", "轨道栖所", },
}

local function term_fix(s)
	for _, t in ipairs(terms) do
		s = s:gsub(t[1], t[2])
	end
	return s
end

local function fix(s)
	local s = term_fix(s)
	s = s:gsub ("#%s*%[LocEditor:ForFutureBatchExport%]%s*$", "")
	return s
end

local function add_values(s)
	local r = {}
	local n = 1
	for v in s:gmatch "§%u[+-]%d+%%?§" do
		r[n] = v
		n = n + 1
	end
	return r
end

local function check_add(a, b)
	local aa = add_values(a)
	local bb = add_values(b)
	if #aa ~= #bb then
		return true
	end
	for i, v in ipairs(a) do
		if v ~= b[i] then
			return true
		end
	end
	return false
end

local function entry(data, key, diff)
	local r = { d = data.en_current[key].d }
	local en = data.en_last[key]
	local needfix = false
	local current_en = data.en_current[key].v

	local function mark(tag)
		table.insert(diff[tag] , {
			line = string.format("%s(%d)", data.en_current[key].filename, data.en_current[key].line),
			key = key,
			en = data.en_current[key].v,
			entry = r.v,
		})
	end

	local function get_official()
		local cn = data.official_cn[key]
		if cn then
			-- 取官方翻译
			if english_only(current_en, cn.v) then
				r.v = current_en
				return false
			else
				local fixed = fix(cn.v)
				r.v = fixed
				if check_add(current_en, fixed) then
					mark "error"
				end
			end
		else
			if english_only(current_en) then
				r.v = current_en
				return false
			end
			-- 官方漏翻，取英文
			r.v = current_en .. " # TODO"
		end
		return true
	end
	
	if en then
		-- 上一版也有该英文条目
		if en.v == current_en then
			-- 英文没有变化，保留上一版中文翻译
			local last_cn = data.cloudwu_cn[key]
			if last_cn then
				if is_alias(last_cn.v) then
					r.v = last_cn.v
				else
					local cn = data.official_cn[key]
					if english_only(last_cn.v) and not english_only(cn.v) then
						-- 上一版没有翻译，这一版翻译了
						r.v = cn.v
					else
						r.v = last_cn.v
					end
				end
			else
				if get_official() then
					mark "omit"
				end
			end
		else
			local diff = diff_tags(en.v, current_en, key)
			if diff then
				-- 只有 tag 变化
				r.v = fix_tags(data.cloudwu_cn[key].v, diff)
			elseif small_changes(en.v, current_en) then
				-- 只有微小的变化，保留上个版本
				r.v = data.cloudwu_cn[key].v
			else
				-- 原文有变化
				if get_official() then
					mark "change"
				end
			end
		end
	else
		-- 新增加条目
		if get_official() then
			mark "add"
		end
	end
	data.output[key] = r
end

local function merge(data)
	local diff = {
		omit = {},
		change = {},
		add = {},
		error = {},
	}
	for k,v in pairs(data.en_current) do
		entry(data, k, diff)
	end
	return diff
end

local function sort(diff)
	local function comp(a,b)
		return a.line > b.line
	end
	for k,v in pairs(diff) do
		table.sort(v, comp)
	end
	return diff
end

data.output = {}
local diff = merge(data)
sort(diff)


local function output_diff(diff)
	for k,v in pairs(diff) do
		for _,v in ipairs(v) do
			print(k, v.line, v.key)
			print("  " .. v.en)
			print("  " .. v.entry)
		end
	end
end

local function gen(output_path, input_path, filename, data)
	local f = io.open(input_path .. filename, "rb")
	if not f then
		return
	end
	local wf = assert(io.open(output_path .. filename, "wb"))

	for line in f:lines() do
		local key,dig,value = line:match("^ ?([%w%._%-]+):(%d*) (.*)")
		if not key then
			-- 不用翻译
			wf:write(line, "\n")
		else
			local d = data.output[key] or error(key .. " not exist in " .. input_path .. filename)
			wf:write(" ", key, ":", dig, " " , d.v, "\n")
		end
	end

	f:close()
	wf:close()
end

local function output(data)
	for _, filename in ipairs(list) do
		gen(root .. "cn/localisation/english/" ,
			root .. "3.13/english/" ,
			filename, data)
	end
end

output(data)

--output_diff(diff)
