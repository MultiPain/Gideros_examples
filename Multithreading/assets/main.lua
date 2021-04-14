require "Threads"
require "Worker"

USE_THREADS @ true -- change this to see different results
GRIDS_COUNT @ 16
SIZE @ 64

AREA @ &SIZE * SIZE&

print("Max iteration per frame:", GRIDS_COUNT * AREA)

local fpsTimer = 0
local fpsFiled = TextField.new(nil, "FPS")
fpsFiled:setScale(2)
fpsFiled:setPosition(10, 20)
stage:addChild(fpsFiled)

local worker
if (USE_THREADS) then 
	local CORES = Thread.getNumLogicalCores()
	-- use all logical cores
	worker = Worker.new(CORES)
end
--
local function printProfileResult(name, len)
	len = len or name:len()
	local result=Core.profilerReport()
	for k,v in pairs(result) do
		local found=false
		for k2,v2 in pairs(v) do
			if found and k2=="time" then print(v1,v2) end
			if k2=="name" and string.sub(v2,1,len)==name then v1=v2 found=true end
		end
	end
end

-- function to execute (for threads, data must be isolated from the main thread, do not use gobal vars, gideros objects, etc)
local function task(iter)
	local a = 0
	for i = 1, iter do 
		a += math.sqrt((i * 5) // 2) * 10
	end
	return a
end


local function workerFunction()
	worker:wait()
end
--
function multithread(e)
	local dt = e.deltaTime
	fpsTimer += dt
	if (fpsTimer > 1) then
		fpsTimer = 0
		fpsFiled:setText(1 // dt)
	end
	
	for i = 1, GRIDS_COUNT do
		worker:pushTask(task, AREA)
	end
	
	Core.profilerReset()
	Core.profilerStart()
	workerFunction()
	Core.profilerStop()

	printProfileResult("workerFunction")
end

function noMultithread(e)
	local dt = e.deltaTime
	fpsTimer += dt
	if (fpsTimer > 1) then
		fpsTimer = 0
		fpsFiled:setText(1 // dt)
	end
	
	Core.profilerReset()
	Core.profilerStart()
	for i = 1, GRIDS_COUNT do
		task(AREA)
	end
	Core.profilerStop()

	printProfileResult("task")
end

if (USE_THREADS) then
	stage:addEventListener("enterFrame", multithread)
else
	stage:addEventListener("enterFrame", noMultithread)
end