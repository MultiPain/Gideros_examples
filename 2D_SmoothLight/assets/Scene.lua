local Left,Top,Right,Bottom = application:getLogicalBounds()
local W = -Left+Right
local H = -Top+Bottom
local RND = math.random

local lightTex = Texture.new("light.png", true)
local function circle(r, color)
	local shape = Path2D.new()
	local ms="MAAZ"
	local mp={-r,0, r,r,0,0,0,r,0, r,r,0,0,0,-r,0} -- anchor in center
	shape:setPath(ms,mp)
	shape:setFillColor(color or 0, 1)
	shape:setLineColor(color, 1)
	shape:setLineThickness(1, 1)
	return shape
end

Scene = Core.class(Sprite)

function Scene:init()
	self.objects = {}
	self.lights = {}
	
	self.pmx = 0
	self.pmy = 0
	
	self.smooth = 10
	
	self:createObjects()
	
	self:addEventListener("keyDown", self.keyDown, self)
	self:addEventListener("mouseMove", self.mouseMove, self)
	self:addEventListener("mouseDown", self.mouseDown, self)
	self:addEventListener("mouseUp", self.mouseUp, self)
	self:addEventListener("mouseWheel", self.mouseWheel, self)
end

function Scene:createObjects()
	local tex = Texture.new("background.png", true, {wrap = Texture.REPEAT})
	local bg = Pixel.new(tex, W,H)
	bg:setPosition(Left, Top)
	bg:setTextureScale(.2,.2)
	self:addChild(bg)
	--math.randomseed(0)
	
	for i = 1, 80 do 
		local o
		if RND() < .5 then 
			local w,h = RND(16, 64), RND(16,64)
			o = Pixel.new(RND(0xffffff), 1, w,h)
			o.type = "rect"
			o.w = w
			o.h = h			
			o:setAnchorPoint(.5,.5)
			o:setRotation(RND(360))
			o:setPosition(Left + RND(W - w*2), Top + RND(H-h*2))
		else
			local r = RND(8, 32)
			o = circle(r, RND(0xffffff))
			o.type = "circle"
			o.r = r
			o:setPosition(Left + RND(W - r*2), Top + RND(H-r*2))
		end
		self:addChild(o)
		self.objects[i] = o
	end
	
	
	local fg = Pixel.new(0, 0.7, W,H)
	fg:setPosition(Left, Top)
	fg:setTextureScale(.2,.2)
	self:addChild(fg)
	
	self.drawCallsTF = TextField.new(nil, "Draw calls: 0", "|")
	self.drawCallsTF:setScale(2)
	self.drawCallsTF:setTextColor(0xffffff)
	self:addChild(self.drawCallsTF)
end

function Scene:createLight(x,y,tex,r,c,c2)
	local l = Light.new(tex, r, c, 1,c2,1)
	l:setSmooth(self.smooth)
	l:setPosition(x-r,y-r)
	l:update(self.objects)
	self:addChild(l)
	
	self.lights[l] = true
	
	return l
end

function Scene:findLight(x, y)
	local pick_dist = 50
	for light,_ in pairs(self.lights) do 
		local lx,ly = light:getPosition()
		local dx = x - lx - light.r
		local dy = y - ly - light.r
		if (dx*dx+dy*dy) < (pick_dist * pick_dist) then
			return light
		end
	end
end

function Scene:keyDown(e)
	if e.keyCode == KeyCode.R then 
		for light,_ in pairs(self.lights) do 
			self:removeChild(light)
			self.lights[light] = nil
		end
	end
end

function Scene:mouseDown(e)
	self.pmx = e.x
	self.pmy = e.y
	
	if e.button == KeyCode.MOUSE_RIGHT then 
		self.dragableLight = self:findLight(e.x, e.y)
	elseif e.button == KeyCode.MOUSE_LEFT then 
		self.dragableLight = self:createLight(e.x,e.y,lightTex,RND(96,128),RND(0x909090, 0xffffff))
		self.dragableLight:setBlendMode(Sprite.ADD)
	elseif e.button == KeyCode.MOUSE_MIDDLE then 
		local light = self:findLight(e.x, e.y)
		if light then 
			light:removeFromParent()
			self.lights[light] = nil
		end
	end
end

function Scene:mouseWheel(e)
	if self.dragableLight then 
		local s = self.smooth
		if e.wheel < 0 then 
			s -= 1
			if s <= 1 then s = 1 end
		elseif e.wheel > 0 then 
			s += 1
		end
		self.smooth = s
		self.dragableLight:setSmooth(s)
		self.dragableLight:update(self.objects)
	end
end

function Scene:mouseMove(e)
	if self.dragableLight then 
		local dx = e.x - self.pmx
		local dy = e.y - self.pmy
		
		local lx,ly = self.dragableLight:getPosition()
		self.dragableLight:setPosition(lx+dx,ly+dy)
		self.dragableLight:update(self.objects)
		self.drawCallsTF:setText("Draw calls: "..self.dragableLight.drawCalls)
		self.pmx = e.x
		self.pmy = e.y
	end
end

function Scene:mouseUp(e)
	self.dragableLight = nil
	self.drawCallsTF:setText("Draw calls: 0")
end