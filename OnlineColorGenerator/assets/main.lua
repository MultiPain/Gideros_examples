QUERY_STRING @ |('{"input":[%s,%s,%s,%s,%s],"model":"%s"}')|
COLOR_FORMAT @ |('0x%06X ')|
RGB_FORMAT @ |('[%s,%s,%s]')|
PALETTE_W @ 256
PALETTE_H @ 64

require "ImGui_beta_docking" -- rename to "ImGui_beta" (or "ImGui_beta_docking") if using beta build
require "json"

-- create imgui instance
local imgui = ImGui.new()
stage:addChild(imgui)

local function emptyCallback() end
-- conver rgb color to hex (r,g,b in range [0..255])
local function rgb2hex(r,g,b)
	return (r << 16) + (g << 8) + b
end

-- conver hex to  (r,g,b in range [0..255])
local function hex2rgb(hex)
	local r = (hex >> 16) & 0xff
	local g = (hex >> 8) & 0xff
	local b = (hex >> 0) & 0xff
	return r,g,b
end

-- query color
-- 		data - query text (see http://colormind.io/api-access/)
-- 		completeCallback - function called on request complete (or fail)
-- 		progressCallback - function called on request progress
local function getColors(data, completeCallback, progressCallback)
	completeCallback = completeCallback or emptyCallback
	progressCallback = progressCallback or emptyCallback
	
	local loader = UrlLoader.new(
		"http://colormind.io/api/", 
		UrlLoader.POST, 
		{["Content-Type"] = "application/xml"}, 
		data
	)

	loader:addEventListener(Event.COMPLETE, function(event)
		local data = json.decode(event.data)
		local colors = {}
		for i,v in pairs(data.result) do 
			colors[i] = rgb2hex(v[1], v[2], v[3])
		end
		completeCallback(true, colors)
		loader = nil
	end)
	
	loader:addEventListener(Event.ERROR, function()
		completeCallback(false)
		loader = nil
	end)
	
	loader:addEventListener(Event.PROGRESS, progressCallback)
end

-- window body is drawn on screen
local drawWindow = true
-- generate button is active or not
local active = true
-- last query success status
local lastError = false
-- all generated colors
local cachedColors = {}
-- preview color index
local currentColorIndex = -1
-- mode item index (0 - default" or 1 - "ui")
local modeItem = 0
-- mode list
local modeList = {"default", "ui"}
-- stores color in hex
local queryLockedColors = {}
-- default locked colors structure
for i = 1, 5 do 
	queryLockedColors[i] = {activeFlag = false, color = 0, str = "\"N\""} 
end

local function resetLockedColors()
	for i,v in ipairs(queryLockedColors) do 
		v.color = 0
		v.activeFlag = false
	end
end

local function enterFrame(e)
	imgui:newFrame(e)
	
	-- create window
	drawWindow = imgui:beginWindow("Color generator", nil, 0) -- window without close button
	if (drawWindow) then 
		-- create combox box with 2 modes
		imgui:text("mode")
		imgui:sameLine()
		modeItem = imgui:combo("##mode", modeItem, modeList)
		
		imgui:separator()
		-- locked colors
		for i,v in ipairs(queryLockedColors) do 
			-- create a checkbox
			v.activeFlag = imgui:checkbox("Lock #"..i, v.activeFlag)
			-- if checked draw color picker
			if (v.activeFlag) then 
				imgui:sameLine()
				v.color = imgui:colorEdit3("###"..i, v.color, ImGui.ColorEditFlags_HDR)
				v.str = RGB_FORMAT:format(hex2rgb(v.color))
			-- if not set "str" field to "empty" symbol (required by colormind API)
			else
				v.str = "\"N\""
			end
		end
		
		if (imgui:button("Reset all") and active) then 
			resetLockedColors()
		end
		imgui:separator()
		
		imgui:pushStyleVar(ImGui.StyleVar_Alpha, active and 1 or 0.5)
		if (imgui:button("Generate") and active) then 
			active = false
			local query = QUERY_STRING:format(
				queryLockedColors[1].str,
				queryLockedColors[2].str,
				queryLockedColors[3].str,
				queryLockedColors[4].str,
				queryLockedColors[5].str,
				modeList[modeItem + 1]
			)
			
			getColors(query, function(success, result) 
				active = true
				lastError = not success -- you cant call "openPopup" from callback fro whatever reason, so we use flag
				if (success) then
					local w = PALETTE_W // #result
					local paletteStruct = {}
					paletteStruct.colors = {}
					paletteStruct.lockedColors = {}
					for i,v in ipairs(queryLockedColors) do 
						paletteStruct.lockedColors[i] = {lockedFlag = v.activeFlag, color = v.color}
					end
					
					local texture = RenderTarget.new(PALETTE_W, PALETTE_H)
					for i,v in ipairs(result) do 
						texture:clear(v, 1, (i-1) * (w-1), 0, w, PALETTE_H)
						paletteStruct.colors[i] = v
					end
					paletteStruct.texture = texture
					
					local colorsLen = #cachedColors
					cachedColors[colorsLen + 1] = paletteStruct
					currentColorIndex = colorsLen + 1
				end
			end)
		end
		imgui:popStyleVar()
		
		-- show error message
		if (lastError) then
			imgui:openPopup("Error")
			lastError = false
		end
		
		-- error message window itself
		if (imgui:beginPopupModal("Error", nil, ImGui.WindowFlags_AlwaysAutoResize)) then 
			imgui:text("Error while loading colors...")
			if (imgui:button("OK", 220, 30)) then 
				imgui:closeCurrentPopup()
			end
			imgui:setItemDefaultFocus()
			imgui:endPopup()
		end
		
		-- show current color palette
		if (currentColorIndex > 0) then 
			imgui:image(
				cachedColors[currentColorIndex].texture, -- RenderTarget
				PALETTE_W, PALETTE_H, -- size
				nil, nil, nil, nil, -- default colors
				0, 0, 1, PALETTE_H / PALETTE_W -- UV's
			)
		end
		
		-- draw custom list
		local l = #cachedColors
		if (l > 0) then 
			imgui:beginChild(1, 0, 128)
			local i = l
			while (i >= 1) do
				local colorData = cachedColors[i]
				
				-- generate color string 
				local colorPrintName = ""
				for _,color in ipairs(colorData.colors) do 
					colorPrintName = colorPrintName .. COLOR_FORMAT:format(color) 
				end
				imgui:text(colorPrintName)
				
				-- preview
				imgui:sameLine()		
				if (imgui:button("View###view"..i)) then
					currentColorIndex = i
					
					for k,qlc in ipairs(queryLockedColors) do 
						local paletteLockedColors = colorData.lockedColors[k]
						qlc.activeFlag = paletteLockedColors.lockedFlag
						if (paletteLockedColors.lockedFlag) then
							qlc.color = paletteLockedColors.color
						end
					end
				end
				
				-- copy to clipboard
				imgui:sameLine()
				if (imgui:button("Copy###copy"..i)) then
					imgui:logToClipboard()
					imgui:logText(colorPrintName)
					imgui:logFinish()
				end
				
				-- remove from list
				imgui:sameLine()
				if (imgui:button("X###del"..i)) then
					if (currentColorIndex == i) then 
						currentColorIndex = -1
					end
					table.remove(cachedColors, i)
					l -= 1
				end
				i -= 1
			end
			imgui:endChild()
		end
		
		imgui:endWindow()
	end
		
	imgui:showDemoWindow()
	
	imgui:render()
	imgui:endFrame()
end

stage:addEventListener("enterFrame", enterFrame)
