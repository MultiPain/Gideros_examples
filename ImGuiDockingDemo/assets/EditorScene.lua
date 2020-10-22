--!NOEXEC

local window_flags = ImGui.WindowFlags_NoTitleBar | ImGui.WindowFlags_NoCollapse | ImGui.WindowFlags_NoResize | ImGui.WindowFlags_NoMove | ImGui.WindowFlags_NoBringToFrontOnFocus | ImGui.WindowFlags_NoNavFocus | ImGui.WindowFlags_MenuBar

EditorScene = Core.class(Sprite)

function EditorScene:init()	
	self.board = Board.new{
		offset = 10,
		xoff = .5, yoff = .5
	}
	self.board:generate(9, 9)
	
	self.imgui = ImGui.new()
	self.imgui:captureMouseFromApp(true)
	self:addChild(self.imgui)
	
	self:addChild(self.board)
	
	local IO = self.imgui:getIO()
	--IO:setMouseDrawCursor(true)
	IO:setIniFilename(nil) -- disable INI file (new API)
	IO:addConfigFlags(ImGui.ConfigFlags_DockingEnable)
	
	self:loadStyles()
	
	self:appResize()
	self:addEventListener("enterFrame", self.drawGUI, self)
	self:addEventListener("applicationResize", self.appResize, self)
	
	local c, a = self.imgui:getStyle():getColor(ImGui.Col_WindowBg)
	app:setBackgroundColor(c)
	
	------------------------------------------------------------------
	
	self.showLog = true
	self.showStyleEditor = true
end
--
function EditorScene:loadStyles()
	local style = self.imgui:getStyle()
	
	style:setColor(ImGui.Col_TabHovered, 0x54575b, 0.83)
	style:setColor(ImGui.Col_NavWindowingHighlight, 0xffffff, 0.70)
	style:setColor(ImGui.Col_FrameBgActive, 0xababaa, 0.39)
	style:setColor(ImGui.Col_PopupBg, 0x212426, 1.00)
	style:setColor(ImGui.Col_DragDropTarget, 0x1ca3ea, 1.00)
	style:setColor(ImGui.Col_FrameBgHovered, 0x616160, 1.00)
	style:setColor(ImGui.Col_ScrollbarBg, 0x050505, 0.53)
	style:setColor(ImGui.Col_DockingEmptyBg, 0x333333, 1.00)
	style:setColor(ImGui.Col_ResizeGripActive, 0x4296f9, 0.95)
	style:setColor(ImGui.Col_FrameBg, 0x40403f, 1.00)
	style:setColor(ImGui.Col_Separator, 0x6e6e7f, 0.50)
	style:setColor(ImGui.Col_Button, 0x40403f, 1.00)
	style:setColor(ImGui.Col_Header, 0x383838, 1.00)
	style:setColor(ImGui.Col_ScrollbarGrabActive, 0x828282, 1.00)
	style:setColor(ImGui.Col_ModalWindowDimBg, 0xcccccc, 0.35)
	style:setColor(ImGui.Col_NavWindowingDimBg, 0xcccccc, 0.20)
	style:setColor(ImGui.Col_TabUnfocused, 0x141416, 1.00)
	style:setColor(ImGui.Col_HeaderHovered, 0x40403f, 1.00)
	style:setColor(ImGui.Col_BorderShadow, 0x000000, 0.00)
	style:setColor(ImGui.Col_Border, 0x6e6e7f, 0.50)
	style:setColor(ImGui.Col_HeaderActive, 0xababaa, 0.39)
	style:setColor(ImGui.Col_NavHighlight, 0x4296f9, 1.00)
	style:setColor(ImGui.Col_ChildBg, 0x212426, 1.00)
	style:setColor(ImGui.Col_TextSelectedBg, 0x4296f9, 0.35)
	style:setColor(ImGui.Col_TitleBg, 0x141416, 1.00)
	style:setColor(ImGui.Col_PlotHistogramHovered, 0xff9900, 1.00)
	style:setColor(ImGui.Col_PlotHistogram, 0xe6b200, 1.00)
	style:setColor(ImGui.Col_ScrollbarGrab, 0x4f4f4f, 1.00)
	style:setColor(ImGui.Col_CheckMark, 0x1ca3ea, 1.00)
	style:setColor(ImGui.Col_ButtonActive, 0xababaa, 0.39)
	style:setColor(ImGui.Col_PlotLines, 0x9c9c9b, 1.00)
	style:setColor(ImGui.Col_TextDisabled, 0x80807f, 1.00)
	style:setColor(ImGui.Col_ScrollbarGrabHovered, 0x696968, 1.00)
	style:setColor(ImGui.Col_Text, 0xffffff, 1.00)
	style:setColor(ImGui.Col_DockingPreview, 0x4296f9, 0.70)
	style:setColor(ImGui.Col_TitleBgActive, 0x141416, 1.00)
	style:setColor(ImGui.Col_TabUnfocusedActive, 0x212426, 1.00)
	style:setColor(ImGui.Col_SliderGrabActive, 0x1480b7, 1.00)
	style:setColor(ImGui.Col_ResizeGrip, 0x000000, 0.00)
	style:setColor(ImGui.Col_Tab, 0x141416, 0.83)
	style:setColor(ImGui.Col_TitleBgCollapsed, 0x000000, 0.51)
	style:setColor(ImGui.Col_ResizeGripHovered, 0x4a4c4f, 0.67)
	style:setColor(ImGui.Col_TabActive, 0x3b3b3d, 1.00)
	style:setColor(ImGui.Col_WindowBg, 0x212426, 1.00)
	style:setColor(ImGui.Col_SeparatorActive, 0x4296f9, 0.95)
	style:setColor(ImGui.Col_SeparatorHovered, 0x696b70, 1.00)
	style:setColor(ImGui.Col_PlotLinesHovered, 0xff6e59, 1.00)
	style:setColor(ImGui.Col_SliderGrab, 0x1ca3ea, 1.00)
	style:setColor(ImGui.Col_ButtonHovered, 0x616160, 1.00)
	style:setColor(ImGui.Col_MenuBarBg, 0x242423, 1.00)
	
	style:setWindowRounding(0)
	style:setChildRounding(0)
	style:setPopupRounding(3)
	style:setFrameRounding(3)
	style:setScrollbarRounding(0)
	style:setGrabRounding(3)
	style:setTabRounding(0)
