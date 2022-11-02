application:setBackgroundColor(0x323232)
require "ImGui"
require "TablesDemo"

local ui = ImGui.new() 
local IO = ui:getIO()

function onWindowResize()
	local minX, minY, maxX, maxY = application:getLogicalBounds()
	local W, H = maxX - minX, maxY - minY
	
	ui:setPosition(minX, minY)
	IO:setDisplaySize(W, H)
end

local function onDrawGui(e)
	ui:newFrame(e.deltaTime)
	
	showDemoWindowTables(ui)
	
	ui:updateCursor()
	ui:render()
	ui:endFrame()
end

onWindowResize()
stage:addEventListener("enterFrame", onDrawGui)
stage:addEventListener("applicationResize", onWindowResize)
stage:addChild(ui)
