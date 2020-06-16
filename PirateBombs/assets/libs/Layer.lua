Layer = Core.class(Sprite)

function Layer:init(name, paralax)
	self.name = name
	self.paralax = 1
	if (paralax ~= nil) then self:setParalax(paralax) end
end
--
function Layer:setParalax(value)
	self.paralax = (value<>0)><1
end
--
function Layer:move(dx, dy)
	local x, y = self:getPosition()
	x += dx
	y += dy
	self:setPosition(x, y)
end
--
function Layer:setX(x)
	Sprite.setX(self, x * self.paralax)
end
--
function Layer:setY(y)
	Sprite.setY(self, y * self.paralax)
	print(1)
end
--
function Layer:setPosition(x, y)
	Sprite.setPosition(self, x * self.paralax, y * self.paralax)
end