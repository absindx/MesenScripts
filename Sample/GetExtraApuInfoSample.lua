-- Copy the GetExtraApuInfo.lua to the Mesen directory

-- Load module
emuex	= require("GetExtraApuInfo")

-- Dump utility
local drawStringYPosition	= 0
local function resetDrawStringPosition()
	drawStringYPosition	= 0
end
local function drawString(str)
	emu.drawString(0, drawStringYPosition, str, 0xFFFFFF, 0x80000000)
	drawStringYPosition	= drawStringYPosition + 8
end

local unpack	= unpack	or table.unpack
function dumpChannel_Note(name, channel)
	drawString(string.format("[%s] noteNumber=%3d, registers={%02X, %02X, %02X, %02X}", name, channel.noteNumber, unpack(channel.registers)))
end
function dumpChannel_Dpcm(name, channel)
	drawString(string.format("[%s] rate=%2d, registers={%02X, %02X, %02X, %02X}", name, channel.rate, unpack(channel.registers)))
end

function dumpApuExInfo()
	-- Get apu info
	apuInfo	= emuex.getExtraApuInfo()

	-- Dump info table
	resetDrawStringPosition()
	dumpChannel_Note("Sq1", apuInfo.square1)
	dumpChannel_Note("Sq2", apuInfo.square2)
	dumpChannel_Note("Tri", apuInfo.triangle)
	dumpChannel_Note("Noi", apuInfo.noise)
	dumpChannel_Dpcm("Dmc", apuInfo.dmc)
end

-- Register callback
emu.addEventCallback(dumpApuExInfo, emu.eventType.startFrame)
