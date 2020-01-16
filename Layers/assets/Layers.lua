Layer = Core.class(Sprite)

function Layer:init(name)
	self.name = name
end
--
function Layer:clear()
	for i = self:getNumChildren(), 1, -1 do 
		self:removeChildAt(i)
	end
end
--

Layers = Core.class(Sprite)

function Layers:init(...)
	self.layers = {}
	self:load(...)
end
--
function Layers:load(...)
	for i,name in ipairs({...}) do 
		self:addLayer(name)
	end
end
--
function Layers:addLayer(name, ind)
	local i = ind or self:getNumChildren()+1
	
	assert(self.layers[name] == nil, "Layer \""..name.."\" already exists")
	
	-- simple layer object
	local lr = Layer.new(name)	
	self.layers[name] = lr
	self:addChildAt(lr, i)
end
--
function Layers:removeLayer(name_or_id)
	local lr = self:getLayer(name_or_id)
	self.layers[lr.name] = nil
	self:removeChild(lr)
end
--
function Layers:removeAllLayers()
	for i = self:getNumChildren(), 1, -1 do 
		self:removeLayer(i)
	end
end
--
function Layers:getByName(name)
	assert(self.layers[name], "Layer with name \"".. name .."\" does not exist")
	return self.layers[name]
end
--
function Layers:getByID(id)
	return self:getChildAt(id)
end
--
function Layers:getLayer(name_or_id)
	if (type(name_or_id) == "string") then 
		return self:getByName(name_or_id)
	elseif (type(name_or_id) == "number") then 
		return self:getByID(name_or_id)
	end
	error("First paramter must be string or number")
end
--
function Layers:add(name_or_id, sprite)
	local lr = self:getLayer(name_or_id)	
	lr:addChild(sprite)
end
--
function Layers:addTop(sprite)
	local lr = self:getLayer(self:getNumChildren())
	lr:addChild(sprite)
end
--
function Layers:remove(name_or_id, sprite)
	local lr = self:getLayer(name_or_id)
	lr:removeChild(sprite)
end
--
function Layers:removeQuery(sprite)
	for i = 1, self:getNumChildren() do
		local lr = self:getLayer(i)
		if (lr:contains(sprite)) then 
			lr:removeChild(sprite)
			break
		end
	end
end