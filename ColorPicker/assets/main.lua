application:setBackgroundColor(0x323232)

local colorPicker = ColorPicker.new(0, 0.1, 128, 128, 15)
--colorPicker:setPosition(100,100)
stage:addChild(colorPicker)

local mouseOldX = 0
local mouseOldX = 0

stage:addEventListener("mouseDown", function(e)
	mouseOldX = e.x
	mouseOldY = e.y
end)

stage:addEventListener("mouseMove", function(e)
	local mx = e.x
	local my = e.y
	
	local dx = mx - mouseOldX
	local dy = my - mouseOldY
	
	if (e.button == 2) then 
		local w, h = colorPicker:getDimensions()
		colorPicker:setDimensions(w + dx, h + dy)
	elseif (e.button == 4) then 
		local x, y = colorPicker:getPosition()
		colorPicker:setPosition(x + dx, y + dy)
	end
	
	mouseOldX = mx
	mouseOldY = my	
end)