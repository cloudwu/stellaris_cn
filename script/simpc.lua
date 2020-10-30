local path1 = "../cn/localisation/english/"
local path2 = "../cn/localisation/simp_chinese/"

local function convert(filename)
	local f = io.open(path2 .. filename:gsub("_english", "_simp_chinese"), "wb")
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

local list = {
"achievements_l_english.yml",
"ai_crisis_l_english.yml",
"ancient_relics_events_l_english.yml",
"ancient_relics_l_english.yml",
"apocalypse_l_english.yml",
"dip_messages_l_english.yml",
"diplo_stances_l_english.yml",
"distant_stars_l_english.yml",
"dlc_recommendations_l_english.yml",
"event_chains_l_english.yml",
"events_2_l_english.yml",
"events_3_l_english.yml",
"events_4_l_english.yml",
"events_5_l_english.yml",
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
"new_scripted_loc_l_english.yml",
"observer_events_l_english.yml",
"observer_l_english.yml",
"pop_factions_l_english.yml",
"prescripted_l_english.yml",
"projects_2_l_english.yml",
"projects_3_l_english.yml",
"projects_4_l_english.yml",
"projects_5_l_english.yml",
"projects_l_english.yml",
"scripted_loc_l_english.yml",
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

for _,file in ipairs(list) do
	convert(file)
end
