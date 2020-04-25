--------------------------------------------------
-- Get extra APU info
--------------------------------------------------

--[[
	emuex.getExtraApuInfo()
		Returns a table with additional information added to the emu.getState().apu .

		square1: {
			registers: {
				1: int,	-- $4000 DDLC VVVV
				2: int,	-- $4001 EPPP NSSS
				3: int,	-- $4002 TTTT TTTT
				4: int,	-- $4003 LLLL LTTT
			},
			noteNumber: int
		},
		square2: {
			registers: {
				1: int,	-- $4004 DDLC VVVV
				2: int,	-- $4005 EPPP NSSS
				3: int,	-- $4006 TTTT TTTT
				4: int,	-- $4007 LLLL LTTT
			},
			noteNumber: int
		},
		triangle: {
			registers: {
				1: int,	-- $4008 CRRR RRRR
				2: int,	-- $4009 ---- ----
				3: int,	-- $400A TTTT TTTT
				4: int,	-- $400B LLLL LTTT
			},
			noteNumber: int
		},
		noise: {
			registers: {
				1: int,	-- $400C --LC VVVV
				2: int,	-- $400D ---- ----
				3: int,	-- $400E L--- PPPP
				4: int,	-- $400F LLLL L---
			},
			noteNumber: int
		},
		dmc: {
			registers: {
				1: int,	-- $4010 IL-- RRRR
				2: int,	-- $4011 -DDD DDDD
				3: int,	-- $4012 AAAA AAAA
				4: int,	-- $4013 LLLL LLLL
			},
			rate: int
		}
]]

--------------------------------------------------
-- Memory
--------------------------------------------------

local localMemory	= {}
local function readMemory(address)
	return localMemory[address]	or emu.read(address, emu.memType.cpuDebug)
end
local function writeBypass(address, value)
	localMemory[address]	= value
end

emu.addMemoryCallback(writeBypass, emu.memCallbackType.cpuWrite, 0x4000, 0x4017)

--------------------------------------------------
-- Frequency
--------------------------------------------------

local frequencyTable	= {}
for n=0,127 do
	frequencyTable[n]	= 440 * 2 ^ ( (n - 69) / 12)
end
frequencyTable[-1]	= 0

local function searchFrequencyTable(freq)
	local freqCount	= #frequencyTable
	if(freq < frequencyTable[0])then
		return nil
	elseif(frequencyTable[freqCount] <= freq)then
		return freqCount
	end

	for n=freqCount,0,-1 do
		if(frequencyTable[n - 1] < freq)then
			return n
		end
	end

	return nil
end
local function frequencyToNote(freq)
	local note	= searchFrequencyTable(freq)
	if(not note)then
		return 0
	end
	local freq1	= frequencyTable[note - 1]	or 0
	local freq2	= frequencyTable[note]
	local freqp	= (freq1 + freq2) / 2
	if(freq < freqp)then
		return note - 1
	else
		return note
	end
end

--------------------------------------------------
-- APU
--------------------------------------------------

local function setApuInfo_Square1(apu)
	local ch	= apu.square1
	ch.registers	= {
		readMemory(0x4000),
		readMemory(0x4001),
		readMemory(0x4002),
		readMemory(0x4003),
	}
	ch.noteNumber	= frequencyToNote(ch.frequency)
end
local function setApuInfo_Square2(apu)
	local ch	= apu.square2
	ch.registers	= {
		readMemory(0x4004),
		readMemory(0x4005),
		readMemory(0x4006),
		readMemory(0x4007),
	}
	ch.noteNumber	= frequencyToNote(ch.frequency)
end
local function setApuInfo_Triangle(apu)
	local ch	= apu.triangle
	ch.registers	= {
		readMemory(0x4008),
		readMemory(0x4009),
		readMemory(0x400A),
		readMemory(0x400B),
	}
	ch.noteNumber	= frequencyToNote(ch.frequency)
end
local function setApuInfo_Noise(apu)
	local ch	= apu.noise
	ch.registers	= {
		readMemory(0x400C),
		readMemory(0x400D),
		readMemory(0x400E),
		readMemory(0x400F),
	}
	ch.noteNumber	= ch.registers[3] & 0x0F
end
local function setApuInfo_Dmc(apu)
	local ch	= apu.dmc
	ch.registers	= {
		readMemory(0x4010),
		readMemory(0x4011),
		readMemory(0x4012),
		readMemory(0x4013),
	}
	ch.rate	= ch.registers[1] & 0x0F
end

--------------------------------------------------
-- API
--------------------------------------------------

emuex	= emuex	or {}

function emuex.getExtraApuInfo()
	local apu	= emu.getState().apu

	setApuInfo_Square1(apu)
	setApuInfo_Square2(apu)
	setApuInfo_Triangle(apu)
	setApuInfo_Noise(apu)
	setApuInfo_Dmc(apu)

	return apu
end

return emuex
