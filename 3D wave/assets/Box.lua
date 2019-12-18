Box = Core.class(Mesh, function() return true end)

function Box:init(w, h, depth, color)
	color = color or 0xffffff
	self.depth = -depth
	self.w = w
	self.h = h
	
	self:setVertex(1, 0,0,self.depth) --╗
	self:setVertex(2, w,0,self.depth) --╠═ back side
	self:setVertex(3, w,h,self.depth) --║
	self:setVertex(4, 0,h,self.depth) --╝
	self:setVertex(5, 0,0,0) --╗
	self:setVertex(6, w,0,0) --╠═ front side
	self:setVertex(7, w,h,0) --║
	self:setVertex(8, 0,h,0) --╝
	self:setIndexArray(1,2,3, 1,3,4, 1,5,4, 5,4,8, 5,6,7, 5,7,8, 6,2,3, 6,3,7, 1,2,6, 1,6,5, 4,3,7, 4,7,8)
	self:setColor(color, 1)
end

function Box:setColor(color, alpha)
	for i = 1, 8 do Mesh.setColor(self, i, color,alpha) end
end

function Box:setFrontColor(color, alpha)
	for i = 5, 8 do Mesh.setColor(self, i, color,alpha) end
end

function Box:setBackColor(color, alpha)
	for i = 1, 4 do Mesh.setColor(self, i, color,alpha) end
end

function Box:setTopColor(color, alpha)
	Mesh.setColor(self, 1, color,alpha)  
	Mesh.setColor(self, 2, color,alpha)  
	Mesh.setColor(self, 5, color,alpha)  
	Mesh.setColor(self, 6, color,alpha)  
end

function Box:setBottomColor(color, alpha)
	Mesh.setColor(self, 4, color,alpha) 
	Mesh.setColor(self, 3, color,alpha) 
	Mesh.setColor(self, 8, color,alpha) 
	Mesh.setColor(self, 7, color,alpha) 
end

function Box:setLeftColor(color, alpha)
	Mesh.setColor(self, 1, color,alpha) 
	Mesh.setColor(self, 4, color,alpha) 
	Mesh.setColor(self, 5, color,alpha) 
	Mesh.setColor(self, 8, color,alpha) 
end

function Box:setRightColor(color, alpha)
	Mesh.setColor(self, 2, color,alpha) 
	Mesh.setColor(self, 3, color,alpha) 
	Mesh.setColor(self, 6, color,alpha) 
	Mesh.setColor(self, 7, color,alpha) 
end

function Box:setWidth(w)
	self.w = w
	
	self:setVertex(2, w,0,self.depth)
	self:setVertex(3, w,self.h,self.depth)
	self:setVertex(6, w,0,0)
	self:setVertex(7, w,self.h,0)
end

function Box:setHeight(h)
	self.h = h
	
	self:setVertex(3, self.w,h,self.depth)
	self:setVertex(4, 0,h,self.depth)
	self:setVertex(7, self.w,h,0)
	self:setVertex(8, 0,h,0)
end

function Box:setDepth(d)
	self.depth = -d
	
	self:setVertex(1, 0,0,self.depth)
	self:setVertex(2, self.w,0,self.depth)
	self:setVertex(3, self.w,self.h,self.depth)
	self:setVertex(4, 0,self.h,self.depth)
end

function Box:setSize(w, h, d)
	self:setWidth(w)
	self:setHeight(h)
	self:setDepth(d)
end

function Box:getWidth() return self.w end
function Box:getHeight() return self.h end
function Box:getDepth() return -self.depth end
function Box:getSize() return self.w, self.h, -self.depth end