require "lfs"
require "ImGui"

ui = ImGui.new()
IO = ui:getIO()
stage:addChild(ui)

RangeStart		= 0.384
RangeEnd		= 0.631
FileLoading		= false
FileReady		= false
FileSelected	= 2
GraphWidth		= 1024
GraphHeight		= 256
ShowLoading		= false
UsePointsGraph	= false
UseHistogram	= false

ImageTexture	= nil -- RenderTarget
Points			= nil -- table of points per channel ({ {channel 1 points}, {channel 2 points} }
FileError		= nil -- io.open() error message

local function getWavProjectFiles(path)
	local t = {}
	
	for file in lfs.dir(path) do
		if file == "." or file == ".." then
			continue
		end
		local fpath = `{path}/{file}`
		local attr = lfs.attributes(fpath)
		
		if attr.mode == "directory" then
			local s = getWavProjectFiles(fpath)
			table.move(s, 1, #s, #t + 1, t)
		elseif file:sub(-3):lower() == "wav" then
			t[#t + 1] = fpath:sub(5)
		end
	end
	
	return t
end

SoundFiles = getWavProjectFiles("|R|")
assert(#SoundFiles > 0, "No WAV files found...")

function map(n, start1, stop1, start2, stop2, withinBounds)
	local v = (n - start1) / (stop1 - start1) * (stop2 - start2) + start2
	
	if not withinBounds then
		return v
	end
	
	if (start2 < stop2) then
		return v <> start2 >< stop2
	else
		return v <> stop2 >< start2
	end
end

function updateWave(width, height, start, finish, data)
	ShowLoading = true
	
	if UsePointsGraph then
		Points = updatePoints(width, height, start, finish, data)
	else
		ImageTexture = updateGraph(width, height, start, finish, data)
	end
	
	ShowLoading = false
end

function updateGraph(desiredWidth, height, start, finish, data)
	local padding = 4
	local ampMin = data.ampMin
	local ampMax = data.ampMax
	local channels = data.channelNum
	local arr = data.samples
	local realLen = #arr
	local halfHeight = height * 0.5
	
	if desiredWidth > realLen then 
		desiredWidth = realLen 
	end
	
	local viewLen = finish - start
	local len = math.floor(realLen * viewLen)
	
	local samplesCount = len / channels
	local interval = samplesCount // desiredWidth
	if interval == 0 then interval = 1 end
	
	local startIdx = math.floor(realLen * start)
	local rtHeight = (height + padding * 2) * channels
	local rtWidth = desiredWidth + padding * 2
	local rt = RenderTarget.new(rtWidth, rtHeight)
	rt:clear(0, 1)
	--[[
	-- draw padding
	rt:clear(0xa0a0a0, 1, 0, 0, rtWidth, padding)
	rt:clear(0xa0a0a0, 1, 0, 0, padding, rtHeight)
	rt:clear(0xa0a0a0, 1, 0, rtHeight - padding, rtWidth, padding)
	rt:clear(0xa0a0a0, 1, rtWidth - padding, 0, padding, rtWidth)
	rt:clear(0xa0a0a0, 1, 0, rtHeight * 0.5 - padding, rtWidth, padding * 2)
	--]]
	
	-- fit samples into screen pixels
	for ch = 1, channels do
		for i = 0, desiredWidth - 1 do
			local v = 0
			
			-- calculate samples avg
			for j = i * interval, (i + 1) * interval - 1 do
				local idx = startIdx + j * channels + ch
				
				if idx > startIdx + len then
					break
				end
				
				v += arr[idx]
			end
			v /= interval
			local x = padding + i
			local clamped = map(v, ampMin, ampMax, -1, 1, true)
			local h = (math.abs(clamped) * halfHeight) <> 1
			local y = padding * ch + halfHeight - h * 0.5 + (ch - 1) * height
			
			rt:clear(0xffffff, 1, x, y, 1, h * 2)
		end
		rt:clear(0xa0a0a0, 1, 0, padding * ch + halfHeight + height * (ch - 1), rtWidth, 2)
	end
	
	return rt
end

function updatePoints(desiredWidth, height, start, finish, data)
	local ampMin = data.ampMin
	local ampMax = data.ampMax
	local channels = data.channelNum
	local arr = data.samples
	local realLen = #arr
	
	if desiredWidth > realLen then desiredWidth = realLen end
	
	local viewLen = finish - start
	local len = math.floor(realLen * viewLen)
	
	local interval = (len / channels) // desiredWidth
	if interval == 0 then interval = 1 end
	local startIdx = math.floor(realLen * start)
	
	local points = {}
	for k = 1, channels do
		points[k] = {}
	end
	
	for i = 0, desiredWidth - 1 do
		for ch = 1, channels do
			local t = points[ch]
			local v = 0
			
			for j = i * interval, (i + 1) * interval - 1 do
				local idx = startIdx + j * channels + ch
				
				if idx > startIdx + len then
					break
				end
				
				v += arr[idx]
			end
			
			t[#t + 1] = map(v / interval, ampMin, ampMax, 0, height)
		end
	end
	
	return points
end

-- async
function startReadingCurrentFile()
	ImageTexture = nil
	Points = nil
	FileLoading = false
	
	Core.asyncCall(function()
		FileError = nil
		FileLoading = true
		FileReady = false
		
		local ok, errorMsg = pcall(function()
			local path = SoundFiles[FileSelected + 1]
			waveFile = WAVreader.new(path)
		end)
		
		FileLoading = false
		
		if ok then
			FileReady = true
			updateWave(GraphWidth, GraphHeight, RangeStart, RangeEnd, waveFile)
		else
			FileError = errorMsg
		end
	end)
end

function onEnterFrame(e)
	local dt = e.deltaTime
	ui:newFrame(dt)
	
	if ui:beginFullScreenWindow("WAV visualizer") then
		local availW, availH = ui:getContentRegionAvail()
		ui:pushItemWidth(availW - 120)
		local fileChanged = false
		
		FileSelected, fileChanged = ui:combo("File", FileSelected, SoundFiles)
		
		ui:beginDisabled(FileLoading)
			local openClicked = ui:button("Open", availW)
			
			local clicked = false
			UsePointsGraph, clicked = ui:checkbox("Use points graph", UsePointsGraph)
			
			if UsePointsGraph then
				ui:sameLine()
				UseHistogram = ui:checkbox("Use histogram", UseHistogram)
			end
			
			if openClicked or clicked or fileChanged then
				startReadingCurrentFile()
			end
		ui:endDisabled()
		
		if FileReady then
			ui:textColored("File is ready", 0x00ff00, 1)
		elseif FileLoading then
			ui:textColored("Reading file...", 0xe6a400, 1)
		else
			ui:textColored("File is NOT ready", 0xff0000, 1)
		end
		
		if FileError then
			ui:textColored(FileError, 0xff0000, 1)
		end
		
		local changedX, changedY, changedRange = false
		
		ui:beginDisabled(not FileReady)
			GraphWidth,  changedX = ui:sliderInt("Image width",  GraphWidth,  128, 4096)
			GraphHeight, changedY = ui:sliderInt("Image height", GraphHeight, 128, 4096)
			RangeStart, RangeEnd, changedRange = ui:dragFloatRange2("View range", RangeStart, RangeEnd, 0.0001, 0, 1, nil, nil, ImGui.SliderFlags_AlwaysClamp)		
		ui:endDisabled()
		
		if changedX or changedY or changedRange then
			Core.asyncCall(updateWave, GraphWidth, GraphHeight, RangeStart, RangeEnd, waveFile)
		end
		
		if ShowLoading then
			ui:text("Loading...")
		end
		
		if ImageTexture and not ShowLoading then
			ui:scaledImage("WAVE", ImageTexture, availW, GraphHeight, ImGui.ImageScaleMode_Stretch)
		end
		
		if Points and not ShowLoading then
			for i, points in ipairs(Points) do
				if UseHistogram then
					ui:plotHistogram(`CH {i}`, points, nil, nil, nil, nil, 0, GraphHeight)
				else
					ui:plotLines(`CH {i}`, points, nil, nil, nil, nil, 0, GraphHeight)
				end
			end
		end
		
		ui:popItemWidth()
	end
	ui:endWindow()
	
	ui:render()
	ui:endFrame()
end

function onAppResize(self, e)
	local minX, minY, maxX, maxY = application:getLogicalBounds()
	ScreenW = maxX - minX
	ScreenH = maxY - minY
	IO:setDisplaySize(ScreenW, ScreenH)
	ui:setPosition(minX, minY)
end

startReadingCurrentFile()
onAppResize()
stage:addEventListener("applicationResize", onAppResize)
stage:addEventListener("enterFrame", onEnterFrame)