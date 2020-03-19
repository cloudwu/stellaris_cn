local diff_path = "../diff/"
local newdiff_path = "../diff0/"
local update_path = "../diff1/"

local function readdiff(filename)
	local diff = {}
	for line in io.lines(filename) do
		local command, key, dig, v = line:match("(%w+) +([%w%._-]+):(%d*) (.*)")
		local value = diff[key]
		if value == nil then
			value = { key = key }
			diff[key] = value
			table.insert(diff, value)
		end
		value[command] = { d = dig, v = v }
	end
	return diff
end

local function exist(filename)
	local f = io.open(filename)
	if f then
		f:close()
		return true
	end
	return false
end

local function mergediff(filename)
	local file1 = diff_path .. filename .. ".diff"
	local file2 = newdiff_path .. filename .. ".diff"
	local updatefile = update_path .. filename .. ".diff"

	if not exist(file2) then
		return
	end

	if not exist(file1) then
		-- copy diff
		local f = io.open(file2)
		local text = f:read "a"
		f:close()
		local f = io.open(updatefile , "wb")
		f:write(text)
		f:close()
		return
	end

	local diff = readdiff(file1)
	local newdiff = readdiff(file2)
	local result = {}

	local function insert_command(cmd, item)
		local value = item[cmd]
		if value then
			table.insert(result, string.format("%s %s:%s %s", cmd, item.key, value.d, value.v))
		end
	end

	for _, item in ipairs(newdiff) do
		insert_command("ADD", item)
		insert_command("RM", item)
		insert_command("OLD", item)
		insert_command("NEW", item)
		insert_command("CN", item)
		insert_command("CN2", item)
		local last = diff[item.key]
		if last then
			insert_command("CHANGE", last)
		end
	end

	local f = io.open (updatefile, "wb")
	f:write(table.concat(result, "\n"))
	f:close()
end

local list = {
"achievements_l_english.yml",
"ai_crisis_l_english.yml",
"ancient_relics_events_l_english.yml",
"ancient_relics_l_english.yml",
"apocalypse_l_english.yml",
"dip_messages_l_english.yml",
"distant_stars_l_english.yml",
"event_chains_l_english.yml",
"events_2_l_english.yml",
"events_3_l_english.yml",
"events_4_l_english.yml",
"events_5_l_english.yml",
"events_l_english.yml",
"gamepad_indicator_text_l_english.yml",
"horizonsignal_l_english.yml",
"l_english.yml",
"leviathans_l_english.yml",
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
"diplo_stances_l_english.yml",
"federations_l_english.yml",
"federations_resolution_comments_l_english.yml",
"lithoids_l_english.yml",
}

for _, filename in ipairs(list) do
	mergediff(filename)
end