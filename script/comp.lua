local files = {
"dip_messages_l",
"event_chains_l",
"events_2_l",
"events_3_l",
"events_4_l",
"events_5_l",
"events_l",
"guardian_l",
"horizonsignal_l",
"l",
"mandates_l",
"messages_l",
"modifiers_2_l",
"modifiers_3_l",
"modifiers_l",
"name_lists_l",
"pop_factions_l",
"prescripted_l",
"projects_2_l",
"projects_3_l",
"projects_4_l",
"projects_5_l",
"projects_l",
"ship_sections_l",
"standalone_l",
"technology_l",
"triggers_effects_l",
"tutorial_l",
}

local chinese = "../cn/localisation/%s_simp_chinese.yml"
local english = "../en/localisation/%s_english.yml"

local function comp(name, chinese, english)
end

local function map(f)
	local tmp =  {}
	for line in f:lines() do
		local key, id, value = line:match("^%s+([^#%s:]+):(%d)%s+([^#]*)")
		if key and id and value then
			assert(tmp[key] == nil)
			tmp[key] = { id = id, value = value }
		end
	end

	return tmp
end

local missing = 0
local excess = 0
local id = 0

for _, name in ipairs(files) do
	local c = assert(io.open(string.format(chinese, name)))
	local e = assert(io.open(string.format(english, name)))
	local cm = map(c)
	local em = map(e)
	for k,v in pairs(em) do
		if cm[k] == nil then
			print("MISSING", name, k)
			missing = missing + 1
		elseif v.id ~= cm[k].id then
			print("ID", name, k, v.id, cm[k].id)
			id = id + 1
		end
	end
	for k,v in pairs(cm) do
		if em[k] == nil then
			print("EXCESS", name, k)
			excess = excess + 1
		end
	end
	c:close()
	e:close()
end

print("TOTAL MISSING", missing, "EXCESS", excess, "ID", id)
