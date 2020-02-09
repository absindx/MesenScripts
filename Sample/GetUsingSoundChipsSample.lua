-- Copy the GetUsingSoundChips.lua to the Mesen directory

-- Load module
chips	= require("GetUsingSoundChips")

-- Get chips info
chipInfo	= chips.GetUsingSoundChips()

-- Dump info table
for k,v in pairs(chipInfo)do
	emu.log(string.format("%s\t= %s", k, v))
end

--[[ Output: (Depends on open ROM)
vrc6	true
vrc7	false
fds	false
mmc5	false
n163	false
s5b	false
]]
