-- Copy the GetINesInfo.lua to the Mesen directory

-- Load module
emuex	= require("GetINesInfo")

-- Get iNES info
romInfo	= emuex.getINesInfo()

-- Dump info table
for k,v in pairs(romInfo)do
	emu.log(string.format("%s\t= %s", k, v))
end

--[[ Output: (Depends on open ROM)
mapper	= 4
sub	= 0
prgRom	= 16
chrRom	= 8
mirroring	= 1	-- emuex.mirroringType.vertical
battery	= false
]]
