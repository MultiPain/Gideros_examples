local font = TTFont.new("Bolularegular.otf", 20)

Editor = Core.class(Sprite)

function Editor:init()
	self.ui = SUI.new("touch")
	self:addChild(self.ui)
	
	self.step = 0.1
	self.drawMode = 0 -- 0 - curve, 1 - vector dirs
	self.drawLen = 5
	
	local gr = self.ui:hGroup(0, 10)
	
	local gr2 = self.ui:vGroup(0, 10)
	gr2:add(self.ui:button(Pixel.new(0xf0f0f0, 1, 24, 24),function() self:addPoint()end):addText("+", font))
	gr2:add(self.ui:button(Pixel.new(0xf0f0f0, 1, 24, 24),function() self:removePoint()end):addText("-", font))
	gr:add(gr2)
	
	gr:add(self.ui:hSlider(0.001, 0.5, self.step, false, 
		{Pixel.new(0xffffff, 1, 98, 24),Pixel.new(0xf0f0f0, 1, 24, 24)},
		function(obj, value) self.step = value;self:redrawPath() end
	):addText("Accuracy", font))
	
	gr:add(self.ui:checkBox("", 
		{Pixel.new(0xffffff, 1, 24, 24),Pixel.new(0xf0f0f0, 1, 24, 24)},
		function(obj, state) self.drawMode = state;self:redrawPath() end, 
		{labelWidth = 98, labelOffsetX = 4}
	):addText("Draw mode", font,FontBase.TLF_REF_TOP|FontBase.TLF_RIGHT|FontBase.TLF_VCENTER|FontBase.TLF_CENTER))
	
	gr:add(self.ui:hSlider(5, 40, self.drawLen, false, 
		{Pixel.new(0xffffff, 1, 98, 24),Pixel.new(0xf0f0f0, 1, 24, 24)},
		function(obj, value) self.drawLen = value;self:redrawPath() end
	):addText("Vector len", font))
	
	
	self.points = {}
	
	self.curve = Bezier.new()
	self.path = Path2D.new()
	self:addChild(self.path)
	
	self:addEventListener(Event.APPLICATION_RESIZE, self.appResize, self)
	self:appResize()
end
--
function Editor:addPoint()
	local n = #self.points
	local x,y = self.spawnX,self.spawnY
	if n > 0 then 
		x,y = self.points[n]:getPosition()
		y += 20
	end
	
	
	local p = self.ui:button(
		{{img=Pixel.new(0xffffff, 1, 12, 12),set={anchorX = 6, anchorY = 6}}},
		function(obj, state)
			--if state == "drop" then 
				self:redrawPath()
			--end
		end
	)
	p:addText(n+1, font)
	p:addDragDrop() --< NEW adds drag&drop behaviour (removes button default behaviour)
	p:setPosition(x, y)
	self.points[n+1] = p
	self:redrawPath()
end
--
function Editor:removePoint()
	local n = #self.points
	if n > 0 then 
		local p = self.points[n]
		p:removeFromParent()
		self.points[n] = nil
		self:redrawPath()
	end
end
--
function Editor:redrawPath()
	local p = {}
	local j = 1
	--generate points for bezier curve in format {x0,y0, x1,y1, x2,y2, ...}
	for i,v in ipairs(self.points) do 
		local x,y = v:getPosition()
		p[j+0] = x
		p[j+1] = y
		j += 2
	end
	-- generate bezier path
	self.curve.srcPoints = p
	
	-- draw path
	local points = {}
	local ms = ""
	if self.drawMode == 0 then 
		points = self.curve:getCurvePoints(self.step)
		ms = "M"
		for i = 2,#points/2 do ms = ms .. "L" end
	else
		local mi = 1
		local dpoints = self.curve:getDirCurvePoints(self.step)
		
		for k,v in ipairs(dpoints) do 
			--v: {point = {x=x,y=y}, dir={x=dx,y=dy,a=a}}
			if v.dir.x ~= 0 then 
				local sx = v.point.x
				local sy = v.point.y
				ms = ms .. "ML"
				points[mi+0] = sx
				points[mi+1] = sy
				
				points[mi+2] = sx + v.dir.x * self.drawLen
				points[mi+3] = sy + v.dir.y * self.drawLen
				mi += 4
			end
		end
	end
	
	self.path:setLineThickness(3,0.1) -- Outline width
	self.path:setFillColor(0,0) --Fill color
	self.path:setLineColor(color or 0xC0C0C0) --Line color
	self.path:setPath(ms,points)
end
--
function Editor:appResize()
	local minX,minY,maxX,maxY = app:getLogicalBounds()
	local w = -minX + maxX
	local h = -minY + maxY
	
	self.spawnX = minX + w / 2
	self.spawnY = minY + h / 2
	
	self.minX = minX
	self.minY = minY
	self.maxX = maxX
	self.maxY = maxY
end