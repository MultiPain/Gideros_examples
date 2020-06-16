local minX,minY,maxX,maxY=app:getDeviceSafeArea(true)
local CX,CY=app:getContentWidth()/2, app:getContentHeight()/2
local SW = maxX - minX
local SH = maxY - minY
local Utils = require "utils"

GameScene = Core.class(Sprite)

function GameScene:init()
	self.world = BumpWorld.new()
	self.cam = Camera.new(SW, SH)
	self:addChild(self.cam)	
	
	self:createLevel()
	
	self:addEventListener(Event.ENTER_FRAME, self.update, self)
	self.keys = {}
	self:addEventListener(Event.KEY_UP, self.keyUP, self)
	self:addEventListener(Event.KEY_DOWN, self.keyDown, self)
end	

function GameScene:createLevel()
	self.level = Level.new(self.world)
	local data = self.level:load("test")
	self.cam:loadLayers(data.layers)
	
	self.player = Player.new(self.world)
	self.player:setPosition(data.playerData.x, data.playerData.y)
	self.cam:focus(self.player)
	self.cam:add("walls", self.player)
	
	self.cam:addLayer("ui", 0)
	self.FPS_counter = TextField.new(nil, "FPS: 0", "|")
	self.FPS_counter:setScale(2)
	self.FPS_counter:setPosition(minX + 10, minY + 10)
	self.cam:add("ui", self.FPS_counter)
end

local timer = 0
function GameScene:update(e)
	local dt = e.deltaTime
	timer += dt
	if (timer > 1) then 
		timer = 0
		self.FPS_counter:setText(string.format("FPS: %.2f", 1/dt))
	end
	
	self.cam:update(dt)
	self.player:update(dt)
	
	local x,y = self.cam.x, self.cam.y
	x = Utils.lerp(x, self.player:getX(), 0.1)
	y = Utils.lerp(y, self.player:getY(), 0.1)
	self.cam:setPosition(x, y)
end

function GameScene:keyUP(e)
	if (e.keyCode == KeyCode.RIGHT) then 
		self.player.movingRight = false
	end
	
	if (e.keyCode == KeyCode.LEFT) then
		self.player.movingLeft = false		
	end
	
	if (e.keyCode == KeyCode.UP) then 
		self.player:stopJump()
	end
end	

function GameScene:keyDown(e)
	if (e.keyCode == KeyCode.RIGHT) then 
		self.player.movingRight = true
	end
	
	if (e.keyCode == KeyCode.LEFT) then
		self.player.movingLeft = true
	end
	
	if (e.keyCode == KeyCode.UP) then 
		self.player:controlableJump()
	elseif (e.keyCode == KeyCode.Z) then 
		self.player:fixedJump()
	elseif (e.keyCode == KeyCode.P) then 
		local rt = RenderTarget.new(SW, SH)
		rt:draw(stage)
		rt:save("|D|screen.png")
	elseif (e.keyCode == KeyCode.DOWN) then 
		self.player:fallOff()
		self.player:unstick()
	elseif (e.keyCode == KeyCode.K) then 
		self.player:kill()
		
	elseif (e.keyCode == KeyCode.X) then 
		self.player:hit()
	end
end	
