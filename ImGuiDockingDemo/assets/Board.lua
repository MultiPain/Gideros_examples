--!NEEDS:Grid.lua

Board = Core.class(Grid, function(t) t.tile = TILE return t end)
--
function Board:init(t)
end
--
function Board:createPieceAt(x, y)
	local piece = Pixel.new(COLOR, 1, TILE, TILE)
	piece:setPosition(self:toGlobal(x, y))
	self:addChild(piece)
	self.data[y][x] = piece
end
--
function Board:removePieceAt(x, y)
	local v = self.data[y][x]
	if (v and v ~= 0) then
		v:removeFromParent()
	end
	self.data[y][x] = nil
end
--
function Board:resize(w, h)	
	if (w < self.w) then 
		local dw = self.w - w
		for y = 1, self.h do 
			for i = 1, dw do 
				self:removePieceAt(self.w - i + 1, y)
			end
		end
	elseif (w > self.w) then 
		local dw = w - self.w
		for y = 1, self.h do 
			for i = 1, dw do 
				self:createPieceAt(self.w + i, y)
			end
		end
	end
	self.w = w
	
	if (h < self.h) then 
		for x = 1, self.w do 
			local dh = self.h - h
			for i = 1, dh do 
				self:removePieceAt(x, self.h - i + 1)
			end
		end
	elseif (h > self.h) then 
		for x = 1, self.w do 
			local dh = h - self.h
			for i = 1, dh do 
				self:createPieceAt(x, self.h + i)
			end
		end
	end
	self.h = h
end
--
function Board:generate(w, h)
	self.w = w
	self.h = h
	
	for y = 1, h do 
		self.data[y] = {}
		for x = 1, w do
			local piece = Pixel.new(COLOR, 1, TILE, TILE)
			self:add(x, y, piece)
		end
	end
end