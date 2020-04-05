local random = math.random
local lightTex1 = Texture.new("textures/light.png", true)
local lightTex2 = Texture.new("textures/light_256.png", true)
local lightIcon = Texture.new("textures/icon.png", true)

local pick_dist = 50 -- drag&drop distance
local function choose(...)
	local t = {...}
	return t[random(#t)]
end

local Left,Top,Right,Bottom = application:getLogicalBounds()
local W = -Left+Right
local H = -Top+Bottom

require "cbump"

Scene = Core.class(Sprite)

function Scene:init()
	self.layers = Layers.new("bg", "obj", "fg", "light", "ui")
	self.layers:getLayer("light"):setBlendMode("add")
	self:addChild(self.layers)
	
	self.bump = BumpWorld.new()
	self.dragableLight = nil
	self.pmx = 0
	self.pmy = 0
	
	self:createBG()
	
	self.walls = {}
	self.lights = {}
	
	self:createWorld()
	
	self.fpsTimer = 0
	self.fpsTF = TextField.new(nil, "FPS: -", "|")
	self.fpsTF:setScale(2)
	self.fpsTF:setTextColor(0xffffff)
	self.fpsTF:setPosition(20,20)
	self.layers:add("ui", self.fpsTF)
	
	self.lightsCount = 0
	self.lightsTF = TextField.new(nil, "Lights: 0", "|")
	self.lightsTF:setScale(2)
	self.lightsTF:setTextColor(0xffffff)
	self.lightsTF:setPosition(20,40)
	self.layers:add("ui", self.lightsTF)
	
	stage:addEventListener("enterFrame", self.update, self)
	
	stage:addEventListener(Event.MOUSE_DOWN, self.mouseDown, self)
	stage:addEventListener(Event.MOUSE_MOVE, self.mouseMove, self)
	stage:addEventListener(Event.MOUSE_UP, self.mouseUp, self)
end

function Scene:createBG()
	local bg = Pixel.new(Texture.new("textures/background.png", true, {wrap = Texture.REPEAT}), W,H)
	bg:setTextureScale(0.2, 0.2)
	bg:setPosition(Left, Top)
	self.layers:add("bg", bg)
	----------------------------------
	local fg = Pixel.new(0,0.9, W,H)
	fg:setPosition(Left, Top)
	self.layers:add("fg", fg)
end

function Scene:createWall(x,y,w,h)
	local px = Pixel.new(random(0xffffff), 1, w, h)
	px:setPosition(x, y)
	self.layers:add("obj", px)
	self.bump:add(px, x, y, w, h)
	return px
end
	
function Scene:createWorld()
	for i = 1, 30 do 
		local w = random(32, 64)
		local h = random(32, 64)
		self.walls[i] = self:createWall(random(Left, Right - w), random(Top, Bottom - h), w, h)
	end
end

function Scene:createLight(x,y,r,c,a)
	local light = Light.new(self.bump, r, c, a, lightTex1)
	light:setPosition(x - r, y - r)
	light:update()
	self.lights[light] = true
	self.layers:add("light", light)
	
	local icon = Bitmap.new(lightIcon)
	icon:setScale(.7)
	icon:setAnchorPoint(.5,.5)
	icon:setPosition(light.r,light.r)
	light:addChild(icon)
	return light
end

function Scene:findLight(x, y)
	for light,_ in pairs(self.lights) do 
		local lx,ly = light:getPosition()
		local dx = x - lx - light.r
		local dy = y - ly - light.r
		if (dx*dx+dy*dy) < (pick_dist * pick_dist) then
			return light
		end
	end
end

function Scene:update(e)
	local dt = e.deltaTime
	
	self.fpsTimer += dt
	if self.fpsTimer >= 1 then 
		self.fpsTF:setText(("FPS: %02i"):format(1/dt))
		self.fpsTimer = 0
	end
end

function Scene:mouseDown(e)
	self.pmx = e.x
	self.pmy = e.y
	
	if e.button == KeyCode.MOUSE_LEFT then 
		self.dragableLight = self:findLight(e.x, e.y)
	elseif e.button == KeyCode.MOUSE_RIGHT then 
		self.dragableLight = self:createLight(e.x,e.y,choose(128,256),random(0xffffff),1)
		self.lightsCount += 1
		
		self.lightsTF:setText(("Lights: %i"):format(self.lightsCount))
	elseif e.button == KeyCode.MOUSE_MIDDLE then 
		local light = self:findLight(e.x, e.y)
		if light then 
			light:removeFromParent()
			self.lights[light] = nil
			
			self.lightsCount -= 1
			self.lightsTF:setText(("Lights: %i"):format(self.lightsCount))
		end
	end
end

function Scene:mouseMove(e)
	if self.dragableLight then 
		local dx = e.x - self.pmx
		local dy = e.y - self.pmy
		
		local lx,ly = self.dragableLight:getPosition()
		self.dragableLight:setPosition(lx+dx,ly+dy)
		
		self.pmx = e.x
		self.pmy = e.y
	end
end

function Scene:mouseUp(e)
	self.dragableLight = nil
end