local game = Game
local SCR = game.Screen
local TILE = game.TILE
local MPANEL_W = TILE * game.MAX_MATCH

GameScene = Core.class(Sprite)

function GameScene:init()
	self.layers = Layers.new("bg", "main", "match")
	self:addChild(self.layers)
	
	self.matched = {}
	self.animatedTiles = 0
	
	self.panelBg = Pixel.new(0x909090, 1, MPANEL_W + 20, TILE + 20)
	self.panelBg:setPosition(
		SCR.Left + (SCR.W - MPANEL_W) / 2 - 10,
		SCR.Bottom - 210
	)
	self.layers:add("bg", self.panelBg)
	
	self.board = Board.new()
	self.board:load("level_1")
	self.board:setPosition(
		SCR.Left + (SCR.W - self.board:getWidth()) / 2,
		SCR.Top + (SCR.H - self.board:getHeight()) / 2
	)
	self.layers:add("main", self.board)
	
	self:addEventListener("touchesBegin", self.touchBegin, self)
end


function GameScene:updatePos(index)
	index = index or 0
	for i = index+1, #self.matched do 
		local mtile = self.matched[i]
		mtile:animate{
			duration = .5, 
			values = {
				x = SCR.Left + (SCR.W - MPANEL_W) / 2 + (i-1) * TILE + TILE / 2,
				y = SCR.Bottom - 200 + TILE / 2,
			},
			callback = function(obj)
				
			end
		}
	end
end

function GameScene:findMatches()
	local matched = 1
	local n = #self.matched
	if (n < 3) then return end
	local i = n
	local found = false
	while (i >= 3) do
		local t1 = self.matched[i]
		local t2 = self.matched[i-1]
		local t3 = self.matched[i-2]
		if (not (t1.isMoving or t2.isMoving or t3.isMoving)) then
			if (t1.color == t2.color and t1.color == t3.color) then 
				for j = i,i-2,-1 do 
					self.matched[j]:removeFromParent()
					table.remove(self.matched, j)
					--self.matched[j] = nil
				end
				found = true
				i -= 2
			end
		end
		i -= 1
	end
	if (found) then 
		self:updatePos()
	end
end

function GameScene:addMatch(tile)
	local n = #self.matched 
	local index = -1
	
	for i = 1, n-1 do 
		local v = self.matched[i]
		local next_v = self.matched[i+1]
		if (tile.color == v.color) then		
			if (next_v.color ~= tile.color) then 
				table.insert(self.matched, i+1, tile)
				index = i+1
				break
			end
		end
	end
	-- if there was no same tile in the collection
	-- add to the end
	if (index == -1) then 
		n+=1
		index = n
		self.matched[n] = tile
	end
	
	return index
end

function GameScene:animate(index, tile)
	index = index or 1
	if (index < 1) then index = 1 end
	
	tile.isMoving = true
	tile:animate{
		duration = .5, 
		values = {
			x = SCR.Left + (SCR.W - MPANEL_W) / 2 + (index-1) * TILE + TILE / 2,
			y = SCR.Bottom - 200 + TILE / 2,
		},
		callback = function(obj)
			obj.isMoving = false
			self:findMatches()
		end
	}
	self:updatePos(index)
end

function GameScene:touchBegin(e)
	local x, y = e.touch.x, e.touch.y
	local v,tx,ty,tz = self.board:touch(x, y)
	if (v and v.enabled) then 
		if (#self.matched < game.MAX_MATCH) then 
			local tile = self.board:remove(tx,ty,tz)
			
			-- translate local coords to global screen coords
			local parent = tile:getParent()
			local lx,ly = tile:getPosition()
			tile:setPosition(parent:localToGlobal(lx,ly))
			self.layers:add("match", tile)
			self:animate(self:addMatch(tile), tile)
		else
			print("Game over?")
		end		
	end
end