app @ application
app:setBackgroundColor(0x323232)
app:configureFrustum(120)

require "FastNoise"

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
	
	for y = 1, h+1 do 
		for x = 1, w+1 do 
			local nv = n:noise(x,y)
			
			m:setVertex(v,(x-1)*cell, (y-1)*cell, nv*extrusion)
			
			local gr = ((nv+1)/2)*255
			m:setColor(v, rgb2hex(gr,gr,gr), 1)
			
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

local m = meshGrid(128, 128, 8)
m:setAnchorPoint(.5,.5)
stage:setPosition(app:getContentWidth() / 2, app:getContentHeight() / 2)
stage:addChild(m)
stage:setRotationX(45)

local timer = 0
stage:addEventListener(Event.ENTER_FRAME, function(e)
	local dt = e.deltaTime
	timer += dt
	stage:setZ(math.sin(timer)*200)
	stage:setRotation(stage:getRotation() + 25 * dt)
end)