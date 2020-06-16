Grid = Core.class(Sprite)

function Grid:init(t)
	self.tileW = t.tileW
	self.tileH = t.tileH or self.tileW
	
	self.offsetX = t.offsetX or 0
	self.offsetY = t.offsetY or self.offsetX
	
	self.ax = t.ax or 0
	self.ay = t.ay or 0
	
	self.margin = t.margin or 0
	
	self.cellW = self.tileW + self.offsetX
	self.cellH = self.tileH + self.offsetY
	
	self.data = {}
	
	if (t.w and t.h) then 
		self.w = t.w
		self.h = t.h
		for y = 1, self.h do 
			self.data[y] = {}
			for x = 1, self.w do 
				self.data[y][x] = 0
			end
		end
	end
end

function Grid:isValid(tx, ty)
	return not (tx < 1 or tx > self.w or ty < 1 or ty > self.h)
end

function Grid:getAt(tx, ty)
	if (self:isValid(tx, ty)) then 
		return self.data[ty][tx]
	end
end

function Grid:toGlobal(tx, ty)
	return
		self.margin + self.tileW * self.ax + self.cellW * (tx - 1),
		self.margin + self.tileH * self.ay + self.cellH * (ty - 1)
end

function Grid:toLocal(x, y)
	return 
		1 + (x - self.margin + self.offsetX / 2) // self.cellW,
		1 + (y - self.margin + self.offsetY / 2) // self.cellH
end

function Grid:add(tx, ty, obj)
	assert(self:isValid(tx,ty), "[Grid]: invalid tile coords")
	self:addChild(obj)
	obj:setPosition(self:toGlobal(tx,ty))
	self.data[ty][tx] = obj
end

function Grid:remove(tx, ty)
	assert(self:isValid(tx,ty), "[Grid]: invalid tile coords")
	local v = self.data[ty][tx]
	--if (v ~= 0) then self:removeChild(v) end
	self.data[ty][tx] = 0
	return v
end

function Grid:iterate(callback)
	for y = 1, self.h do 
		for x = 1, self.w do 
			callback(x, y)
		end
	end
end

function Grid:getWidth()
	return self.margin * 2 + self.w * self.cellW - self.offsetX
end

function Grid:getHeight()
	return self.margin * 2 + self.h * self.cellH - self.offsetY
end