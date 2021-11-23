local en_path = "../en/localisation/english/"
local cn_path = "../cn/localisation/english/"
local new_path = "../en3.0/localisation/english/"
local diff_path = "../diff/"
local cn2_path = "../cn3.0/"

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

local function diff(filename, cn2)
	local f = new_diff(diff_path .. filename .. ".diff")
	local en = readfile(en_path .. filename)
	local cn = readfile(cn_path .. filename)
	for line in io.lines(new_path .. filename) do
		local key,dig,value = line:match("^ ([%w%._%-]+):(%d*) (.*)")
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
					if c == nil then
						print(filename, key, line)
					end
					local ct = diff_icon(value, e.v, c.v)
					if ct then
						f:write("CHANGE ", key, ":", dig, " ", ct, "\n")
					else
						f:write("CN  ", key, ":", dig, " ", c.v, "\n")
						if cn2[key] then
							f:write("CN2 ", key, ":", dig, " ", cn2[key].v, "\n")
						end
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
"achievements_l_simp_chinese.yml",
"ai_crisis_l_simp_chinese.yml",
"ancient_relics_events_l_simp_chinese.yml",
"ancient_relics_l_simp_chinese.yml",
"apocalypse_l_simp_chinese.yml",
"dip_messages_l_simp_chinese.yml",
"diplo_stances_l_simp_chinese.yml",
"distant_stars_l_simp_chinese.yml",
"dlc_recommendations_l_simp_chinese.yml",
"event_chains_l_simp_chinese.yml",
"events_2_l_simp_chinese.yml",
"events_3_l_simp_chinese.yml",
"events_4_l_simp_chinese.yml",
"events_5_l_simp_chinese.yml",
"events_l_simp_chinese.yml",
"federations_anniversary_l_simp_chinese.yml",
"federations_l_simp_chinese.yml",
"federations_resolution_comments_l_simp_chinese.yml",
"gamepad_indicator_text_l_simp_chinese.yml",
"horizonsignal_l_simp_chinese.yml",
"l_simp_chinese.yml",
"leviathans_l_simp_chinese.yml",
"lithoids_l_simp_chinese.yml",
"mandates_l_simp_chinese.yml",
"marauder_l_simp_chinese.yml",
"megacorp_l_simp_chinese.yml",
"messages_l_simp_chinese.yml",
"modifiers_2_l_simp_chinese.yml",
"modifiers_3_l_simp_chinese.yml",
"modifiers_l_simp_chinese.yml",
"modifiers_utopia_l_simp_chinese.yml",
"musicplayer_l_simp_chinese.yml",
"name_lists_l_simp_chinese.yml",
"necroids_l_simp_chinese.yml",
"nemesis_content_l_simp_chinese.yml",
"nemesis_crisis_l_simp_chinese.yml",
"nemesis_custodian_l_simp_chinese.yml",
"nemesis_douglas_l_simp_chinese.yml",
"nemesis_espionage_l_simp_chinese.yml",
"nemesis_gemma_l_simp_chinese.yml",
"nemesis_intel_l_simp_chinese.yml",
"nemesis_intel_pierre_l_simp_chinese.yml",
"new_scripted_loc_l_simp_chinese.yml",
"observer_events_l_simp_chinese.yml",
"observer_l_simp_chinese.yml",
"pop_factions_l_simp_chinese.yml",
"prescripted_l_simp_chinese.yml",
"projects_2_l_simp_chinese.yml",
"projects_3_l_simp_chinese.yml",
"projects_4_l_simp_chinese.yml",
"projects_5_l_simp_chinese.yml",
"projects_l_simp_chinese.yml",
"scripted_loc_l_simp_chinese.yml",
"ship_browser_l_simp_chinese.yml",
"ship_sections_l_simp_chinese.yml",
"social_gui_l_simp_chinese.yml",
"standalone_l_simp_chinese.yml",
"synthetic_dawn_events_l_simp_chinese.yml",
"technology_l_simp_chinese.yml",
"traditions_l_simp_chinese.yml",
"triggers_effects_l_simp_chinese.yml",
"tutorial_l_simp_chinese.yml",
"unrest_l_simp_chinese.yml",
"utopia_ascension_l_simp_chinese.yml",
"utopia_henrik_l_simp_chinese.yml",
"utopia_l_simp_chinese.yml",
"utopia_maximilian_l_simp_chinese.yml",
"utopia_megastructures_l_simp_chinese.yml",
"utopia_miranda_l_simp_chinese.yml",
"void_dweller_traditions_l_simp_chinese.yml",
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
"ancient_relics_events_l_english.yml",
"ancient_relics_l_english.yml",
"apocalypse_l_english.yml",
"aquatics_l_english.yml",
"dip_messages_l_english.yml",
"diplo_stances_l_english.yml",
"distant_stars_l_english.yml",
"dlc_recommendations_l_english.yml",
"event_chains_l_english.yml",
"events_2_l_english.yml",
"events_3_l_english.yml",
"events_4_l_english.yml",
"events_5_l_english.yml",
"events_6_l_english.yml",
"events_l_english.yml",
"federations_anniversary_l_english.yml",
"federations_l_english.yml",
"federations_resolution_comments_l_english.yml",
"gamepad_indicator_text_l_english.yml",
"horizonsignal_l_english.yml",
"l_english.yml",
"leviathans_l_english.yml",
"lithoids_l_english.yml",
"mandates_l_english.yml",
"marauder_l_english.yml",
"megacorp_l_english.yml",
"messages_l_english.yml",
"modifiers_2_l_english.yml",
"modifiers_3_l_english.yml",
"modifiers_l_english.yml",
"modifiers_utopia_l_english.yml",
"musicplayer_l_english.yml",
"name_lists_l_english.yml",
"necroids_l_english.yml",
"nemesis_content_l_english.yml",
"nemesis_crisis_l_english.yml",
"nemesis_custodian_l_english.yml",
"nemesis_espionage_l_english.yml",
"nemesis_intel_l_english.yml",
"new_scripted_loc_l_english.yml",
"observer_events_l_english.yml",
"observer_l_english.yml",
"pop_factions_l_english.yml",
"plantoids_l_english.yml",
"prescripted_l_english.yml",
"prescripted_l_english.yml",
"projects_2_l_english.yml",
"projects_3_l_english.yml",
"projects_4_l_english.yml",
"projects_5_l_english.yml",
"projects_l_english.yml",
"scripted_loc_l_english.yml",
"ship_browser_l_english.yml",
"ship_sections_l_english.yml",
"social_gui_l_english.yml",
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

local cn2 = readcn()
--local cn2 = {}

for _,file in ipairs(list) do
	diff(file, cn2)
end
