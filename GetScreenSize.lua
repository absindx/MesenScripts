--------------------------------------------------
-- Get screen size
--------------------------------------------------

--[[
	emuex.getExtraApuInfo()
		Returns the size of the screen considering the overscan value.
]]

--------------------------------------------------

emuex	= emuex	or {}

--------------------------------------------------

local function matchArray(a, b, s)
	for i=1, #b do
		if(a[i + s - 1] ~= b[i])then
			return false
		end
	end
	return true
end

local function readBigendianInt(a, s)
	return (a[s] << 24) | (a[s + 1] << 16) | (a[s + 2] << 8) | a[s + 3]
end

--------------------------------------------------

function emuex.getScreenSize()
	-- get PNG binary array
	local strImage	= emu.takeScreenshot()
	local binImage	= {strImage:byte(1, -1)}

	-- check PNG signature
	local pngSignature	= {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A}
	if(not matchArray(binImage, pngSignature, 1))then
		return nil
	end

	-- search IHDR chunk
	local ihdrSignature	= {0x49, 0x48, 0x44, 0x52}	-- "IHDR"
	local caret	= #pngSignature + 1
	repeat
		if(matchArray(binImage, ihdrSignature, caret + 4))then	-- length(4)
			-- IHDR chunk found
			local width	= readBigendianInt(binImage, caret + 8)	-- length(4) + type(4)
			local height	= readBigendianInt(binImage, caret + 12)	-- length(4) + type(4) + width(4)
			return width, height
		end

		local chunkLength	= readBigendianInt(binImage, caret)
		caret	= caret + chunkLength + 12	-- length(4) + type(4) + crc(4)
	until(caret >= #binImage)

	-- IHDR chunk not found
	return nil
end

return emuex
