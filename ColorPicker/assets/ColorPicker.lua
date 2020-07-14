local pickerSize = 8
local PICKER_TEX = Texture.new("picker.png", true)
local SLIDER_TEX = Texture.new("slider_2.png", true)

local function clamp(v, min, max)
	return (v <> min) >< max
end

-- RGB to HEX (and HEX  to RGB) converters
-- Converts an RGB color value to HEX 
-- RGB must be in range [0, 255]
local function rgb2hex255(r, g, b)
	return (r << 16) + (g << 8) + b
end

-- Converts an HEX color value to RGB
-- RGB values in range [0, 255]
local function hex2rgb255(hex)
	local r = hex >> 16
	local g = hex >> 8 & 0xff
	local b = hex & 0xff
	return r,g,b
end

-- Converts an RGB color value to HEX 
-- RGB must be in range [0, 1]
local function rgb2hex(r, g, b)
	r *= 255
	g *= 255
	b *= 255
	return (r << 16) + (g << 8) + b
end

-- Converts an HEX color value to RGB
-- RGB values in range [0, 1]
local function hex2rgb(hex)
	local r,g,b = utils.hex2rgb255(hex)
	return r/255,g/255,b/255
end

-- Converts an RGB color value to HSV
-- Assumes r, g, and b are contained in the set [0, 255] and
-- returns h, s, and v in the set [0, 1]
local function rgb2hsv(r, g, b, a)
	r /= 255
	g /= 255
	b /= 255
	a /= 255
	local max, min = r<>g<>b, r><g><b
	local h, s, v
	v = max

	local d = max - min
	if max == 0 then s = 0 else s = d / max end

	if max == min then
		h = 0 -- achromatic
	else
		if max == r then
		h = (g - b) / d
		if g < b then h = h + 6 end
		elseif max == g then h = (b - r) / d + 2
		elseif max == b then h = (r - g) / d + 4
		end
		h /= 6
	end

	return h, s, v, a
end

-- Converts an HSV color value to RGB. 
-- Assumes h, s, and v are contained in the set [0, 1] and
-- returns r, g, and b in the set [0, 255]
local function hsv2rgb(h, s, v, a)
	local r, g, b

	local i = (h * 6) // 1
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)

	i = i % 6

	if i == 0 then r, g, b = v, t, p
	elseif i == 1 then r, g, b = q, v, p
	elseif i == 2 then r, g, b = p, v, t
	elseif i == 3 then r, g, b = p, q, v
	elseif i == 4 then r, g, b = t, p, v
	elseif i == 5 then r, g, b = v, p, q
	end

	return r * 255, g * 255, b * 255, a * 255
end


ColorPicker = Core.class(Pixel)

