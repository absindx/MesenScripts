-- Copy the GetScreenSize.lua to the Mesen directory

-- Load module
emuex	= require("GetScreenSize")

-- Get screen info
width, height	= emuex.getScreenSize()

-- Output screen info
if(width and height)then
	emu.log(string.format("Screen: %dx%d", width, height))
else
	emu.log("Failed to get the screen size.")
end

--[[ Output: (Depends on overscan setting)
Screen: 256x240
]]
