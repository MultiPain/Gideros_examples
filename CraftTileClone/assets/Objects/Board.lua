local game = Game
local gridArgs = {
	tileW = game.TILE, offsetX = game.OFFSET,
	ax = .5, ay = .5,
}
local CELL = game.TILE + game.OFFSET

Board = Core.class(Sprite)

function Board:init()
	self.grids = {}
	
end

function Board:load(name)
	local data = require("levels/"..name)
	self.z = #data
	
	for i = 1, self.z do 
		local arr = data[i]
		
		gridArgs.w = #arr[1]
		gridArgs.h = #arr
		local g = Grid.new(gridArgs)
		g:iterate(function(x, y)
			if (arr[y][x] == 1) then 
				local clr = game.Colors[math.random(#game.Colors)]
				g:add(x, y, Tile.new(game.TILE, game.TILE, clr))
			end
		end)
		if (i % 2 == 0) then 
			g:setPosition(CELL / 2, CELL / 2)
		end
		
		self.grids[i] = g
		self:addChild(g)
	end
	
	for z,g in ipairs(self.grids) do 
		g:iterate(function(x,y)
			local t = g:getAt(x,y)
			if (t ~= 0 and self:checkTile(x,y,z)) then 
				t:enable()
			end
		end)
	end
end

function Board:touch(gx, gy)
	local x, y = self:globalToLocal(gx, gy)
	
	for i = self.z, 1, -1 do 
		local g = self.grids[i]
		if (g:hitTestPoint(gx,gy)) then
			local delta = 0
			if (i % 2 == 0) then delta = CELL / 2 end
			local tx, ty = g:toLocal(x - delta, y - delta)
			local v = g:getAt(tx,ty)
			if (v ~= 0) then 
				return v,tx,ty,i
			end
		end
	end
end

function Board:checkTile(tx,ty,tz)
	local v = self.grids[tz]:getAt(tx, ty)
	if (v ~= 0 and tz + 1 <= self.z) then
		local next_g = self.grids[tz + 1]
		for y = 0,1 do 
			for x = 0,1 do 
				local tile = next_g:getAt(tx - x, ty - y)
				if (tile and tile ~= 0) then 
					return nil
				end
			end
		end
	end
	return v
end

function Board:remove(tx, ty, tz)
	local v = self.grids[tz]:remove(tx,ty)
	
	if (tz - 1 > 0) then 
		for y = 0,1 do 
			for x = 0,1 do 
				local tile = self:checkTile(tx + x, ty + y, tz - 1)
				if (tile and tile ~= 0) then 
					tile:enable()
				end
			end
		end
	end
	
	return v
end