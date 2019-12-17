app @ application
app:setBackgroundColor(0x323232)
app:configureFrustum(120)

require "FastNoise"

local colorArray = {
	{h = 0.3, color = {52,99,195,255}},
	{h = 0.4, color = {54,102,198,255}},
	{h = 0.45, color = {209,208,128,255}},
	{h = 0.55, color = {88,151,24,255}},
	{h = 0.6, color = {63,106,20,255}},
	{h = 0.7, color = {92,68,61,255}},
	{h = 0.9, color = {75,60,55,255}},
	{h = 1, color = {255,255,255,255}},
}

function rgb2hex(r, g, b)
	return (r << 16) + (g << 8) + b
end

function meshGrid(w, h, cell, extrusion)
	extrusion = extrusion or 50
	local m = Mesh.new(true)
	
	local v = 1
	local i = 1
	
	local n = Noise.new()
	n:setFrequency(0.04)
	n:setFractalOctaves(10)
	n:setNoiseType(Noise.SIMPLEX_FRACTAL)
	
	local tex = n:generateTexture(w,h,true,nil,{colors = colorArray})
	m:setTexture(tex)
	
	for y = 1, h+1 do 
		for x = 1, w+1 do 
			local nv = n:noise(x,y)
			
			m:setVertex(v,(x-1)*cell, (y-1)*cell, nv*extrusion)
			
			m:setTextureCoordinate(v, x-1, y-1)
			
			if (x <= w and y <= h) then 
				local a = y*(w+1)+x+1
				m:setIndex(i+0, v)
				m:setIndex(i+1, v+1)
				m:setIndex(i+2, a)
				m:setIndex(i+3, v)
				m:setIndex(i+4, a)
				m:setIndex(i+5, a-1)
				i += 6
			end
			v += 1
		end
	end
	return m
end

function rectMesh(w, h, cell, color, alpha)
	local m = Mesh.new(true)
	m:setVertex(1, 0, 0, 0)
	m:setVertex(2, w*cell, 0, 0)
	m:setVertex(3, w*cell, h*cell, 0)
	m:setVertex(4, 0, h*cell, 0)
	m:setColorArray(color,alpha, color,alpha, color,alpha, color,alpha)
	m:setIndexArray(1,2,3, 1,3,4)
	return m
end

local w,h, cell = 128,128,16

water = rectMesh(w, h, cell, 0x0000ff, 0.5)
water:setAnchorPoint(.5,.5)

local m = meshGrid(w,h, cell, 255)
m:setAnchorPoint(.5,.5)
stage:addChild(m)
stage:addChild(water)

stage:setPosition(app:getContentWidth() / 2, app:getContentHeight() / 2)
stage:setRotationX(45)

local timer = 0

stage:addEventListener(Event.ENTER_FRAME, function(e)
	local dt = e.deltaTime
	timer += dt
	stage:setZ(math.sin(timer)*200)
	stage:setRotation(stage:getRotation() + 25 * dt)
end)
