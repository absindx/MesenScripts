--------------------------------------------------
-- Get using sound chips info
--------------------------------------------------

--[[
	emuex.getUsingSoundChips()
		Returns the extended sound chip information used in the currently opened nes or nsf file.

		vrc6: bool
		vrc7: bool
		fds: bool
		mmc5: bool
		n163: bool
		s5b: bool
]]

--------------------------------------------------

emuex	= emuex	or {}

--------------------------------------------------

local find	= string.find
local match	= string.match

local function split(str, delimiter)
	local list	= {}
	local i		= 1
	local pos	= 1
	local sub	= string.sub

	while(true)do
		local s,e	= find(str, delimiter, pos)
		if(s)then
			list[i]	= sub(str, pos, s-1)
			pos	= e+1
		else
			list[i]	= sub(str, pos)
			break
		end
		i	= i+1
	end
	return list
end
local function trim(str)
	return match(str, "^%s*(.-)%s*$")
end

--------------------------------------------------

local chipMatchTable	= {
--	Key name	NSF Log		iNES Mapper
	"vrc6",		"VRC6",		24,		-- VRC6a
	"vrc6",		"VRC6",		26,		-- VRC6b
	"vrc7",		"VRC7",		85,
	"fds",		"FDS",		20,		-- Reserved, use emu.getRomInfo().format
	"mmc5",		"MMC5",		5,
	"n163",		"Namco 163",	19,
	"s5b",		"Sunsoft 5B",	69,
}
local fdsRomFormat	= 3	-- emu.getRomInfo().format

function emuex.getUsingSoundChips()
	local log	= emu.getLogWindowLog()
	local lines	= split(log, "\n")
	local info	= {}

	-- init
	for i=1,#chipMatchTable,3 do
		info[chipMatchTable[i]]	= false
	end

	info["fds"]	= emu.getRomInfo().format == fdsRomFormat

	for i=#lines,1,-1 do
		if(find(lines[i], "^%-%-%-%-%-") ~= nil)then
			break
		end

		local mapper	= match(lines[i], "%[iNes%]%s*Mapper:%s*(%d+)")
		if(mapper)then
			mapper	= tonumber(mapper)
			for i=1,#chipMatchTable,3 do
				local key	= chipMatchTable[i]
				info[key]	= info[key]	or (mapper == chipMatchTable[i + 2])
			end
		end

		local chipsLog	= match(lines[i], "%[NSF%]%s*Sound Chips:%s*(.+)")
		if(chipsLog)then
			chipsLog	= split(chipsLog, ",")
			for i=1,#chipsLog do
				local chip	= trim(chipsLog[i])
				for i=1,#chipMatchTable,3 do
					local key	= chipMatchTable[i]
					info[key]	= info[key]	or (chip == chipMatchTable[i + 1])
				end
			end
		end
	end

	return info
end

return emuex
