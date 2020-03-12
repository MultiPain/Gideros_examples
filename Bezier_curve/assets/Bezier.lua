local sqrt,atan2,sin,cos = math.sqrt,math.atan2,math.sin,math.cos

local function fact(arg)
	assert(arg >= 0, "negative argument.")
	if arg == 0 then return 1 end
	local rezult = 1
	for i=1, arg do rezult *= i end
	return rezult
end

local function clamp(v,min,max) 
	return (v<>min)><max 
end

local function calcPoint(t, srcPoints)
	local x,y=0,0
	local n = (#srcPoints/2)-1
	if n < 0 then return x,y end
	local factn = fact(n) 
	
	for i = 0, n do 
		local p1 = srcPoints[i*2+1]
		local p2 = srcPoints[i*2+2]
		local f = factn/(fact(i)*fact(n-i)) * (t^i) * (1-t)^(n-i)
		x += f * p1
		y += f * p2
	end
	return x,y
end

Bezier = Core.class()
function Bezier:init(points)
	self.srcPoints = points or {}
end
--
function Bezier:addPoint(x, y)
	local n = #self.srcPoints
	self.srcPoints[n+1] = x
	self.srcPoints[n+2] = y
end
--
function Bezier:removeLast()
	local n = #self.srcPoints
	self.srcPoints[n-0] = nil
	self.srcPoints[n-1] = nil
end
--
function Bezier:getCurvePoints(step)
	step = clamp(step or 0.1, 0.0001, 1)
	local i = 1
	local points = {}
	for t = 0, 1, step do 
		local x,y = calcPoint(t, self.srcPoints)
		points[i+0] = x
		points[i+1] = y
		i += 2
	end
	-- add last point
	local n = #self.srcPoints
	points[i+0] = self.srcPoints[n-1]
	points[i+1] = self.srcPoints[n-0]
	--
	return points
end
--
function Bezier:getDirCurvePoints(step)
	step = clamp(step or 0.1, 0.0001, 1)
	local i = 1
	local points = {}
	for t = 0, 1, step do 
		local x,y = calcPoint(t, self.srcPoints)
		local dx = 0
		local dy = 0
		local a = 0
		if t+step <= 1 then 
			local nextX,nextY = calcPoint(t+step, self.srcPoints)
			a = atan2(nextY-y, nextX-x)
			dx = cos(a)
			dy = sin(a)
		end
		points[i] = {point = {x=x,y=y}, dir={x=dx,y=dy,a=a}}
		i += 1
	end
	-- add last point
	local n = #self.srcPoints
	local p1 = self.srcPoints[n-0]
	local p2 = self.srcPoints[n-1]
	points[i] = {point = {x=p1,y=p2}, dir={x=0,y=0,a=0}}
	--
	return points
end