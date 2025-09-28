local filelist = require "filelist"
local term_fix = require "termfix"

local INPUT_PATH = "../4.1/english/"
local OUTPUT_PATH = "../cn/localisation/english/"
local OFFICAL_CHINESE = "../4.1/simp_chinese/"

local filename = ...

local function readlist(path)
	local list = filelist.filelist(path)
	return filelist.readlist(path, list)
end

local offical_cn = readlist(OFFICAL_CHINESE)

local function import(data)
	local f = io.open(INPUT_PATH .. filename, "rb")
	if not f then
		print ("Missing " .. INPUT_PATH .. filename)
		return
	end
	print ("Write " .. OUTPUT_PATH .. filename)
	local wf = assert(io.open(OUTPUT_PATH .. filename, "wb"))

	for line in f:lines() do
		local key,dig,value = line:match("^ ?([%w%._%-]+):(%d*) (.*)")
		if not key then
			-- 不用翻译
			wf:write(line, "\n")
		else
			local d = data[key]
			if not d then
				-- 没有翻译
				print(">>> Missing ", key)
			else
				local s = term_fix(d.v)
				if s ~= d.v then
--					print("Fix " .. s , "\n\t", d.v)
				end
				wf:write(" ", key, ":", d.d, " " , d.v, "\n")
			end
		end
	end
	f:close()
	wf:close()
end

import(offical_cn)
