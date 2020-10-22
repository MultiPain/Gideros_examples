Grid = Core.class(Sprite)

function Grid:init(t)
	self.tile = t.tile 
	self.offset = t.offset or 0
	self.margin = t.margin or 0
	self.xoff = t.xoff or 0
	self.yoff = t.yoff or 0
	
	self.w = 1 
	self.h = 1
	self.data = {}
end
--
function Grid:toLocal(x, y)
	x, y = self:globalToLocal(x, y)
	return 
		1 + ((x - self.margin) // (self.tile + self.offset)),
		1 + ((y - self.margin) // (self.tile + self.offset))
end
--
function Grid:toGlobal(tx, ty)
	return 
		self.margin + self.offset / 2 + (self.tile + self.offset) * (tx-1) + self.tile * self.xoff, 
		self.margin + self.offset / 2 + (self.tile + self.offset) * (ty-1) + self.tile * self.yoff
end
--
function Grid:isValid(tx, ty)
	return not (tx < 1 or tx > self.w or ty < 1 or ty > self.h)
end
--
function Grid:isFree(tx, ty)
	return self.data[ty][tx] == 0
end
--
function Grid:getAt(tx, ty)
	if (self:isValid(tx, ty)) then 
		return self.data[ty][tx]
	end
end
--
function Grid:add(tx, ty, obj)
	assert(self:isValid(tx, ty), "[Grid]: Invalid tile position")
	obj:setPosition(self:toGlobal(tx, ty))
	self:addChild(obj)
	self.data[ty][tx] = obj
end
--
function Grid:remove(tx, ty)
	assert(self:isValid(tx, ty), "[Grid]: Invalid tile position")
	local v = self.data[ty][tx]
	if (v ~= 0) then self:removeChild(v) end
	self.data[ty][tx] = 0
end
--
function Grid:iterate(func)
	for y = 1, self.h do 
		for x = 1, self.w do 
			func(x, y, self.data[y][x])
		end
	end
end
--
function Grid:getWidth() 
	return self.w * (self.tile + self.offset) + self.margin * 2
end
--
function Grid:getHeight() 
	return self.h * (self.tile + self.offset) + self.margin * 2
end