end
--
function EditorScene:drawGUI(e)
	local UI = self.imgui
	
	UI:newFrame(e)
	local dockspace_id = UI:getID("root")
	
	if (not UI:dockBuilderCheckNode(dockspace_id)) then 
		self:createDock(UI, dockspace_id)
	end
	
	local IO = self.imgui:getIO()
	local w, h = IO:getDisplaySize()
	UI:setNextWindowPos(0, 0)
	UI:setNextWindowSize(w, h )
	
	UI:pushStyleVar(ImGui.StyleVar_WindowRounding, 0)
	UI:pushStyleVar(ImGui.StyleVar_WindowBorderSize, 0)
	UI:pushStyleVar(ImGui.StyleVar_WindowPadding, 0, 0)
	--UI:pushStyleColor(ImGui.Col_WindowBg, 0, 0)
	if (UI:beginWindow("DockSpace Demo", nil, window_flags)) then 
		UI:popStyleVar(3)
		--UI:popStyleColor()
		
		UI:dockSpace(dockspace_id, 0, 0, ImGui.DockNodeFlags_NoWindowMenuButton | ImGui.DockNodeFlags_NoCloseButton)
		
		if (UI:beginMenuBar()) then 
			if (UI:beginMenu("File")) then 
				if (UI:menuItem("Open", "CTRL+O")) then 
					
				end
				if (UI:menuItem("Save", "CTRL+S")) then 
					
				end
				if (UI:menuItem("Save as", "CTRL+SHIFT+S")) then 
					
				end
				UI:endMenu()
			end 
			if (UI:beginMenu("Windows")) then 
				if (UI:menuItem("Log", nil, self.showLog)) then 
					self.showLog = not self.showLog
				end
				if (UI:menuItem("Style editor", nil, self.showStyleEditor)) then 
					self.showStyleEditor = not self.showStyleEditor
				end
				UI:endMenu()
			end
			UI:endMenuBar()
		end
	end
	
	UI:endWindow()
	
	if (UI:beginWindow("Grid", nil, ImGui.WindowFlags_NoBackground | ImGui.WindowFlags_NoMove)) then
		local x1, y1, x2, y2 = UI:getWindowBounds()
		local w = x2 - x1
		local h = y2 - y1
		local dx = (w - self.board:getWidth()) / 2
		local dy = (h - self.board:getHeight()) / 2
		self.board:setPosition(x1 + dx, y1 + dy)
		self.board:setClip(-dx, -dy, w, h <> 0)
		
		UI:text(("[%f x %f] [%f, %f]"):format(w, h, dx, dy))
	end
    UI:endWindow()
	
	if (self.showLog) then 
		self.showLog = UI:showLog("Log", self.showLog, ImGui.WindowFlags_NoMove)
	end
	
	if (UI:beginWindow("Properties", nil, ImGui.WindowFlags_NoMove | ImGui.WindowFlags_NoResize)) then
		self:drawProperties(UI)
	end
    UI:endWindow()
	
	if (self.showStyleEditor) then
		self.showStyleEditor = UI:showLuaStyleEditor("Style editor", self.showStyleEditor, ImGui.WindowFlags_NoMove)
	end
	
	UI:updateMouseCursor() -- set cursor to ImGui's current cursor using application:set("cursor", cursorName)
	
	UI:render()
	UI:endFrame()
