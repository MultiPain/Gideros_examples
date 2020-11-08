TestScene = Core.class(Sprite)

local function dummyConstraints(x,y, w,h, dw,dh) return dw,dh end

function TestScene:init()
	self.imgui = ImGui.new()
	self.imgui:captureMouseFromApp(true)
	self.imgui:setAutoUpdateCursor(true)
	self:addChild(self.imgui)
	
	local IO = self.imgui:getIO()
	IO:setIniFilename(nil)
	IO:setLogFilename("|D|log.txt")
	
	self:appResize()
	self:addEventListener("enterFrame", self.drawGUI, self)
	self:addEventListener("applicationResize", self.appResize, self)
	
	------------------------------------------------------------------
	self.cachedDirs = {} 	-- cached dirs and files (refilled only when directory is changed)
	self.fileName = "" 		-- current file name in open/save dialog
	self.openModalType = "" -- type of modal window ("Save file" or "Open file")
	self.currentItem = 0 	-- current selected item in open dialog
end
-- callbacks
function TestScene:onSaveDialogOK(dir)
	
end
--
function TestScene:onSaveDialogError(errorMessage)
	
end
--
function TestScene:onOpenDialogOK(dir)
	
end
--
function TestScene:onOpenDialogError(errorMessage)
	
end
--
function TestScene:updateDirCache(dir)
	if (self.cachedDirs.isUpdated) then 
		return
	end
	
	self.cachedDirs.isUpdated = true
	self.cachedDirs.file = {}
	self.cachedDirs.directory = {}
	
	-- scane directory
	for entry in lfs.dir(dir) do
		if (entry ~= "." and entry ~= "..") then
			local path = dir.."\\"..entry
			local attributes = lfs.attributes(path)
			local t = self.cachedDirs[attributes.mode] -- pick "self.cachedDirs.file" or "self.cachedDirs.directory" table
			if (t) then
				t[#t+1] = {
					path = path,
					name = entry,
					attr = attributes,
					selected = false
				}
			end
		end
	end
