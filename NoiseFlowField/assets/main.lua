app @ application
app:setBackgroundColor(0x323232)

local random,cos,sin = math.random,math.cos,math.sin

TWO_PI @ 6.28318530718
DRAW_VECTORS @ false
THRESHOLD @ true
THRESHOLD_ALPHA @ 0.1
TIME_SCALE @ 1
PCOUNT @ 1000
GRID_W @ 48
GRID_H @ 24

-- Setup noise
require "FastNoise"
local N = Noise.new()
--N:setFrequency(0.05)
--N:setNoiseType(Noise.SIMPLEX_FRACTAL)
--N:setFractalType(Noise.FBM)
--N:setFractalGain(0.7)

-- Get screen resolution
local _,_,ScrW,ScrH = app:getDeviceSafeArea(true)

-- Calculate cell size
local cellW = ScrW / GRID_W
local cellH = ScrH / GRID_H

-- Create particles
local particles = Particles.new()
local particlesData = {}

-- To create a threshold effect, create RenderTarget
local Canvas = RenderTarget.new(ScrW, ScrH)
local CanvasBG = Pixel.new(0, THRESHOLD_ALPHA, ScrW, ScrH)
local Output = Bitmap.new(Canvas)

-- Layer for vectors and grid cells
local MainLayer = Sprite.new()

-- Grid
local noiseData = {}

-- Lemits vectors length
function limitVec(x,y,len)
	local mag = math.sqrt(x*x+y*y)
	if mag > len and len ~= 0 then 
		local ratio = len / mag
		
		x *= ratio
		y *= ratio
	end
	return x, y
end

-- Initial grid setup
function setupBoard(flag)
	for y = 1, GRID_H do 
		noiseData[y] = {}
		for x = 1, GRID_W do 
			local t = {}
			
			-- create a chess like board
			if (x+y)%2 == 0 then 
				t.chess = Pixel.new(0xffffff, THRESHOLD_ALPHA / 5, cellW, cellH)
				t.chess:setPosition(
					(x-1) * cellW,
					(y-1) * cellH
				)
				MainLayer:addChild(t.chess)
			end
			
			-- noise vector
			t.vec = Pixel.new(0xffffff, 1, 20, 2)
			t.vec:setPosition(
				(x-1) * cellW + cellW / 2,
				(y-1) * cellH + cellH / 2
			)
			MainLayer:addChild(t.vec)
			
			-- noise value
			t.value = 0
			
			noiseData[y][x] = t
		end
	end
	
	-- create actual particles
	for i = 1, PCOUNT do 
		local params = {
			-- acceleration speed
			acceleration = random(10, 40),
			-- maximum movement speed
			maxSpeed = random(1, 10),
			-- velocity
			vx = 0, vy = 0,
		}
		particlesData[i] = params
		
		particles:addParticles{{
			-- initial position
			x = random(ScrW), y = random(ScrH),
			-- initial color
			color = random(0xffffff), alpha = random(),
			-- initial size
			size = random(4, 16), 
		}}
	end
	
	if not flag then 
		if DRAW_VECTORS then stage:addChild(MainLayer) end
		stage:addChild(particles)
	else
		stage:addChild(Output)
	end
end

local timer = 0 
function updateBoard(e)
	local dt = e.deltaTime
	timer += dt * TIME_SCALE
	-- generate noise grid
	for y = 1, GRID_H do 
		for x = 1, GRID_W do 
			-- get grid cell
			local cell = noiseData[y][x]
			-- get noise value and normolize it so it will be in range [0..1] (instead of [-1..1]
			cell.value = (N:noise3D(x,y,timer) + 1) / 2
			-- rotate vector
			cell.vec:setRotation(360 * cell.value)
			-- precalculate acceleration vector
			local ang = TWO_PI * cell.value
			cell.ax = cos(ang)
			cell.ay = sin(ang)
		end
	end
	
	for i = 1, PCOUNT do 
		-- get current particle position
		local x, y = particles:getParticlePosition(i)
		
		-- if out of bounds, move to opposite side
		if x < 1 then x = ScrW-1 end
		if x > ScrW-1 then x = 1 end
		if y < 1 then y = ScrH-1 end
		if y > ScrH-1 then y = 1 end
		
		-- translate global position to grid's local position
		local cx = 1 + x // cellW
		local cy = 1 + y // cellH
		
		-- get grid cell
		local cell = noiseData[cy][cx]
		
		-- get vector rotation (e.g. angle) in rad.
		local ang = ^<(cell.value * 360)
		-- get info about particle
		local data = particlesData[i]
		-- scale acceleration vector
		local vx = cell.ax * data.acceleration * dt
		local vy = cell.ay * data.acceleration * dt
		-- apply acceleration and limit velocity
		data.vx,data.vy = limitVec(data.vx + vx,data.vy + vy, data.maxSpeed)
		-- move particle
		x += data.vx
		y += data.vy
		particles:setParticlePosition(i, x,y)
	end
	
	if THRESHOLD then 
		Canvas:draw(CanvasBG)
		Canvas:draw(particles)
		if DRAW_VECTORS then 
			Canvas:draw(MainLayer)
		end
	end
end

setupBoard(THRESHOLD)
stage:addEventListener("enterFrame", updateBoard)