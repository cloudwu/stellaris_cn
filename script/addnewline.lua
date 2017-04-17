-- 这个脚本用于核对英文原文结束有 \n 但是中文翻译漏掉的条目

local cnpath = "../cn/localisation/english"
local enpath = "../en/localisation/english"
local scriptpath = "."

local filelist = {
	"achievements_l_english.yml",
	"dip_messages_l_english.yml",
	"event_chains_l_english.yml",
	"event_chains_l_english_tag.yml",
	"events_2_l_english.yml",
	"events_3_l_english.yml",
	"events_4_l_english.yml",
	"events_5_l_english.yml",
	"events_l_english.yml",
	"gamepad_indicator_text_l_english.yml",
	"guardian_l_english.yml",
	"guardian_l_english_tag.yml",
	"horizonsignal_l_english.yml",
	"l_english.yml",
	"l_english_tag.yml",
	"mandates_l_english.yml",
	"messages_l_english.yml",
	"modifiers_2_l_english.yml",
	"modifiers_3_l_english.yml",
	"modifiers_l_english.yml",
	"modifiers_utopia_l_english.yml",
	"musicplayer_l_english.yml",
	"name_lists_l_english.yml",
	"pop_factions_l_english.yml",
	"prescripted_l_english.yml",
	"projects_2_l_english.yml",
	"projects_3_l_english.yml",
	"projects_4_l_english.yml",
	"projects_5_l_english.yml",
	"projects_l_english.yml",
	"scripted_loc_l_english.yml",
	"ship_sections_l_english.yml",
	"standalone_l_english.yml",
	"technology_l_english.yml",
	"traditions_l_english.yml",
	"triggers_effects_l_english.yml",
	"tutorial_l_english.yml",
	"unrest_l_english.yml",
	"utopia_ascension_l_english.yml",
	"utopia_l_english.yml",
	"utopia_megastructures_l_english.yml",
}

local check_text = assert(loadfile(scriptpath .. "/check.lua"))()

local function get_content(line)
	local content, comment = line:match("([^#]*)(%s*#.*)$")
	if content then
		return content, comment
	end
	return line
end

local function readenglish(filename)
	local dict = {}
	local enf = string.format("%s/%s", enpath, filename)
	local f = assert(io.open(enf), "Can't open " .. enf)
	local i = 0
	for line in f:lines() do
		i = i + 1
		line = get_content(line)
		local key, value = line:match(' ([%w_]+):%d "(.*)"?$')	-- 一些英文条目缺少 " ，容错
		if key then
			assert(dict[key] == nil, filename .. ":" .. i)
			dict[key] = value
		end
	end
	f:close()
	return dict
end

local function check(filename)
	local english = readenglish(filename)
	local cnf = string.format("%s/%s", cnpath, filename)
	local f = assert(io.open(cnf), "Can't open " .. cnf)
	local c = {}
	local i = 0
	local missing = false
	for line in f:lines() do
		i = i + 1
		local content, comment = get_content(line)
		local key, number, value = content:match(' ([%w_]+):(%d) "(.*)"$')
		if key then
			local ev = assert(english[key], filename .. ":" .. i)
			if ev:sub(-3) == '\\n"' then
				if value:sub(-2) ~= "\\n" then
					line = string.format(' %s:%s "%s\\n"%s', key, number, value, comment or "")
					missing = true
					print(filename, i, "MISSING")
				end
			else
				if value:sub(-2) == "\\n" then
					-- 多了 \n
					line = string.format(' %s:%s "%s"%s', key, number, value:sub(1,-3), comment or "")
					missing = true
					print(filename, i, "REDUNDANCY")
				end
			end
		end
		table.insert(c, line)
	end
	f:close()
	if missing then
		return c
	end
end

for _, filename in ipairs(filelist) do
	print(filename)
	local c = check(filename)
	if c then
		-- 修正
		local cnf = string.format("%s/%s", cnpath, filename)
		local f = assert(io.open(cnf, "wb"))
		f:write(table.concat(c, "\n"))
		f:write("\n")
		f:close()
	end
end
