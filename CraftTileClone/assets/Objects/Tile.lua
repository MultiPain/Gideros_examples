Tile = Core.class(Sprite)

function Tile:init(w, h, color)
	self.bg = Pixel.new(Game.TILE_TEXTURE, w, h)
	self.bg:setNinePatch(16,16,16,25,16,16,16,25)
	self.bg:setAnchorPoint(.5, .5)
	self.bg:setColor(color or 0xffffff)
	self:addChild(self.bg)
	
	self.color = color
	self:disable()
end

function Tile:enable()
	self.enabled = true
	self:setColorTransform(1,1,1)
end

function Tile:disable()
	self.enabled = false
	self:setColorTransform(.35,.35,.35)
end

-- t (table):
--	duration, values, ease, callback
function Tile:animate(t)
	t.duration = t.duration or 0
	t.ease = t.ease or easing.linear
	t.callback = t.callback or game.NULL
	
	if (self.gt) then 
		--self.gt.duration = t.duration
		self.gt.ease = t.ease
		self.gt:setValues(t.values)
		self.gt:setPaused(false)
	else
		self.gt = GTween.new(self, t.duration, t.values, {ease = t.ease})
		self.gt:addEventListener("complete", t.callback, self)
	end
	self.gt:setPosition(0)
	self.gt:setPaused(false)
end