end
--
function EditorScene:createDock(UI, dockspace_id)
	UI:dockBuilderRemoveNode(dockspace_id)
	UI:dockBuilderAddNode(dockspace_id)
	
	-- split main node into 2 (left and right node), return left panel id AND modified dockspace id
	local dock_id_left,_,dockspace_id= UI:dockBuilderSplitNode(dockspace_id, ImGui.Dir_Left, 0.2, nil, dockspace_id)
	local dock_id_right,_,dockspace_id= UI:dockBuilderSplitNode(dockspace_id, ImGui.Dir_Right, 0.5, nil, dockspace_id)
	
	-- split right node into 2, return bottom panel id
	local dock_id_bottom = UI:dockBuilderSplitNode(dockspace_id, ImGui.Dir_Down, 0.2, nil, dockspace_id)
	
	-- split right node into 2 (but in different direction), return top panel id
	local dock_id_top = UI:dockBuilderSplitNode(dockspace_id, ImGui.Dir_Up, 0.7, nil, dockspace_id)

	UI:dockBuilderDockWindow("Grid", dock_id_top)
	UI:dockBuilderDockWindow("Log", dock_id_bottom)
	UI:dockBuilderDockWindow("Properties", dock_id_left)
	UI:dockBuilderDockWindow("Style editor", dock_id_right)
	UI:dockBuilderFinish(dockspace_id)
end
--
function EditorScene:drawProperties(UI)
	UI:pushID(1)
	UI:text("Board size:") UI:sameLine()
	local w, h = UI:sliderInt2("", self.board.w, self.board.h, 3, 9)
	if (self.board.w ~= w or self.board.h ~= h) then
		self.imgui:writeLog(("Size changed [%i x %i] -> [%i x %i]"):format(self.board.w, self.board.h, w, h))
		self.board:resize(w, h)
	end
	UI:separator()
	
end
--
function EditorScene:appResize()
	self.imgui:onAppResize()
	
	local minX, minY, maxX, maxY = application:getLogicalBounds()
	local sx = app:getLogicalScaleX()
	local sy = app:getLogicalScaleY()
	
	self.imgui:setScale(1 / sx, 1 / sy)
	self.imgui:setPosition(minX, minY)
	
	local IO = self.imgui:getIO()
	IO:setDisplaySize((maxX - minX) * sx, (maxY - minY) * sy)
end