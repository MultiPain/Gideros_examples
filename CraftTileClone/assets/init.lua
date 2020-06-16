app @ application
local minX, minY, maxX, maxY = app:getLogicalBounds()
local w = -minX + maxX
local h = -minY + maxY

Game = {
	TILE = 64, 
	OFFSET = 4,
	MAX_MATCH = 9,
	
	Colors = {0x031D44, 0x064789, 0xEDB230, 0xE77728, 0xF4E9CD},
	
	Screen = {
		Left = minX, Right = maxX,
		Top = minY, Bottom = maxY,
		W = w, H = h,
		CX = minX + w / 2,
		CY = minY + h / 2,
	},
	NULL = function() end
}