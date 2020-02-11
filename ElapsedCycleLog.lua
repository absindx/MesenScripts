--------------------------------------------------
-- Elapsed cycle log
--------------------------------------------------

--------------------------------------------------
-- Setting
--------------------------------------------------

local startAddress	= 0x8000
local endAddress	= startAddress + 3	-- JSR abs
local screenWidth	= 256
local screenHeight	= 240
local drawHeight	= 64

--------------------------------------------------
-- Draw
--------------------------------------------------

local textWidth		= 6
local textHeight	= 10
local cycleDigit	= 4
local maxLog		= screenWidth - textWidth * cycleDigit
local rectY		= screenHeight - drawHeight
local graphY		= screenHeight - 2
local textLog		= math.floor(drawHeight / textHeight)

local unpack	= unpack	or table.unpack
local function ceil(v, d)
	d	= d	or 1
	return math.ceil(v / d) * d
end
local function floor(v, d)
	d	= d	or 1
	return math.floor(v / d) * d
end
local function drawLog(log)
	local n	= #log

	local drawLine		= emu.drawLine
	local drawString	= emu.drawString
	local format		= string.format

	emu.clearScreen()

	-- text log
	for i=1,textLog do
		local v	= log[n - i + 1]
		if(not v)then
			break
		end
		drawString(0, screenHeight - i * textHeight, format("%4d", v), 0xFFFFFF, 0x80000000, 0)
	end

	-- graph
	local max	= ceil(math.max(unpack(log)), 100)
	local min	= floor(math.min(unpack(log)), 100)
	local d		= max - min
	local rectX	= screenWidth - n
	local centerY	= math.floor((rectY + screenHeight) / 2)

	emu.drawRectangle(rectX, rectY, n, drawHeight, 0x80000000, true, 0)
	emu.drawRectangle(rectX, rectY, n, drawHeight, 0x00FFFFFF, false, 0)
	emu.drawLine(rectX + 1, centerY, screenWidth - 2, centerY, 0x80FFFFFF, 0)

	drawString(rectX + 2, rectY + 2, format("%4d", max), 0xFFFFFF, 0xFF000000, 0)
	drawString(rectX + 2, screenHeight - textHeight, format("%4d", min), 0xFFFFFF, 0xFF000000, 0)
	drawString(rectX + 2, screenHeight - (drawHeight / 2) - textHeight + 1, format("%4d", (max + min) / 2), 0xFFFFFF, 0xFF000000, 0)

	for lx=3,n do	-- subtract border width
		local x	= lx + rectX - 2
		local y	= graphY - (drawHeight - 2) * (log[lx] - min) / d
		local color	= 0x40FF9153
		if(lx == n)then	-- most recent data
			color	= 0x00D2200E
		end
		drawLine(x, graphY, x, y, color, 0)
	end
end

--------------------------------------------------
-- Logging
--------------------------------------------------

local cycleLog		= {}
local startCycle	= 0
local function pushCycle(cycle)
	cycleLog[#cycleLog + 1]	= cycle
	local n	= #cycleLog - maxLog
	for i=1,n do
		table.remove(cycleLog, 1)
	end
end
local function GetCycle()
	local state	= emu.getState()
	return state.cpu.cycleCount
end

local function timerStart()
	startCycle	= GetCycle()
end
local function timerEnd()
	if(not startCycle)then
		-- invalid
		return
	end

	pushCycle(GetCycle() - startCycle)
	startCycle	= nil

	drawLog(cycleLog)
end

emu.addMemoryCallback(timerStart, emu.memCallbackType.cpuExec, startAddress)
emu.addMemoryCallback(timerEnd, emu.memCallbackType.cpuExec, endAddress)
