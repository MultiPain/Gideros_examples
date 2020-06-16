Camera = Core.class(Sprite)

-- params is set of tables like {name, [paralax]}, {name, [paralax]}, where 
-- name: string, name of the layer
-- paralax: float, paralax effect in range [0, 1], by default is 1
--
-- NOTE: camera's postion is centered
function Camera:init(w, h, ...)
	self.x = 0
	self.y = 0
	self.width = w
	self.height = h
	self.shaking = false
	self.haveBounds = false
	self.bounds = {}
	self.layers = {}
	self.layersNames = {}
	
	self:addLayers(...)
	
	-- SHAKER
	self.shakeData = {
		time = 0,
		amount = 1,
		growth = 5,
		amplitude = 10,
		frequency = 100
	}
	
	self:setPosition(self.width / 2, self.height / 2)
end
-- CAMERA +
-- add layer on top
function Camera:addLayer(name, paralax)
	assert(self.layersNames.name == nil, "Layer with name \""..name.."\" already exists!")
	local lr = Layer.new(name, paralax)
	local i = #self.layers+1
	self.layers[i] = lr
	self.layersNames[name] = i 
	self:addChild(lr)
end
-- add multiple layers on top
-- {name, [paralax]}
function Camera:addLayers(...)
	local t = {...}
	if (#t > 0) then
		for i = 1, #t do
			local p = t[i][2] or 1
			local name = t[i][1]
			self:addLayer(name, p)
		end
	end
end
-- t is set of Layers!
function Camera:loadLayers(t)
	self:clearLayers()
	
	for i = 1, #t do
		local layer = t[i]
		self.layers[i] = layer
		self.layersNames[layer.name] = i
		self:addChild(layer)
	end
end
-- used only for shake update
function Camera:update(dt)
	if (self.shaking) then
		self.shakeData.amount = 1 <> self.shakeData.amount ^ 0.9
		local t = self.shakeData.time
		t += dt
		
		local shakeFactor = self.shakeData.amplitude * math.log(self.shakeData.amount)
		local waveX = math.sin(t * self.shakeData.frequency)
		local waveY = math.cos(t * self.shakeData.frequency)
		self.shakeData.time = t
		self:move(shakeFactor * waveX, shakeFactor * waveY)
		self.shaking = not(self.shakeData.amount <= 1.001)
	end
end
--
function Camera:shake() 
	self.shaking = true
	self.shakeData.amount += self.shakeData.growth
end
--
function Camera:resetShake() 
	self.shaking = false
	self.shakeData.amount = 1
	self.shakeData.time = 0
end
--
function Camera:setShake(growth, amplitude, frequency)
	self.shakeData.growth = growth
	self.shakeData.amplitude = amplitude or 10
	self.shakeData.frequency = frequency or 100
end
--
function Camera:move(dx, dy) self:setPosition(self.x + dx, self.y + dy) end
-- just center camera on sprite
function Camera:focus(sprite) self:setPosition(sprite:getX(), sprite:getY()) end

function Camera:setX(x) 
	x = self.haveBounds and math.clamp(x, self.bounds.x, self.bounds.x + self.bounds.w) or x
	self.x = x
	for _,l in ipairs(self.layers) do l:setX(-x + self.width/2) end	
end
--
function Camera:setY(y) 
	y = self.haveBounds and math.clamp(y, self.bounds.y, self.bounds.y + self.bounds.h) or y
	self.y = y
	for _,l in ipairs(self.layers) do l:setY(-y + self.height/2) end
end
-- set camera CENTER
function Camera:setPosition(x, y) 
	if (self.haveBounds) then 
		x = math.clamp(x, self.bounds.x, self.bounds.x + self.bounds.w) 
		y = math.clamp(y, self.bounds.y, self.bounds.y + self.bounds.h) 
	end
	self.x = x
	self.y = y
	
	for _,l in ipairs(self.layers) do l:setPosition(-x + self.width/2, -y + self.height/2) end
end
--
function Camera:getPosition() return self.x + self.width/2, self.y + self.height/2 end

function Camera:getX() return self.x + self.width/2 end

function Camera:getY() return self.y + self.height/2 end

function Camera:setBounds(x, y, width, height) 
	self.haveBounds = true
	self.bounds.x = x + self.width/2
	self.bounds.y = y + self.height/2
	self.bounds.w = width
	self.bounds.h = height
end
-- CAMERA - 

-- LAYERS +
function Camera:clearLayers()
	local l = #self.layers
	for i = l,1,-1 do
		local lr = table.remove(self.layers, i)
		self:removeChild(lr)
		self.layersNames[lr.name] = nil
	end
end
--
function Camera:add(name, sprite) self:getLayer(name):addChild(sprite) end

function Camera:remove(name, sprite) self:getLayer(name):removeChild(sprite) end

function Camera:setLayerParalax(name, paralax) self:getLayer(name):setParalax(paralax) end
	
function Camera:moveLayer(name, dx, dy) self:getLayer(name):move(dx, dy) end

function Camera:setLayerVisible(flag) self:getLayer(name):setVisible(flag) end

function Camera:getLayerParalax(name) return self:getLayer(name).paralax end

function Camera:getLayer(name) return self.layers[self.layersNames[name]] end
-- LAYERS -