end
-- 
function TestScene:drawFileDialog(UI)
	-- setup min and max sizes
	UI:setNextWindowSizeConstraints(800, 400, 1920, 1080)
	-- draw window
	-- 2d argument draws "X" on window
	if (UI:beginPopupModal(self.openModalType, true, 0, dummyConstraints)) then 
		local isOpenMode = self.openModalType == "Open file"
		local currentDir = lfs.currentdir()
		
		if (UI:button("Back")) then
			-- reset selected item and selected filename 
			self.currentItem = 0
			self.fileName = ""
			-- change dir
			currentDir = currentDir:match("(.*[/\\])")
			lfs.chdir(currentDir)
			-- force to rewrite dirs
			self.cachedDirs.isUpdated = false
		end
		UI:sameLine()
		
		-- show path, write dir to tmp variable
		local tmp, flag = UI:inputText("Path", currentDir, 256, ImGui.InputTextFlags_EnterReturnsTrue)
		-- if input ends
		if (flag) then 
			-- check if dir exists
			local status = lfs.chdir(tmp)
			if (status) then
				-- change dir
				currentDir = tmp
				lfs.chdir(currentDir)
				-- force to rewrite dirs
				self.cachedDirs.isUpdated = false
			end
		end
		
		UI:separator()
		
		self:updateDirCache(currentDir)
		
		-- draw folders as buttons
		local frameHeightWithSpacing = UI:getFrameHeightWithSpacing()
		UI:beginChild("DIRS", 300, -frameHeightWithSpacing, ImGui.WindowFlags_HorizontalScrollbar)
		for _,data in ipairs(self.cachedDirs.directory) do 
			if (UI:button(data.name, -1, 0)) then 
				lfs.chdir(data.path)
				self.cachedDirs.isUpdated = false
			end
		end
		UI:endChild()
		UI:sameLine()
		
		UI:beginChild("FILES", 0, -frameHeightWithSpacing)
		
		-- draw table of files
		UI:columns(4)
		UI:text("Name")			UI:nextColumn()
		UI:text("Change")		UI:nextColumn()
		UI:text("Modification") UI:nextColumn()
		UI:text("Size") 		UI:nextColumn()
		UI:separator()
		
		for i,data in ipairs(self.cachedDirs.file) do 
			-- files are selectables
			if (ImGui:selectable(data.name, self.currentItem == i)) then 
				self.currentItem = i
				self.fileName = data.name
			end
			
			-- draw last change date
			UI:nextColumn()
			UI:text(os.date('%c', data.attr.change))
			UI:nextColumn()
			-- draw last modification date
			UI:text(os.date('%c', data.attr.modification))
			UI:nextColumn()
			
			-- calculate text object position aligned to the right edge
			local text = ("%.2f KB"):format(data.attr.size / 1024)
			local spaceX = UI:getStyle():getItemSpacing()
			local tw, th = UI:calcTextSize(text)
			UI:setCursorPosX(UI:getCursorPosX() + UI:getColumnWidth() - tw - UI:getScrollX() - 2 * spaceX);
			-- draw file size 
			UI:text(text)
			UI:nextColumn()
		end
		UI:endChild()
		
		UI:text("File name:")
		UI:sameLine()
		
		local w = UI:getContentRegionAvail()
		-- leave 150 pixels for buttons
		UI:setNextItemWidth(w - 150)
		local inputFlag = false
		-- draw filename input box
		self.fileName, inputFlag = UI:inputText("", self.fileName, 64, ImGui.InputTextFlags_EnterReturnsTrue)
		UI:sameLine()
		
		w = UI:getContentRegionAvail()
		if (isOpenMode) then 
			-- search and highlight filename
			if (self.fileName ~= "") then 
				local itemFound = false
				for i,data in ipairs(self.cachedDirs.file) do 	
					if (data.name == self.fileName) then 
						itemFound = true
						self.currentItem = i
						break
					end
				end
				if (not itemFound) then 
					self.currentItem = 0
				end
			end
			
			-- if ENTER (on input box) or button was pressed
			if (UI:button("Open", w * .5) or inputFlag) then
				-- try to open file
				if (self.fileName ~= "") then
					local status, error = pcall(self.onSaveDialogOK, self, currentDir .. "\\" .. self.fileName)
					if (not status) then 
						self:onSaveDialogError(error)
					end
				end
				
				UI:closeCurrentPopup()
				self.fileName = ""
			end
		else
			if (UI:button("Save", w * .5) or inputFlag) then 
				local status, error = pcall(self.onOpenDialogOK, self, currentDir .. "\\" .. self.fileName)
				if (not status) then 
					self:onOpenDialogError(error)
				else
					self.cachedDirs.isUpdated = false
				end
				
				UI:closeCurrentPopup()
				self.fileName = ""
			end
		end
		UI:sameLine()
		
		w = UI:getContentRegionAvail()
		if (UI:button("Cancel", w) or UI:isKeyPressed(KeyCode.ESC)) then 
			UI:closeCurrentPopup()
			self.fileName = ""
		end
		
		UI:endPopup()
	end
end
--
function TestScene:drawGUI(e)
	local UI = self.imgui
	
	UI:newFrame(e)
	
	UI:pushStyleColor(ImGui.Col_WindowBg, 0, 0)
	if (UI:beginFullScreenWindow("File dialog demo", nil, ImGui.WindowFlags_MenuBar)) then 
		UI:popStyleColor()
		
		if (UI:beginMenuBar()) then 
			local openModal = false
			
			if (UI:beginMenu("File")) then 
				if (UI:menuItem("Open", "CTRL+O")) then 
					openModal = true -- you cant open popups from menu bars (ImGui problem)
					self.openModalType = "Open file"
				end
				if (UI:menuItem("Save as", "CTRL+SHIFT+S")) then 
					openModal = true -- you cant open popups from menu bars (ImGui problem)
					self.openModalType = "Save file"
				end
				UI:endMenu()
			end 
			-- see: https://github.com/ocornut/imgui/issues/331
			if (openModal) then
				self.currentItem = 0
				UI:openPopup(self.openModalType)
			end
			
			self:drawFileDialog(UI)
			UI:endMenuBar()
		end
	end
	UI:endWindow()
	
	UI:render()
	UI:endFrame()
end
-- adapt ImGui to fill window size
function TestScene:appResize()
	local minX, minY, maxX, maxY = application:getLogicalBounds()
	local sx = application:getLogicalScaleX()
	local sy = application:getLogicalScaleY()
	
	self.imgui:setScale(1 / sx, 1 / sy)
	self.imgui:setPosition(minX, minY)
	
	local IO = self.imgui:getIO()
	IO:setDisplaySize((maxX - minX) * sx, (maxY - minY) * sy)
end