function ColorPicker:init(initialColor, alpha, width, height, margins)
	self.colorsWidth = width
	self.colorsHeight = height
	
	margins = margins or 0
	hueSize = hueSize or 20
	initialColor = initialColor or 0
	
	self.mousePrevX = 0
	self.mousePrevY = 0
	
	self:setLayoutParameters{
		insets = margins, 
		cellSpacingY = 10,
		equalizeCells = false,
		columnWidths = {width},
		rowHeights = {height, 20, 32},
		resizeContainer = false,
	}
	
	-- source color
	self.sourceColor = Pixel.new(0xffffff, 1, 0, 0)
	self.sourceColor:setColor(initialColor, 1)
	self.sourceColor:setLayoutConstraints{
		gridx = 0, weightx = 1,
		gridy = 0, weighty = 1,
		fill = 1,
	}
	self:addChild(self.sourceColor)
	
	-- white gradient
	self.whiteGrad = Pixel.new(0xffffff, 1, 0, 0)
	self.whiteGrad:setColor(0xffffff, 0, 0xffffff, 1, 180)
	self.whiteGrad:setLayoutConstraints{
		gridx = 0, weightx = 1,
		gridy = 0, weighty = 1,
		fill = 1,
	}
	self:addChild(self.whiteGrad)
	
	-- black gradient
	self.blackGrad = Pixel.new(0xffffff, 1, 0, 0)
	self.blackGrad:setColor(0, 0, 0, 1, 270)
	self.blackGrad:setLayoutConstraints{
		gridx = 0, weightx = 1,
		gridy = 0, weighty = 1,
		fill = 1,
	}
	self:addChild(self.blackGrad)
	
	-- color picker image
	self.mainPicker = Bitmap.new(PICKER_TEX)
	self.mainPicker:setAnchorPoint(.5,.5)
	self.blackGrad:addChild(self.mainPicker)
	
	-- generate hue slider
	self.hue = Pixel.new(0xffffff, 1, 0, 0)
	self.hue:setLayoutParameters{}
	self.hue:setLayoutConstraints{
		gridx = 0, weightx = 1,
		gridy = 1, weighty = 1,
		fill = 1,
	}
	local j = 0
	local r,g,b = hsv2rgb(0, 1, 1, 1)
	local prev = rgb2hex255(r,g,b)
	for hue = 60, 360, 60 do
		r,g,b = hsv2rgb(hue / 360, 1, 1, 1)
		local curr = rgb2hex255(r,g,b)
		
		local colorPart = Pixel.new(0xffffff, 1, 10, 10)
		colorPart:setColor(curr, 1, prev, 1, 0)
		colorPart:setLayoutConstraints{
			gridx = j, weightx = 1,
			gridy = 0, weighty = 1,
			fill = 1,
		}
		self.hue:addChild(colorPart)
		prev = curr
		j += 1
	end
	self:addChild(self.hue)
	
	-- hue picker image
	self.huePicker = Sprite.new()
	
	local sliderHeight = SLIDER_TEX:getHeight()
	self.topHuePicker = Bitmap.new(SLIDER_TEX)
	self.topHuePicker:setAnchorPoint(0.5, 0)
	self.topHuePicker:setY(-sliderHeight)
	
	self.bottomHuePicker = Bitmap.new(SLIDER_TEX)
	self.bottomHuePicker:setAnchorPoint(0.5, 1)
	self.bottomHuePicker:setRotation(180)
	self.bottomHuePicker:setY(self.hue:getHeight() + sliderHeight)
	
	self.huePicker:addChild(self.topHuePicker)
	self.huePicker:addChild(self.bottomHuePicker)
	--self.huePicker:setAnchorPoint(0.5, 0.25)
	self.hue:addChild(self.huePicker)
	
	-- colored sprite
	self.result = Pixel.new(0, 1, 0, 0)
	self.result:setLayoutConstraints{
		gridx = 0, weightx = 1,
		gridy = 2, weighty = 1,
		fill = 1
	}
	self:addChild(self.result)
	
	-- calculate minimum size
	local info = self:getLayoutInfo()
	local layoutParams = self:getLayoutParameters()
	
	self.minWidth = layoutParams.insetLeft + layoutParams.insetRight + layoutParams.cellSpacingX * (info.width - 1)
	self.minHeight = layoutParams.insetTop + layoutParams.insetBottom + layoutParams.cellSpacingY * (info.height - 1)
	
	for k,v in ipairs(info.minWidth) do 
		self.minWidth += v 
	end
	
	for k,v in ipairs(info.minHeight) do 
		self.minHeight += v 
	end
	
	-- set background size
	Pixel.setDimensions(self, self.minWidth, self.minHeight)
	
	-- single rt to be able to get pixel data
	self.rt = RenderTarget.new(self.minWidth, self.minHeight)
	self:updateColor()
	
	self.state = ""
	
	self:addEventListener("mouseDown", self.onMouseDown, self)
	self:addEventListener("mouseMove", self.onMouseMove, self)
	self:addEventListener("mouseUp", self.onMouseUp, self)
