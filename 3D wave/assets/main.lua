app:configureFrustum(120)
app:setBackgroundColor(0x404040)

local CW,CH=app:getContentWidth(),app:getContentHeight()
GR @ 12
MAX_D @ 4
MAX_H @ 500
timeScale @ 2
local w,h,d,off = 90,100,100,0
local t = {}
for x = 0, GR*2-1 do 
	t[x+1] = {}
	for z = 0, GR*2-1 do 
		local b1 = Box.new(w,h,d)
		
		b1:setX(x*(w+off) - GR*w - 0)
		b1:setZ(-z*(w+off) + GR*w)
		b1:setBottomColor(0xff0000,1)
		b1:setTopColor(0x0077be,1)
		b1:setAnchorPoint(0.5,0.5,0.5)
		stage:addChild(b1)
		t[x+1][z+1]=b1
	end
end

stage:setPosition(CW/2,CH/2)
stage:setRotationX(-35)
stage:setZ(-2000)

function dist(x1,y1, x2,y2) return math.sqrt((x2-x1)^2 + (y2-y1)^2) end
function map(v, minC, maxC, minD, maxD) return (v - minC) / (maxC - minC) * (maxD - minD) + minD end

local timer = 0
stage:addEventListener(Event.ENTER_FRAME, function(e)
	local dt = e.deltaTime
	timer += dt
	
	stage:setRotationY(stage:getRotationY() + 10 * dt)
	for z = 1, GR*2 do 
		for x = 1, GR*2 do 
			local box = t[x][z]
			local d = dist(x,z,GR,GR)
			local offset = map(d, 0, MAX_D, -1,1)
			local h = 40+(1+math.sin(offset-timer*timeScale))*MAX_H
			
			box:setHeight(h)
			box:setAnchorPoint(0.5,0.5)
		end
	end
end)