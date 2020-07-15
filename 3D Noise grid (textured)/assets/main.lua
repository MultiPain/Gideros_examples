app @ application
app:setBackgroundColor(0x323232)
app:configureFrustum(120)

require "FastNoise"

local colorArray = {
	{0.300000, 0x3463c3},
	{0.400000, 0x3666c6},
	{0.450000, 0xd1d080},
	{0.550000, 0x589718},
	{0.600000, 0x3f6a14},
	{0.700000, 0x5c443d},
	{0.900000, 0x4b3c37},
	{1.000000, 0xffffff},
}

local function meshGrid(width, height, cellSize, extrusion)
	extrusion = extrusion or 50
	local mesh = Mesh.new(true)
	
	local v = 1
	local i = 1
	
	local n = Noise.new()
	n:setFrequency(0.04)
	n:setFractalOctaves(10)
	n:setNoiseType(Noise.SIMPLEX_FRACTAL)
	n:setColorLookup(colorArray)
	
	local tex = n:getTexture(width, height, true)
	mesh:setTexture(tex)
	
	for y = 1, height+1 do 
		for x = 1, width+1 do 
			local nv = n:noise(x, y)
			
			mesh:setVertex(v, (x - 1) * cellSize, (y - 1) * cellSize, nv * extrusion)
			
			mesh:setTextureCoordinate(v, x - 1, y - 1)
			
			if (x <= width and y <= height) then 
				local a = y * (width + 1) + x + 1
				mesh:setIndex(i + 0, v)
				mesh:setIndex(i + 1, v + 1)
				mesh:setIndex(i + 2, a)
				mesh:setIndex(i + 3, v)
				mesh:setIndex(i + 4, a)
				mesh:setIndex(i + 5, a - 1)
				i += 6
			end
			v += 1
		end
	end
	return mesh
end

local function rectMesh(width, height, cellSize, color, alpha)
	local mesh = Mesh.new(true)
	mesh:setVertex(1, 0, 0, 0)
	mesh:setVertex(2, width * cellSize, 0, 0)
	mesh:setVertex(3, width * cellSize, height * cellSize, 0)
	mesh:setVertex(4, 0, height * cellSize, 0)
	mesh:setColorArray(
		color, alpha,
		color, alpha,
		color,alpha,
		color,alpha
	)
	mesh:setIndexArray(1,2,3, 1,3,4)
	return mesh
end


local width, height, cellSize = 128, 128, 16

local waterMesh = rectMesh(width, height, cellSize, 0x0000ff, 0.5)
waterMesh:setAnchorPoint(.5,.5)

local mesh = meshGrid(width, height, cellSize, 255)
mesh:setAnchorPoint(.5,.5)
stage:addChild(mesh)
stage:addChild(waterMesh)

stage:setPosition(app:getContentWidth() / 2, app:getContentHeight() / 2)
stage:setRotationX(45)

local timer = 0
stage:addEventListener(Event.ENTER_FRAME, function(e)
	local dt = e.deltaTime
	
	timer += dt
	
	stage:setZ(math.sin(timer)*200)
	stage:setRotation(stage:getRotation() + 25 * dt)
end)