end
--
function ColorPicker:setDimensions(width, height)
	local oldWidth, oldHeight = self:getDimensions()
	if (width < self.minWidth) then 
		width = self.minWidth
	end
	
	if (height < self.minHeight) then 
		height = self.minHeight
	end
	
	-- make sure that size was changed
	if (oldWidth ~= width or oldHeight ~= height) then
		Pixel.setDimensions(self, width, height)
		
		-- get picker position
		local cx, cy = self.mainPicker:getPosition()
		
		-- hide picker to get correct size of 
		-- "blackGrad"
		self.mainPicker:removeFromParent()
		self.colorsWidth, self.colorsHeight = self.blackGrad:getSize()
		self.blackGrad:addChild(self.mainPicker)
		
		-- make sure that color picker is inside "blackGrad"
		local x = clamp(cx, 0, self.colorsWidth-1)
		local y = clamp(cy, 0, self.colorsHeight-1)
		-- move to new position
		self.mainPicker:setPosition(x, y)
		
		-- same for hue picker
		self.huePicker:removeFromParent()
		local hueHeight = self.hue:getHeight()
		self.hue:addChild(self.huePicker)
		
		cx = self.huePicker:getX()
		x = clamp(cx, 0, self.colorsWidth-1)
		self.huePicker:setX(x)
		
		-- adjust slider images position
		local sliderHeight = SLIDER_TEX:getHeight()
		self.topHuePicker:setY(-sliderHeight)
		self.bottomHuePicker:setY(hueHeight)
		
		-- since size is change, render target must be 
		-- resized too, but we dont have a function to change
		-- its size dynamicly, so just create a new object
		self.rt = nil
		self.rt = RenderTarget.new(width, height)
		
		self:updateColor()
	end
end
--
function ColorPicker:updateColor()
	-- make pickers invisible to pick correct color
	self.mainPicker:setVisible(false)
	self.huePicker:setVisible(false)
	
	-- get position to translate pickers coordinates
	local x,y = self:getPosition()
	
	-- draw whole ColorPicker object
	self.rt:clear(0,0)
	self.rt:draw(self, -x, -y)
	
	-- translate hue position
	local colorX, colorY = self.hue:localToGlobal(self.huePicker:getPosition())
	colorX -= x
	colorY -= y
	
	-- get hue color
	local color, alpha = self.rt:getPixel(colorX, colorY)
	self.sourceColor:setColor(color, alpha)
	
	-- redraw
	self.rt:draw(self, -x, -y)
	
	-- translate main picker position
	colorX, colorY = self.blackGrad:localToGlobal(self.mainPicker:getPosition())
	colorX -= x
	colorY -= y
	
	-- get main color
	color, alpha = self.rt:getPixel(colorX, colorY)
	-- set color for result
	self.result:setColor(color, alpha)
	
	-- make pickers visible 
	self.mainPicker:setVisible(true)
	self.huePicker:setVisible(true)
end
--
function ColorPicker:getColor()
	return self.result:getColor()
end
--
function ColorPicker:onMouseDown(event)
	local mx, my = event.x, event.y
	
	if (self.sourceColor:hitTestPoint(mx, my)) then 
		self.state = "MAIN_COLOR"
	elseif (self.hue:hitTestPoint(mx, my)) then 
		self.state = "HUE_COLOR"
	else
		self.state = ""
	end
end
--
function ColorPicker:onMouseMove(event)
	local mx, my = event.x, event.y
	
	if (self.state == "MAIN_COLOR") then 
		-- translate coordinates
		local lx, ly = self.blackGrad:globalToLocal(mx, my)
		
		-- make sure that they in correct bounds
		local x = clamp(lx, 0, self.colorsWidth-1)
		local y = clamp(ly, 0, self.colorsHeight-1)
		
		-- move to new position
		self.mainPicker:setPosition(x, y)
		
		-- update colors
		self:updateColor()
	elseif (self.state == "HUE_COLOR") then
		-- translate coordinates
		local lx, ly = self.hue:globalToLocal(mx, my)
		
		-- make sure that they in correct bounds
		local x = clamp(lx, 0, self.colorsWidth-2)
		
		-- move to new position
		self.huePicker:setX(x)
		
		-- update colors
		self:updateColor()
	end
end
--
function ColorPicker:onMouseUp(event)
	self.state = ""
end