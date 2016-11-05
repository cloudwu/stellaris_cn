local filepath = "../cn/localisation"
local scriptpath = "."

local filelist = {
	"dip_messages_l_english.yml",
	"event_chains_l_english.yml",
	"event_chains_l_english_tag.yml",
	"events_2_l_english.yml",
	"events_3_l_english.yml",
	"events_4_l_english.yml",
	"events_l_english.yml",
	"guardian_l_english.yml",
	"guardian_l_english_tag.yml",
	"l_english.yml",
	"l_english_tag.yml",
	"mandates_l_english.yml",
	"messages_l_english.yml",
	"modifiers_2_l_english.yml",
	"modifiers_3_l_english.yml",
	"modifiers_l_english.yml",
	"name_lists_l_english.yml",
	"pop_factions_l_english.yml",
	"prescripted_l_english.yml",
	"projects_2_l_english.yml",
	"projects_3_l_english.yml",
	"projects_4_l_english.yml",
	"projects_l_english.yml",
	"ship_sections_l_english.yml",
	"standalone_l_english.yml",
	"technology_l_english.yml",
	"triggers_effects_l_english.yml",
	"tutorial_l_english.yml",
}

local check_text = assert(loadfile(scriptpath .. "/check.lua"))()

local function check(filename)
	filename = string.format("%s/%s", filepath, filename)
	local f = assert(io.open(filename), "Can't open " .. filename)
	local text = f:read "a"
	f:close()
	local err = check_text(text)
	if err then
		print("ERR:", filename, err)
	else
		print("OK:", filename)
	end
end

for _, filename in ipairs(filelist) do
	check(filename)
end
