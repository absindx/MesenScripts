--------------------------------------------------
-- Get iNES Info
--------------------------------------------------
-- Idea 1: parse emu.getLogWindowLog()			* this script
-- Idea 2: emu.getRomInfo().path, parse iNES header
--------------------------------------------------

local ines	= {}

--------------------------------------------------

local find	= string.find
local gsub	= string.gsub
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

--------------------------------------------------

ines.mirroringType	= {
	horizontal	= 0,
	vertical	= 1,
}

function ines.getINesInfo()
	local log	= emu.getLogWindowLog()
	local lines	= split(log, "\n")
	local info	= {}

	local function parseINesLog(log)
		local value1, value2
		local function logMatch(pattern)
			value1, value2	= match(log, pattern)
			return value1 ~= nil
		end
		local function setIntKey(key, value)
			value	= tonumber(value)
			if(value)then
				info[key]	= value
			end
		end
		local function setYesNoKey(key, value)
			value	= string.lower(value)
			if(value == "yes")then
				info[key]	= true
			elseif(value == "no")then
				info[key]	= false
			end
		end

		if(logMatch("NES 2%.0 file:%s*(%w+)"))then
			setYesNoKey("ines2", value1)
		elseif(logMatch("Mapper:%s*(%d+)%s*Sub:%s*(%d+)"))then
			setIntKey("mapper", value1)
			setIntKey("sub", value2)
		elseif(logMatch("System:%s*(.+)"))then
			setIntKey("system", value1)
		elseif(logMatch("PRG ROM:%s*(%d+)"))then
			setIntKey("prgRom", value1)
		elseif(logMatch("CHR ROM:%s*(%d+)"))then
			setIntKey("chrRom", value1)
		elseif(logMatch("CHR RAM:%s*(%d+)"))then
			setIntKey("chrRam", value1)
		elseif(logMatch("Work RAM:%s*(%d+)"))then
			setIntKey("workRam", value1)
		elseif(logMatch("Save RAM:%s*(%d+)"))then
			setIntKey("saveRam", value1)
		elseif(logMatch("Mirroring:%s*(%w+)"))then
			value1			= string.lower(value1)
			info["mirroring"]	= ines.mirroringType[value1]
		elseif(logMatch("Battery:%s*(%w+)"))then
			setYesNoKey("battery", value1)
		elseif(logMatch("trainer:%s*(%w+)"))then
			setYesNoKey("battery", value1)
		end
	end

	for i=#lines,1,-1 do
		if(find(lines[i], "^%-%-%-%-%-") ~= nil)then
			break
		end
		local message	= match(lines[i], "%[iNes%]%s*(.*)")
		if(message)then
			parseINesLog(message)
		end
	end

	return info
end

return ines
