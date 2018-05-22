local en_path = "../en2.0/localisation/english/"
local cn_path = "../cn/localisation/english/"
local new_path = "../en/localisation/english/"
local diff_path = "../diff/"
local cn2_path = "../cn2.0/"

local function readfile(filename)
	local f = io.open(filename, "rb")
	if not f then
		return {}
	end
	local dict = {}
	for line in f:lines() do
		local key,dig,value = line:match("^ ([%w%._]+):(%d*) (.*)")
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

local function diff(filename, cn2)
	local f = new_diff(diff_path .. filename .. ".diff")
	local en = readfile(en_path .. filename)
	local cn = readfile(cn_path .. filename)
	for line in io.lines(new_path .. filename) do
		local key,dig,value = line:match("^ ([%w%._]+):(%d*) (.*)")
		if key then
			local e = en[key]
			local c = cn[key]
			if not e then
				-- new item
				f:write("ADD ", key, ":", dig, " " , value, "\n")
				if cn2[key] then
					f:write("CN2 ", key, ":", dig, " ", cn2[key].v, "\n")
				end
			else
				if value == e.v then
					if dig ~= e.d then
						-- only dig changes
						f:write("CHANGE ", key, ":", dig, " ", c.v, "\n")
					end
				else
					f:write("NEW ", key, ":", dig, " ", value, "\n")
					f:write("OLD ", key, ":", e.d, " ", e.v, "\n")
					f:write("CN  ", key, ":", dig, " ", c.v, "\n")
					if cn2[key] then
						f:write("CN2 ", key, ":", dig, " ", cn2[key].v, "\n")
					end
				end
				en[key] = nil
			end
		end
	end
	for k,v in pairs(en) do
		f:write("RM  ", k, ":", v.d, " " , v.v, "\n")
	end

	f:close()
end

local function readcn()
	local cn2_list = {
		"apocalypse_l_simp_chinese.yml",
		"l_simp_chinese.yml",
		"marauder_l_simp_chinese.yml",
		"messages_l_simp_chinese.yml",
		"modifiers_l_simp_chinese.yml",
	}
	local dict = {}
	for _, file in ipairs(cn2_list) do
		local filename = cn2_path .. file
		local r = readfile(filename)
		for k,v in pairs(r) do
			dict[k] = v
		end
	end
	return dict
end

local list = {
"achievements_l_english.yml",
"ai_crisis_l_english.yml",
"apocalypse_l_english.yml",
"dip_messages_l_english.yml",
"event_chains_l_english.yml",
"events_2_l_english.yml",
"events_3_l_english.yml",
"events_4_l_english.yml",
"events_5_l_english.yml",
"events_l_english.yml",
"gamepad_indicator_text_l_english.yml",
"guardian_l_english.yml",
"horizonsignal_l_english.yml",
"l_english.yml",
"mandates_l_english.yml",
"marauder_l_english.yml",
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
"synthetic_dawn_events_l_english.yml",
"technology_l_english.yml",
"traditions_l_english.yml",
"triggers_effects_l_english.yml",
"tutorial_l_english.yml",
"unrest_l_english.yml",
"utopia_ascension_l_english.yml",
"utopia_l_english.yml",
"utopia_megastructures_l_english.yml",
}

--local cn2 = readcn()
local cn2 = {}

for _,file in ipairs(list) do
	diff(file, cn2)
end
