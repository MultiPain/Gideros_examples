--!NOEXEC
local clipper = ImGuiListClipper.new() -- Added in 1.80 to the binding

local disable_indent = false
CT_Text @ 0
CT_FillButton_2 @ 1
CT_SmallButton @ 2

CT_ShowWidth @ 0
CT_ShortText @ 1
CT_LongText @ 2
CT_Button @ 3
CT_FillButton @ 4
CT_InputText @ 5

CT_Selectable @ 4
CT_SelectableSpanRow @ 5

MyItemColumnID_ID @ 0
MyItemColumnID_Name @ 1
MyItemColumnID_Action @ 2
MyItemColumnID_Quantity @ 3
MyItemColumnID_Description @ 4

local ImGuiTableFlags_SizingMask_ = ImGui.TableFlags_SizingFixedFit | ImGui.TableFlags_SizingFixedSame | ImGui.TableFlags_SizingStretchProp | ImGui.TableFlags_SizingStretchSame
local ImGuiTableColumnFlags_WidthMask_ = ImGui.TableColumnFlags_WidthStretch | ImGui.TableColumnFlags_WidthFixed
local ImGuiTableColumnFlags_IndentMask_ = ImGui.TableColumnFlags_IndentEnable | ImGui.TableColumnFlags_IndentDisable
local ImGuiTableColumnFlags_StatusMask_ = ImGui.TableColumnFlags_IsEnabled | ImGui.TableColumnFlags_IsVisible | ImGui.TableColumnFlags_IsSorted | ImGui.TableColumnFlags_IsHovered

local text_cells_bufs_1 = {} for i = 1, 15 do text_cells_bufs_1[i] = "Edit me" end
local text_cells_bufs_2 = {} for i = 1, 9*64 do text_cells_bufs_2[i] = "Edit me" end
local column_selected = {} for i = 1, 3 do column_selected[i] = false end

local flags = {
	[0] = ImGui.TableFlags_Borders | ImGui.TableFlags_RowBg,
	ImGui.TableFlags_SizingStretchSame | ImGui.TableFlags_Resizable | ImGui.TableFlags_BordersOuter | ImGui.TableFlags_BordersV | ImGui.TableFlags_ContextMenuInBody,
	ImGui.TableFlags_SizingFixedFit | ImGui.TableFlags_Resizable | ImGui.TableFlags_BordersOuter | ImGui.TableFlags_BordersV | ImGui.TableFlags_ContextMenuInBody,
	ImGui.TableFlags_SizingFixedFit | ImGui.TableFlags_RowBg | ImGui.TableFlags_Borders | ImGui.TableFlags_Resizable | ImGui.TableFlags_Reorderable | ImGui.TableFlags_Hideable,
	ImGui.TableFlags_Resizable | ImGui.TableFlags_Reorderable | ImGui.TableFlags_Hideable | ImGui.TableFlags_BordersOuter | ImGui.TableFlags_BordersV,
	ImGui.TableFlags_BordersV,
	ImGui.TableFlags_Borders | ImGui.TableFlags_RowBg,
	ImGui.TableFlags_BordersV | ImGui.TableFlags_BordersOuterH | ImGui.TableFlags_RowBg | ImGui.TableFlags_ContextMenuInBody,
	ImGui.TableFlags_ScrollY | ImGui.TableFlags_Borders | ImGui.TableFlags_RowBg | ImGui.TableFlags_Resizable,
	ImGui.TableFlags_ScrollY | ImGui.TableFlags_RowBg | ImGui.TableFlags_BordersOuter | ImGui.TableFlags_BordersV | ImGui.TableFlags_Resizable | ImGui.TableFlags_Reorderable | ImGui.TableFlags_Hideable,
	ImGui.TableFlags_ScrollX | ImGui.TableFlags_ScrollY | ImGui.TableFlags_RowBg | ImGui.TableFlags_BordersOuter | ImGui.TableFlags_BordersV | ImGui.TableFlags_Resizable | ImGui.TableFlags_Reorderable | ImGui.TableFlags_Hideable,
	ImGui.TableFlags_SizingStretchSame | ImGui.TableFlags_ScrollX | ImGui.TableFlags_ScrollY | ImGui.TableFlags_BordersOuter | ImGui.TableFlags_RowBg | ImGui.TableFlags_ContextMenuInBody,
	ImGui.TableFlags_SizingFixedFit | ImGui.TableFlags_ScrollX | ImGui.TableFlags_ScrollY | ImGui.TableFlags_RowBg | ImGui.TableFlags_BordersOuter | ImGui.TableFlags_BordersV | ImGui.TableFlags_Resizable | ImGui.TableFlags_Reorderable | ImGui.TableFlags_Hideable | ImGui.TableFlags_Sortable,
	ImGui.TableFlags_Borders | ImGui.TableFlags_NoBordersInBodyUntilResize,
	ImGui.TableFlags_None,
	ImGui.TableFlags_Borders | ImGui.TableFlags_Resizable | ImGui.TableFlags_ContextMenuInBody | ImGui.TableFlags_RowBg | ImGui.TableFlags_SizingFixedFit | ImGui.TableFlags_NoHostExtendX,
	ImGui.TableFlags_RowBg,
	ImGui.TableFlags_BordersV | ImGui.TableFlags_BordersOuterH | ImGui.TableFlags_Resizable | ImGui.TableFlags_RowBg | ImGui.TableFlags_NoBordersInBody,
	ImGui.TableFlags_Resizable | ImGui.TableFlags_Reorderable | ImGui.TableFlags_Hideable | ImGui.TableFlags_Borders | ImGui.TableFlags_ContextMenuInBody,
	ImGui.TableFlags_Resizable | ImGui.TableFlags_SizingFixedFit | ImGui.TableFlags_Reorderable | ImGui.TableFlags_Hideable | ImGui.TableFlags_Borders,
	ImGui.TableFlags_Resizable | ImGui.TableFlags_Reorderable | ImGui.TableFlags_Hideable | ImGui.TableFlags_Sortable | ImGui.TableFlags_SortMulti | ImGui.TableFlags_RowBg | ImGui.TableFlags_BordersOuter | ImGui.TableFlags_BordersV | ImGui.TableFlags_NoBordersInBody | ImGui.TableFlags_ScrollY,
}

local column_flags = { ImGui.TableColumnFlags_DefaultSort, ImGui.TableColumnFlags_None, ImGui.TableColumnFlags_DefaultHide }
local column_flags_out = { 0, 0, 0 }
local sizing_policy_flags = { ImGui.TableFlags_SizingFixedFit, ImGui.TableFlags_SizingFixedSame, ImGui.TableFlags_SizingStretchProp, ImGui.TableFlags_SizingStretchSame }
local policies = {
	{ Value = ImGui.TableFlags_None,			   Name = "Default",							Tooltip = "Use default sizing policy:\n- ImGuiTableFlags_SizingFixedFit if ScrollX is on or if host window has ImGuiWindowFlags_AlwaysAutoResize.\n- ImGuiTableFlags_SizingStretchSame otherwise." },
	{ Value = ImGui.TableFlags_SizingFixedFit,	 Name = "ImGuiTableFlags_SizingFixedFit",	 Tooltip = "Columns default to _WidthFixed (if resizable) or _WidthAuto (if not resizable), matching contents width." },
	{ Value = ImGui.TableFlags_SizingFixedSame,	Name = "ImGuiTableFlags_SizingFixedSame",	Tooltip = "Columns are all the same width, matching the maximum contents width.\nImplicitly disable ImGuiTableFlags_Resizable and enable ImGuiTableFlags_NoKeepColumnsVisible." },
	{ Value = ImGui.TableFlags_SizingStretchProp,  Name = "ImGuiTableFlags_SizingStretchProp",  Tooltip = "Columns default to _WidthStretch with weights proportional to their widths." },
	{ Value = ImGui.TableFlags_SizingStretchSame,  Name = "ImGuiTableFlags_SizingStretchSame",  Tooltip = "Columns default to _WidthStretch with same weights." }
}

local template_items_names = {
    "Banana", "Apple", "Cherry", "Watermelon", "Grapefruit", "Strawberry", "Mango",
    "Kiwi", "Orange", "Pineapple", "Blueberry", "Plum", "Coconut", "Pear", "Apricot"
}

local s_current_sort_specs = 0
local items = {}
for n = 1, 50 do
	local template_n = ((n - 1) % (#template_items_names)) + 1
	local item = {}
	item.id = n - 1
	item.name = template_items_names[template_n]
	item.quantity = (n * n - n) % 20
	
	items[n] = item
end

local function strcmp(s1, s2)
	return s1:len() - s2:len()
end

local function compareWithSortSpecs(a, b)
	local t = s_current_sort_specs:getColumnSortSpecs()
	
	for i, sort_spec in ipairs(t) do
		local delta = 0
		local id = sort_spec:getColumnUserID()
		local dir = sort_spec:getSortDirection()
		
		if (dir == ImGui.SortDirection_Descending) then
			if (id == MyItemColumnID_ID) then              return a.id > b.id
			elseif (id == MyItemColumnID_Name) then        return a.name > b.name
			elseif (id == MyItemColumnID_Quantity) then    return a.quantity > b.quantity
			elseif (id == MyItemColumnID_Description) then return a.name > b.name
			else assert(false) 
			end
		elseif (dir == ImGui.SortDirection_Ascending) then
			if (id == MyItemColumnID_ID) then              return a.id < b.id
			elseif (id == MyItemColumnID_Name) then        return a.name < b.name
			elseif (id == MyItemColumnID_Quantity) then    return a.quantity < b.quantity
			elseif (id == MyItemColumnID_Description) then return a.name < b.name
			else assert(false) 
			end
		end
	end
	
	return a.id > b.id
end

local contents_type_1 = CT_Text
local contents_type_2 = CT_ShowWidth
local contents_type_3 = CT_SelectableSpanRow

local display_headers = false
local show_headers = false
local show_widget_frame_bg = true

local cell_padding_x = 0
local cell_padding_y = 0
local column_count = 3
local freeze_cols = 1
local freeze_rows = 1
local inner_width = 1000

local row_bg_type = 1
local row_bg_target = 1
local cell_bg_type = 1

local dummy_f = 0

-- Simple storage to output a dummy file-system.
local nodes =
{
	{ name = "Root",						 tp = "Folder",	   	size = -1,	   	childIdx =  1, childCount =  3 },
	{ name = "Music",						 tp = "Folder",	   	size = -1,	   	childIdx =  4, childCount =  2 },
	{ name = "Textures",					 tp = "Folder",	   	size = -1,	   	childIdx =  6, childCount =  3 },
	{ name = "desktop.ini",				 	 tp = "System file",size = 1024,	childIdx = -1, childCount = -1 },
	{ name = "File1_a.wav",				 	 tp = "Audio file", size = 123000,	childIdx = -1, childCount = -1 },
	{ name = "File1_b.wav",				 	 tp = "Audio file", size = 456000,	childIdx = -1, childCount = -1 },
	{ name = "Image001.png",				 tp = "Image file", size = 203128,	childIdx = -1, childCount = -1 },
	{ name = "Copy of Image001.png",		 tp = "Image file", size = 203256,	childIdx = -1, childCount = -1 },
	{ name = "Copy of Image001 (Final2).png",tp = "Image file", size = 203512,	childIdx = -1, childCount = -1 },
}

local function displayNode(ui, node)
	ui:tableNextRow()
	ui:tableNextColumn()
	local is_folder = (node.childCount > 0)
	if (is_folder) then
		local open = ui:treeNodeEx(node.name, ImGui.TreeNodeFlags_SpanFullWidth)
		ui:tableNextColumn()
		ui:textDisabled("--")
		ui:tableNextColumn()
		ui:text(node.tp)
		if (open) then
			for child_n = 1, node.childCount do
				displayNode(ui, nodes[node.childIdx + child_n])
			end
			ui:treePop()
		end
	else
		ui:treeNodeEx(node.name, ImGui.TreeNodeFlags_Leaf | ImGui.TreeNodeFlags_Bullet | ImGui.TreeNodeFlags_NoTreePushOnOpen | ImGui.TreeNodeFlags_SpanFullWidth)
		ui:tableNextColumn()
		ui:text(node.size)
		ui:tableNextColumn()
		ui:text(node.tp)
	end
end

-- Make the UI compact because there are so many fields
local function pushStyleCompact(ui)
	local style = ui:getStyle()
	local fx, fy = style:getFramePadding()
	local ix, iy = style:getItemSpacing()
	ui:pushStyleVar(ImGui.StyleVar_FramePadding, fx, fy * 0.6)
	ui:pushStyleVar(ImGui.StyleVar_ItemSpacing, ix, iy * 0.6)
end
--
local function popStyleCompact(ui)
	ui:popStyleVar(2)
end
--
local function helpMarker(ui, desc)
	ui:textDisabled("(?)")
	if (ui:isItemHovered()) then
		ui:beginTooltip()
		ui:pushTextWrapPos(ui:getFontSize() * 35)
		ui:text(desc)
		ui:popTextWrapPos()
		ui:endTooltip()
	end
end
--
local function editTableSizingFlags(ui, p_flags)
	local idx = 1
	for i = 1, #policies do
		if (policies[i].Value == (p_flags & ImGuiTableFlags_SizingMask_)) then
			break
		else
			idx += 1
		end
	end
	
	local preview_text = policies[idx].Name:sub(idx == 1 and 1 or 17)
	
	if (ui:beginCombo("Sizing Policy", preview_text)) then
		for n = 1, #policies do
			if (ui:selectable(policies[n].Name, idx == n)) then 
				p_flags = (p_flags & ~ImGuiTableFlags_SizingMask_) | policies[n].Value
			end
		end
		ui:endCombo()
	end
	
	ui:sameLine();
	ui:textDisabled("(?)")
	if (ui:isItemHovered()) then
		ui:beginTooltip()
		ui:pushTextWrapPos(ui:getFontSize() * 50)
		
		local isx = ui:getStyle():getIndentSpacing()
		for m = 1, #policies do
			ui:separator()
			ui:text(policies[m].Name)
			ui:separator()
			ui:setCursorPosX(ui:getCursorPosX() + isx * 0.5)
			ui:text(policies[m].Tooltip)
		end
		ui:popTextWrapPos()
		ui:endTooltip()
	end
	
	return p_flags
end
--
local function editTableColumnsFlags(ui, p_flags) -- TODO
	p_flags = ui:checkboxFlags("_DefaultHide", p_flags, ImGui.TableColumnFlags_DefaultHide)
	p_flags = ui:checkboxFlags("_DefaultSort", p_flags, ImGui.TableColumnFlags_DefaultSort)
	
	local flags, isChanged = ui:checkboxFlags("_WidthStretch", p_flags, ImGui.TableColumnFlags_WidthStretch)
	if (isChanged) then
		p_flags = flags & ~(ImGuiTableColumnFlags_WidthMask_ ^ ImGui.TableColumnFlags_WidthStretch)
	end
	
	flags, isChanged = ui:checkboxFlags("_WidthFixed", p_flags, ImGui.TableColumnFlags_WidthFixed)
	if (isChanged) then
		p_flags = flags & ~(ImGuiTableColumnFlags_WidthMask_ ^ ImGui.TableColumnFlags_WidthFixed)
	end
	
	p_flags = ui:checkboxFlags("_NoResize", p_flags, ImGui.TableColumnFlags_NoResize)
	p_flags = ui:checkboxFlags("_NoReorder", p_flags, ImGui.TableColumnFlags_NoReorder)
	p_flags = ui:checkboxFlags("_NoHide", p_flags, ImGui.TableColumnFlags_NoHide)
	p_flags = ui:checkboxFlags("_NoClip", p_flags, ImGui.TableColumnFlags_NoClip)
	p_flags = ui:checkboxFlags("_NoSort", p_flags, ImGui.TableColumnFlags_NoSort)
	p_flags = ui:checkboxFlags("_NoSortAscending", p_flags, ImGui.TableColumnFlags_NoSortAscending)
	p_flags = ui:checkboxFlags("_NoSortDescending", p_flags, ImGui.TableColumnFlags_NoSortDescending)
	p_flags = ui:checkboxFlags("_NoHeaderWidth", p_flags, ImGui.TableColumnFlags_NoHeaderWidth)
	p_flags = ui:checkboxFlags("_PreferSortAscending", p_flags, ImGui.TableColumnFlags_PreferSortAscending)
	p_flags = ui:checkboxFlags("_PreferSortDescending", p_flags, ImGui.TableColumnFlags_PreferSortDescending)
	p_flags = ui:checkboxFlags("_IndentEnable", p_flags, ImGui.TableColumnFlags_IndentEnable) 
	ui:sameLine()
	helpMarker(ui, "Default for column 0")
	p_flags = ui:checkboxFlags("_IndentDisable", p_flags, ImGui.TableColumnFlags_IndentDisable) 
	ui:sameLine()
	helpMarker(ui, "Default for column > 0")
	
	return p_flags
end
--
local function showTableColumnsStatusFlags(ui, flags)
	flags = ui:checkboxFlags("_IsEnabled", flags, ImGui.TableColumnFlags_IsEnabled)
	flags = ui:checkboxFlags("_IsVisible", flags, ImGui.TableColumnFlags_IsVisible)
	flags = ui:checkboxFlags("_IsSorted", flags, ImGui.TableColumnFlags_IsSorted)
	flags = ui:checkboxFlags("_IsHovered", flags, ImGui.TableColumnFlags_IsHovered)
	return flags
end
--
function showDemoWindowTables(ui)
	if (not ui:collapsingHeader("Tables & Columns")) then
		return
	end
	
	-- Using those as a base value to create width/height that are factor of the size of our font
	local TEXT_BASE_WIDTH = ui:calcTextSize("A")
	local TEXT_BASE_HEIGHT = ui:getTextLineHeightWithSpacing()

	ui:pushID("Tables")

	local open_action = -1
	if (ui:button("Open all")) then open_action = 1 end
	ui:sameLine()
	
	if (ui:button("Close all")) then  open_action = 0 end
	ui:sameLine()

	-- Options
	disable_indent = ui:checkbox("Disable tree indentation", disable_indent)
	ui:sameLine()
	helpMarker(ui, "Disable the indenting of tree nodes so demo tables can use the full window width.")
	ui:separator()
	if (disable_indent) then ui:pushStyleVar(ImGui.StyleVar_IndentSpacing, 0) end
	
	-- Demos
	if (open_action ~= -1) then
		ui:setNextItemOpen(open_action ~= 0)
	end
	
	if (ui:treeNode("Basic")) then
		-- Here we will showcase three different ways to output a table.
		-- They are very simple variations of a same thing!

		-- [Method 1] Using TableNextRow() to create a new row, and TableSetColumnIndex() to select the column.
		-- In many situations, this is the most flexible and easy to use pattern.
		helpMarker(ui, "Using TableNextRow() + calling TableSetColumnIndex() _before_ each cell, in a loop.")
		if (ui:beginTable("table1", 3)) then
			--for (int row = 0 row < 4 row++)
			for row = 0, 3 do
				ui:tableNextRow()
				for column = 0, 2 do
					ui:tableSetColumnIndex(column)
					ui:text(("Row %d Column %d"):format(row, column))
				end
			end
			ui:endTable()
		end

		-- [Method 2] Using TableNextColumn() called multiple times, instead of using a for loop + TableSetColumnIndex().
		-- This is generally more convenient when you have code manually submitting the contents of each columns.
		helpMarker(ui, "Using TableNextRow() + calling TableNextColumn() _before_ each cell, manually.")
		if (ui:beginTable("table2", 3)) then
			for row = 0, 3 do
				ui:tableNextRow()
				ui:tableNextColumn()
				ui:text(("Row %d"):format(row))
				ui:tableNextColumn()
				ui:text("Some contents")
				ui:tableNextColumn()
				ui:text("123.456")
			end
			ui:endTable()
		end

		-- [Method 3] We call TableNextColumn() _before_ each cell. We never call TableNextRow(),
		-- as TableNextColumn() will automatically wrap around and create new roes as needed.
		-- This is generally more convenient when your cells all contains the same type of data.
		helpMarker(ui, [[ 
Only using TableNextColumn(), which tends to be convenient for tables where every cells contains the same type of contents.
This is also more similar to the old NextColumn() function of the Columns API, and provided to facilitate the Columns->Tables API transition.]])
		if (ui:beginTable("table3", 3)) then
			--for (int item = 0 item < 14 item++)
			for item = 0, 13 do
				ui:tableNextColumn()
				ui:text(("Item %d"):format(item))
			end
			ui:endTable()
		end
		
		ui:treePop()
	end

	if (open_action ~= -1) then 
		ui:setNextItemOpen(open_action ~= 0)
	end
	
	if (ui:treeNode("Borders, background")) then
		-- Expose a few Borders related flags[0] interactively
		pushStyleCompact(ui)
		flags[0] = ui:checkboxFlags("ImGui.TableFlags_RowBg", flags[0], ImGui.TableFlags_RowBg)
		flags[0] = ui:checkboxFlags("ImGui.TableFlags_Borders", flags[0], ImGui.TableFlags_Borders)
		ui:sameLine() helpMarker(ui, "ImGui.TableFlags_Borders\n = ImGui.TableFlags_BordersInnerV\n | ImGui.TableFlags_BordersOuterV\n | ImGui.TableFlags_BordersInnerV\n | ImGui.TableFlags_BordersOuterH")
		ui:indent()

		flags[0] = ui:checkboxFlags("ImGui.TableFlags_BordersH", flags[0], ImGui.TableFlags_BordersH)
		ui:indent()
		flags[0] = ui:checkboxFlags("ImGui.TableFlags_BordersOuterH", flags[0], ImGui.TableFlags_BordersOuterH)
		flags[0] = ui:checkboxFlags("ImGui.TableFlags_BordersInnerH", flags[0], ImGui.TableFlags_BordersInnerH)
		ui:unindent()

		flags[0] = ui:checkboxFlags("ImGui.TableFlags_BordersV", flags[0], ImGui.TableFlags_BordersV)
		ui:indent()
		flags[0] = ui:checkboxFlags("ImGui.TableFlags_BordersOuterV", flags[0], ImGui.TableFlags_BordersOuterV)
		flags[0] = ui:checkboxFlags("ImGui.TableFlags_BordersInnerV", flags[0], ImGui.TableFlags_BordersInnerV)
		ui:unindent()

		flags[0] = ui:checkboxFlags("ImGui.TableFlags_BordersOuter", flags[0], ImGui.TableFlags_BordersOuter)
		flags[0] = ui:checkboxFlags("ImGui.TableFlags_BordersInner", flags[0], ImGui.TableFlags_BordersInner)
		ui:unindent()

		ui:alignTextToFramePadding() 
		ui:text("Cell contents:")
		ui:sameLine() 
		contents_type_1 = ui:radioButton("Text", contents_type_1, CT_Text)
		ui:sameLine() 
		contents_type_1 = ui:radioButton("FillButton", contents_type_1, CT_FillButton_2)
		
		display_headers = ui:checkbox("Display headers", display_headers)
		
		flags[0] = ui:checkboxFlags("ImGui.TableFlags_NoBordersInBody", flags[0], ImGui.TableFlags_NoBordersInBody)
		ui:sameLine() 
		helpMarker(ui, "Disable vertical borders in columns Body (borders will always appears in Headers")
		popStyleCompact(ui)

		if (ui:beginTable("table1", 3, flags[0])) then
			-- Display headers so we can inspect their interaction with borders.
			-- (Headers are not the main purpose of this section of the demo, so we are not elaborating on them too much. See other sections for details)
			if (display_headers) then
				ui:tableSetupColumn("One")
				ui:tableSetupColumn("Two")
				ui:tableSetupColumn("Three")
				ui:tableHeadersRow()
			end

			for row = 0, 4 do
				ui:tableNextRow()
				for column = 0, 2 do
					ui:tableSetColumnIndex(column)
					local text = ("Hello %d,%d"):format(column, row)
					if (contents_type_1 == CT_Text) then
						ui:text(text)
					else
						ui:button(text, -1, 0)
					end
				end
			end
			ui:endTable()
		end
		ui:treePop()
	end

	if (open_action ~= -1) then
		ui:setNextItemOpen(open_action ~= 0)
	end
	
	if (ui:treeNode("Resizable, stretch")) then
		-- By default, if we don't enable ScrollX the sizing policy for each columns is "Stretch"
		-- Each columns maintain a sizing weight, and they will occupy all available width.
		
		pushStyleCompact(ui)
		flags[1] = ui:checkboxFlags("ImGui.TableFlags_Resizable", flags[1], ImGui.TableFlags_Resizable)
		flags[1] = ui:checkboxFlags("ImGui.TableFlags_BordersV", flags[1], ImGui.TableFlags_BordersV)
		ui:sameLine() 
		helpMarker(ui, "Using the _Resizable flag automatically enables the _BordersInnerV flag as well, this is why the resize borders are still showing when unchecking this.")
		popStyleCompact(ui)

		if (ui:beginTable("table1", 3, flags[1])) then
			--for row = 0, 4 do
			for row = 0, 4 do
				ui:tableNextRow()
				for column = 0, 2 do
					ui:tableSetColumnIndex(column)
					ui:text(("Hello %d,%d"):format(column, row))
				end
			end
			ui:endTable()
		end
		ui:treePop()
	end

	if (open_action ~= -1) then
		ui:setNextItemOpen(open_action ~= 0)
	end
	
	if (ui:treeNode("Resizable, fixed")) then 
		-- Here we use ImGui.TableFlags_SizingFixedFit (even though _ScrollX is not set)
		-- So columns will adopt the "Fixed" policy and will maintain a fixed width regardless of the whole available width (unless table is small)
		-- If there is not enough available width to fit all columns, they will however be resized down.
		-- FIXME-TABLE: Providing a stretch-on-init would make sense especially for tables which don't have saved settings
		helpMarker(ui, [[
Using _Resizable + _SizingFixedFit flags.
Fixed-width columns generally makes more sense if you want to use horizontal scrolling.
Double-click a column border to auto-fit the column to its contents.]])
		pushStyleCompact(ui)
		
		flags[2] = ui:checkboxFlags("ImGui.TableFlags_NoHostExtendX", flags[2], ImGui.TableFlags_NoHostExtendX)
		popStyleCompact(ui)

		if (ui:beginTable("table1", 3, flags[2])) then
			for row = 0, 4 do
				ui:tableNextRow()
				for column = 0, 2 do
					ui:tableSetColumnIndex(column)
					ui:text(("Hello %d,%d"):format(column, row))
				end
			end
			ui:endTable()
		end
		ui:treePop()
	end

	if (open_action ~= -1) then
		ui:setNextItemOpen(open_action ~= 0)
	end
	
	if (ui:treeNode("Resizable, mixed")) then
		helpMarker(ui, [[
Using TableSetupColumn() to alter resizing policy on a per-column basis.
When combining Fixed and Stretch columns, generally you only want one, maybe two trailing columns to use _WidthStretch.]])
		if (ui:beginTable("table1", 3, flags[3])) then
			ui:tableSetupColumn("AAA", ImGui.TableColumnFlags_WidthFixed)
			ui:tableSetupColumn("BBB", ImGui.TableColumnFlags_WidthFixed)
			ui:tableSetupColumn("CCC", ImGui.TableColumnFlags_WidthStretch)
			ui:tableHeadersRow()
			for row = 0, 4 do
				ui:tableNextRow()
				for column = 0, 2 do
					ui:tableSetColumnIndex(column)
					if (column == 2) then 
						ui:text(("Stretch %d,%d"):format(column, row))
					else
						ui:text(("Fixed %d,%d"):format(column, row))
					end
				end
			end
			ui:endTable()
		end
		if (ui:beginTable("table2", 6, flags[3])) then
			ui:tableSetupColumn("AAA", ImGui.TableColumnFlags_WidthFixed)
			ui:tableSetupColumn("BBB", ImGui.TableColumnFlags_WidthFixed)
			ui:tableSetupColumn("CCC", ImGui.TableColumnFlags_WidthFixed | ImGui.TableColumnFlags_DefaultHide)
			ui:tableSetupColumn("DDD", ImGui.TableColumnFlags_WidthStretch)
			ui:tableSetupColumn("EEE", ImGui.TableColumnFlags_WidthStretch)
			ui:tableSetupColumn("FFF", ImGui.TableColumnFlags_WidthStretch | ImGui.TableColumnFlags_DefaultHide)
			ui:tableHeadersRow()
			for row = 0, 4 do
				ui:tableNextRow()
				for column = 0, 5 do
					ui:tableSetColumnIndex(column)
					if (column >= 3) then 
						ui:text(("Stretch %d,%d"):format(column, row))
					else
						ui:text(("Fixed %d,%d"):format(column, row))
					end
				end
			end
			ui:endTable()
		end
		ui:treePop()
	end

	if (open_action ~= -1) then
		ui:setNextItemOpen(open_action ~= 0)
	end
	
	if (ui:treeNode("Reorderable, hideable, with headers")) then
		helpMarker(ui, [[
Click and drag column headers to reorder columns.
Right-click on a header to open a context menu.]])
		
		pushStyleCompact(ui)
		flags[4] = ui:checkboxFlags("ImGui.TableFlags_Resizable", flags[4], ImGui.TableFlags_Resizable)
		flags[4] = ui:checkboxFlags("ImGui.TableFlags_Reorderable", flags[4], ImGui.TableFlags_Reorderable)
		flags[4] = ui:checkboxFlags("ImGui.TableFlags_Hideable", flags[4], ImGui.TableFlags_Hideable)
		flags[4] = ui:checkboxFlags("ImGui.TableFlags_NoBordersInBody", flags[4], ImGui.TableFlags_NoBordersInBody)
		flags[4] = ui:checkboxFlags("ImGui.TableFlags_NoBordersInBodyUntilResize", flags[4], ImGui.TableFlags_NoBordersInBodyUntilResize)
		ui:sameLine() 
		helpMarker(ui, "Disable vertical borders in columns Body until hovered for resize (borders will always appears in Headers)")
		popStyleCompact(ui)

		if (ui:beginTable("table1", 3, flags[4])) then
			-- Submit columns name with TableSetupColumn() and call TableHeadersRow() to create a row with a header in each column.
			-- (Later we will show how TableSetupColumn() has other uses, optional flags, sizing weight etc.)
			ui:tableSetupColumn("One")
			ui:tableSetupColumn("Two")
			ui:tableSetupColumn("Three")
			ui:tableHeadersRow()
			for row = 0, 5 do
				ui:tableNextRow()
				for column = 0, 2 do 
					ui:tableSetColumnIndex(column)
					ui:text(("Hello %d,%d"):format(column, row))
				end
			end
			ui:endTable()
		end

		-- Use outer_size.x == 0.0f instead of default to make the table as tight as possible (only valid when no scrolling and no stretch column)
		if (ui:beginTable("table2", 3, flags[4] | ImGui.TableFlags_SizingFixedFit, 0, 0)) then
			ui:tableSetupColumn("One")
			ui:tableSetupColumn("Two")
			ui:tableSetupColumn("Three")
			ui:tableHeadersRow()
			for row = 0, 5 do
				ui:tableNextRow()
				for column = 0, 2 do 
					ui:tableSetColumnIndex(column)
					ui:text(("Fixed %d,%d"):format(column, row))
				end
			end
			ui:endTable()
		end
		ui:treePop()
	end

	if (open_action ~= -1) then
		ui:setNextItemOpen(open_action ~= 0)
	end
	
	if (ui:treeNode("Padding")) then
		-- First example: showcase use of padding flags and effect of BorderOuterV/BorderInnerV on X padding.
		-- We don't expose BorderOuterH/BorderInnerH here because they have no effect on X padding.
		helpMarker(ui, [[
We often want outer padding activated when any using features which makes the edges of a column visible:
e.g.:
- BorderOuterV
- any form of row selection
Because of this, activating BorderOuterV sets the default to PadOuterX. Using PadOuterX or NoPadOuterX you can override the default.
Actual padding values are using style.CellPadding.
In this demo we don't show horizontal borders to emphasis how they don't affect default horizontal padding.]])

		pushStyleCompact(ui)
		flags[5] = ui:checkboxFlags("ImGui.TableFlags_PadOuterX", flags[5], ImGui.TableFlags_PadOuterX)
		ui:sameLine() helpMarker(ui, "Enable outer-most padding (default if ImGui.TableFlags_BordersOuterV is set)")
		flags[5] = ui:checkboxFlags("ImGui.TableFlags_NoPadOuterX", flags[5], ImGui.TableFlags_NoPadOuterX)
		ui:sameLine() helpMarker(ui, "Disable outer-most padding (default if ImGui.TableFlags_BordersOuterV is not set)")
		flags[5] = ui:checkboxFlags("ImGui.TableFlags_NoPadInnerX", flags[5], ImGui.TableFlags_NoPadInnerX)
		ui:sameLine() helpMarker(ui, "Disable inner padding between columns (double inner padding if BordersOuterV is on, single inner padding if BordersOuterV is off)")
		flags[5] = ui:checkboxFlags("ImGui.TableFlags_BordersOuterV", flags[5], ImGui.TableFlags_BordersOuterV)
		flags[5] = ui:checkboxFlags("ImGui.TableFlags_BordersInnerV", flags[5], ImGui.TableFlags_BordersInnerV)
		
		show_headers = ui:checkbox("show_headers", show_headers)
		popStyleCompact(ui)

		if (ui:beginTable("table_padding", 3, flags[5])) then
			if (show_headers) then
				ui:tableSetupColumn("One")
				ui:tableSetupColumn("Two")
				ui:tableSetupColumn("Three")
				ui:tableHeadersRow()
			end

			for row = 0, 4 do
				ui:tableNextRow()
				for column = 0, 2 do
					ui:tableSetColumnIndex(column)
					if (row == 0) then
						local x = ui:getContentRegionAvail()
						ui:text(("Avail %.2f"):format(x))
					else
						ui:button(("Hello %d,%d"):format(column, row), -1, 0)
					end
				end
			end
			ui:endTable()
		end

		-- Second example: set style.CellPadding to (0.0) or a custom value.
		-- FIXME-TABLE: Vertical border effectively not displayed the same way as horizontal one...
		helpMarker(ui, "Setting style.CellPadding to (0,0) or a custom value.")
		
		pushStyleCompact(ui)
		flags[6] = ui:checkboxFlags("ImGui.TableFlags_Borders", flags[6], ImGui.TableFlags_Borders)
		flags[6] = ui:checkboxFlags("ImGui.TableFlags_BordersH", flags[6], ImGui.TableFlags_BordersH)
		flags[6] = ui:checkboxFlags("ImGui.TableFlags_BordersV", flags[6], ImGui.TableFlags_BordersV)
		flags[6] = ui:checkboxFlags("ImGui.TableFlags_BordersInner", flags[6], ImGui.TableFlags_BordersInner)
		flags[6] = ui:checkboxFlags("ImGui.TableFlags_BordersOuter", flags[6], ImGui.TableFlags_BordersOuter)
		flags[6] = ui:checkboxFlags("ImGui.TableFlags_RowBg", flags[6], ImGui.TableFlags_RowBg)
		flags[6] = ui:checkboxFlags("ImGui.TableFlags_Resizable", flags[6], ImGui.TableFlags_Resizable)
		show_widget_frame_bg = ui:checkbox("show_widget_frame_bg", show_widget_frame_bg)
		cell_padding_x, cell_padding_y = ui:sliderFloat2("CellPadding", cell_padding_x, cell_padding_y, 0, 10)
		popStyleCompact(ui)

		ui:pushStyleVar(ImGui.StyleVar_CellPadding, cell_padding_x, cell_padding_y)
		if (ui:beginTable("table_padding_2", 3, flags[6])) then
			if (not show_widget_frame_bg) then
				ui:pushStyleColor(ImGui.Col_FrameBg, 0, 0)
			end
			
			for cell = 1, 15 do
				ui:tableNextColumn()
				ui:setNextItemWidth(-1)
				ui:pushID(cell)
				text_cells_bufs_1[cell] = ui:inputText("##cell", text_cells_bufs_1[cell], 16)
				ui:popID()
			end
			
			if (not show_widget_frame_bg) then
				ui:popStyleColor()
			end
			ui:endTable()
		end
		ui:popStyleVar()

		ui:treePop()
	end

	if (open_action ~= -1) then
		ui:setNextItemOpen(open_action ~= 0)
	end
	if (ui:treeNode("Sizing policies")) then
		pushStyleCompact(ui)
		flags[7] = ui:checkboxFlags("ImGui.TableFlags_Resizable", flags[7], ImGui.TableFlags_Resizable)
		flags[7] = ui:checkboxFlags("ImGui.TableFlags_NoHostExtendX", flags[7], ImGui.TableFlags_NoHostExtendX)
		popStyleCompact(ui)

		
		for table_n = 1, #sizing_policy_flags do
			ui:pushID(table_n)
			ui:setNextItemWidth(TEXT_BASE_WIDTH * 30)
			sizing_policy_flags[table_n] = editTableSizingFlags(ui, sizing_policy_flags[table_n])

			-- To make it easier to understand the different sizing policy,
			-- For each policy: we display one table where the columns have equal contents width, and one where the columns have different contents width.
			if (ui:beginTable("table1", 3, sizing_policy_flags[table_n] | flags[7])) then
				for row = 0, 2 do
					ui:tableNextRow()
					ui:tableNextColumn() ui:text("Oh dear")
					ui:tableNextColumn() ui:text("Oh dear")
					ui:tableNextColumn() ui:text("Oh dear")
				end
				ui:endTable()
			end
			if (ui:beginTable("table2", 3, sizing_policy_flags[table_n] | flags[7])) then
				for row = 0, 2 do
					ui:tableNextRow()
					ui:tableNextColumn() ui:text("AAAA")
					ui:tableNextColumn() ui:text("BBBBBBBB")
					ui:tableNextColumn() ui:text("CCCCCCCCCCCC")
				end
				ui:endTable()
			end
			ui:popID()
		end

		ui:spacing()
		ui:text("Advanced")
		ui:sameLine()
		helpMarker(ui, "This section allows you to interact and see the effect of various sizing policies depending on whether Scroll is enabled and the contents of your columns.")
		
		pushStyleCompact(ui)
		ui:pushID("Advanced")
		ui:pushItemWidth(TEXT_BASE_WIDTH * 30)
		flags[8] = editTableSizingFlags(ui, flags[8])
		contents_type_2 = ui:combo("Contents", contents_type_2, "Show width\0Short Text\0Long Text\0Button\0Fill Button\0InputText\0")
		if (contents_type_2 == CT_FillButton) then
			ui:sameLine()
			helpMarker(ui, "Be mindful that using right-alignment (e.g. size.x = -FLT_MIN) creates a feedback loop where contents width can feed into auto-column width can feed into contents width.")
		end
		
		column_count = ui:dragInt("Columns", column_count, 0.1, 1, 64, "%d", ImGuiSliderFlags_AlwaysClamp)
		flags[8] = ui:checkboxFlags("ImGui.TableFlags_Resizable", flags[8], ImGui.TableFlags_Resizable)
		flags[8] = ui:checkboxFlags("ImGui.TableFlags_PreciseWidths", flags[8], ImGui.TableFlags_PreciseWidths)
		ui:sameLine() 
		helpMarker(ui, "Disable distributing remainder width to stretched columns (width allocation on a 100-wide table with 3 columns: Without this flag: 33,33,34. With this flag: 33,33,33). With larger number of columns, resizing will appear to be less smooth.")
		flags[8] = ui:checkboxFlags("ImGui.TableFlags_ScrollX", flags[8], ImGui.TableFlags_ScrollX)
		flags[8] = ui:checkboxFlags("ImGui.TableFlags_ScrollY", flags[8], ImGui.TableFlags_ScrollY)
		flags[8] = ui:checkboxFlags("ImGui.TableFlags_NoClip", flags[8], ImGui.TableFlags_NoClip)
		ui:popItemWidth()
		ui:popID()
		popStyleCompact(ui)

		if (ui:beginTable("table2", column_count, flags[8], 0, TEXT_BASE_HEIGHT * 7)) then
			for cell = 0, 9 * column_count do
				ui:tableNextColumn()
				local column = ui:tableGetColumnIndex()
				local row = ui:tableGetRowIndex()
				
				ui:pushID(cell)
				local label = ("Hello %d,%d"):format(column, row)
				if (contents_type_2 == CT_ShortText) then 
					ui:text(label)
				elseif (contents_type_2 == CT_LongText) then 
					ui:text(("Some %s text %d,%d\nOver two lines.."):format(column == 0 and "long" or "longeeer", column, row))
				elseif (contents_type_2 == CT_ShowWidth) then 
					local w = ui:getContentRegionAvail()
					ui:text(("W: %.1f"):format(w))
				elseif (contents_type_2 == CT_Button) then 
					ui:button(label)
				elseif (contents_type_2 == CT_FillButton) then 
					ui:button(label, -1, 0)
				elseif (contents_type_2 == CT_InputText) then 
					ui:setNextItemWidth(-1)
					text_cells_bufs_2[cell + 1] = ui:inputText("##", text_cells_bufs_2[cell + 1], 16)
				end
				ui:popID()
			end
			ui:endTable()
		end
		ui:treePop()
	end

	if (open_action ~= -1) then
		ui:setNextItemOpen(open_action ~= 0)
	end
	
	if (ui:treeNode("Vertical scrolling, with clipping")) then
		helpMarker(ui, "Here we activate ScrollY, which will create a child window container to allow hosting scrollable contents.\n\nWe also demonstrate using ImGuiListClipper to virtualize the submission of many items.")
		
		pushStyleCompact(ui)
		flags[9] = ui:checkboxFlags("ImGui.TableFlags_ScrollY", flags[9], ImGui.TableFlags_ScrollY)
		popStyleCompact(ui)

		-- When using ScrollX or ScrollY we need to specify a size for our table container!
		-- Otherwise by default the table will fit all available space, like a BeginChild() call.
		local outer_size_x = 0
		local outer_size_y = TEXT_BASE_HEIGHT * 8
		
		if (ui:beginTable("table_scrolly", 3, flags[9], outer_size_x, outer_size_y)) then
			ui:tableSetupScrollFreeze(0, 1) -- Make top row always visible
			ui:tableSetupColumn("One", ImGui.TableColumnFlags_None)
			ui:tableSetupColumn("Two", ImGui.TableColumnFlags_None)
			ui:tableSetupColumn("Three", ImGui.TableColumnFlags_None)
			ui:tableHeadersRow()

			-- Demonstrate using clipper for large vertical lists
			clipper:beginClip(1000)
			while (clipper:step()) do
				for row = clipper:getDisplayStart(), clipper:getDisplayEnd() do
					ui:tableNextRow()
					for column = 0, 2 do
						ui:tableSetColumnIndex(column)
						ui:text(("Hello %d,%d"):format(column, row))
					end
				end
			end
			ui:endTable()
		end
		ui:treePop()
	end
	if (open_action ~= -1) then 
		ui:setNextItemOpen(open_action ~= 0)
	end
	
	if (ui:treeNode("Horizontal scrolling")) then
		helpMarker(ui, [[
When ScrollX is enabled, the default sizing policy becomes ImGui.TableFlags_SizingFixedFit,
as automatically stretching columns doesn't make much sense with horizontal scrolling.
Also note that as of the current version, you will almost always want to enable ScrollY along with ScrollX,
because the container window won't automatically extend vertically to fix contents (this may be improved in future versions).]])
		
		pushStyleCompact(ui)
		flags[10] = ui:checkboxFlags("ImGui.TableFlags_Resizable", flags[10], ImGui.TableFlags_Resizable)
		flags[10] = ui:checkboxFlags("ImGui.TableFlags_ScrollX", flags[10], ImGui.TableFlags_ScrollX)
		flags[10] = ui:checkboxFlags("ImGui.TableFlags_ScrollY", flags[10], ImGui.TableFlags_ScrollY)
		ui:setNextItemWidth(ui:getFrameHeight())
		freeze_cols = ui:dragInt("freeze_cols", freeze_cols, 0.2, 0, 9, nil, ImGui.SliderFlags_NoInput)
		ui:setNextItemWidth(ui:getFrameHeight())
		freeze_rows = ui:dragInt("freeze_rows", freeze_rows, 0.2, 0, 9, nil, ImGui.SliderFlags_NoInput)
		popStyleCompact(ui)

		-- When using ScrollX or ScrollY we need to specify a size for our table container!
		-- Otherwise by default the table will fit all available space, like a BeginChild() call.
		local outer_size_w = 0
		local outer_size_h = TEXT_BASE_HEIGHT * 8
		
		if (ui:beginTable("table_scrollx", 7, flags[10], outer_size_w, outer_size_h)) then
			ui:tableSetupScrollFreeze(freeze_cols, freeze_rows)
			ui:tableSetupColumn("Line #", ImGui.TableColumnFlags_NoHide) -- Make the first column not hideable to match our use of TableSetupScrollFreeze()
			ui:tableSetupColumn("One")
			ui:tableSetupColumn("Two")
			ui:tableSetupColumn("Three")
			ui:tableSetupColumn("Four")
			ui:tableSetupColumn("Five")
			ui:tableSetupColumn("Six")
			ui:tableHeadersRow()
			for row = 0, 19 do
				ui:tableNextRow()
				for column = 0, 6 do
					-- Both TableNextColumn() and TableSetColumnIndex() return true when a column is visible or performing width measurement.
					-- Because here we know that:
					-- - A) all our columns are contributing the same to row height
					-- - B) column 0 is always visible,
					-- We only always submit this one column and can skip others.
					-- More advanced per-column clipping behaviors may benefit from polling the status flags via TableGetColumnFlags().
					if not (not ui:tableSetColumnIndex(column) and column > 0) then
						if (column == 0) then
							ui:text(("Line %d"):format(row))
						else
							ui:text(("Hello world %d,%d"):format(column, row))
						end
					end
				end
			end
			ui:endTable()
		end
		
		ui:spacing()
		ui:text("Stretch + ScrollX")
		ui:sameLine()
		helpMarker(ui, [[
Showcase using Stretch columns + ScrollX together: this is rather unusual and only makes sense when specifying an 'inner_width' for the table!
Without an explicit value, inner_width is == outer_size.x and therefore using Stretch columns + ScrollX together doesn't make sense.]])
		
		pushStyleCompact(ui)
		ui:pushID("flags[11]")
		ui:pushItemWidth(TEXT_BASE_WIDTH * 30)
		flags[11] = ui:checkboxFlags("ImGui.TableFlags_ScrollX", flags[11], ImGui.TableFlags_ScrollX)
		inner_width = ui:dragFloat("inner_width", inner_width, 1, 0, 1000000, "%.1f")
		ui:popItemWidth()
		ui:popID()
		popStyleCompact(ui)
		if (ui:beginTable("table2", 7, flags[11], outer_size_w, outer_size_h, inner_width)) then
			for cell = 0, 19 * 7 do
				ui:tableNextColumn()
				ui:text(("Hello world %d,%d"):format(ui:tableGetColumnIndex(), ui:tableGetRowIndex()))
			end
			ui:endTable()
		end
		ui:treePop()
	end

	if (open_action ~= -1) then
		ui:setNextItemOpen(open_action ~= 0)
	end
	
	if (ui:treeNode("Columns flags")) then
		-- Create a first table just to show all the options/flags we want to make visible in our example!
		local column_count = 3
		local column_names = { "One", "Two", "Three" }
		
		if (ui:beginTable("table_columns_flags_checkboxes", column_count, ImGui.TableFlags_None)) then
			pushStyleCompact(ui)
			for column = 1, column_count do
				ui:tableNextColumn()
				ui:pushID(column)
				ui:alignTextToFramePadding() -- FIXME-TABLE: Workaround for wrong text baseline propagation
				ui:text(column_names[column])
				ui:spacing()
				ui:text("Input flags:")
				column_flags[column] = editTableColumnsFlags(ui, column_flags[column])
				ui:spacing()
				ui:text("Output flags:")
				column_flags_out[column] = showTableColumnsStatusFlags(ui, column_flags_out[column])
				ui:popID()
			end
			popStyleCompact(ui)
			ui:endTable()
		end

		-- Create the real table we care about for the example!
		-- We use a scrolling table to be able to showcase the difference between the _IsEnabled and _IsVisible flags above, otherwise in
		-- a non-scrolling table columns are always visible (unless using ImGui.TableFlags_NoKeepColumnsVisible + resizing the parent window down)
		
		local outer_size_w = 0
		local outer_size_h = TEXT_BASE_HEIGHT * 9
		
		if (ui:beginTable("table_columns_flags", column_count, flags[12], outer_size_w, outer_size_h)) then
			for column = 1, column_count do
				ui:tableSetupColumn(column_names[column], column_flags[column])
			end
			ui:tableHeadersRow()
			for column = 1, column_count do
				column_flags_out[column] = ui:tableGetColumnFlags(column - 1)
			end
			local indent_step = TEXT_BASE_WIDTH // 2
			for row = 1, 8 do
				ui:indent(indent_step) -- Add some indentation to demonstrate usage of per-column indentEnable/indentDisable flags.
				ui:tableNextRow()
				for column = 1, column_count do
					ui:tableSetColumnIndex(column - 1)
					ui:text(("%s %s"):format((column == 1) and "indented" or "Hello", ui:tableGetColumnName(column - 1)))
				end
			end
			ui:unindent(indent_step * 8)
			
			ui:endTable()
		end
		ui:treePop()
	end

	if (open_action ~= -1) then
		ui:setNextItemOpen(open_action ~= 0)
	end
	
	if (ui:treeNode("Columns widths")) then
		helpMarker(ui, "Using TableSetupColumn() to setup default width.")

		pushStyleCompact(ui)
		flags[13] = ui:checkboxFlags("ImGui.TableFlags_Resizable", flags[13], ImGui.TableFlags_Resizable)
		flags[13] = ui:checkboxFlags("ImGui.TableFlags_NoBordersInBodyUntilResize", flags[13], ImGui.TableFlags_NoBordersInBodyUntilResize)
		popStyleCompact(ui)
		
		if (ui:beginTable("table1", 3, flags[13])) then
			-- We could also set ImGui.TableFlags_SizingFixedFit on the table and all columns will default to ImGui.TableColumnFlags_WidthFixed.
			ui:tableSetupColumn("one", ImGui.TableColumnFlags_WidthFixed, 100) -- Default to 100.0f
			ui:tableSetupColumn("two", ImGui.TableColumnFlags_WidthFixed, 200) -- Default to 200.0f
			ui:tableSetupColumn("three", ImGui.TableColumnFlags_WidthFixed)	-- Default to auto
			ui:tableHeadersRow()
			for row = 0, 3 do
				ui:tableNextRow()
				for column = 0, 2 do
					ui:tableSetColumnIndex(column)
					if (row == 0) then
						local w = ui:getContentRegionAvail()
						ui:text(("(w: %5.1f)"):format(w))
					else
						ui:text(("Hello %d,%d"):format(column, row))
					end
				end
			end
			ui:endTable()
		end

		helpMarker(ui, "Using TableSetupColumn() to setup explicit width.\n\nUnless _NoKeepColumnsVisible is set, fixed columns with set width may still be shrunk down if there's not enough space in the host.")

		pushStyleCompact(ui)
		flags[14] = ui:checkboxFlags("ImGui.TableFlags_NoKeepColumnsVisible", flags[14], ImGui.TableFlags_NoKeepColumnsVisible)
		flags[14] = ui:checkboxFlags("ImGui.TableFlags_BordersInnerV", flags[14], ImGui.TableFlags_BordersInnerV)
		flags[14] = ui:checkboxFlags("ImGui.TableFlags_BordersOuterV", flags[14], ImGui.TableFlags_BordersOuterV)
		popStyleCompact(ui)
		
		if (ui:beginTable("table2", 4, flags[14])) then
			-- We could also set ImGui.TableFlags_SizingFixedFit on the table and all columns will default to ImGui.TableColumnFlags_WidthFixed.
			ui:tableSetupColumn("", ImGui.TableColumnFlags_WidthFixed, 100)
			ui:tableSetupColumn("", ImGui.TableColumnFlags_WidthFixed, TEXT_BASE_WIDTH * 15)
			ui:tableSetupColumn("", ImGui.TableColumnFlags_WidthFixed, TEXT_BASE_WIDTH * 30)
			ui:tableSetupColumn("", ImGui.TableColumnFlags_WidthFixed, TEXT_BASE_WIDTH * 15)
			for row = 0, 4 do
				ui:tableNextRow()
				for column = 0, 3 do
					ui:tableSetColumnIndex(column)
					if (row == 0) then
						local w = ui:getContentRegionAvail()
						ui:text(("(w: %5.1f)"):format(w))
					else
						ui:text(("Hello %d,%d"):format(column, row))
					end
				end
			end
			ui:endTable()
		end
		ui:treePop()
	end

	if (open_action ~= -1) then
		ui:setNextItemOpen(open_action ~= 0)
	end
	
	if (ui:treeNode("Nested tables")) then
		helpMarker(ui, "This demonstrate embedding a table into another table cell.")

		if (ui:beginTable("table_nested1", 2, ImGui.TableFlags_Borders | ImGui.TableFlags_Resizable | ImGui.TableFlags_Reorderable | ImGui.TableFlags_Hideable)) then
			ui:tableSetupColumn("A0")
			ui:tableSetupColumn("A1")
			ui:tableHeadersRow()

			ui:tableNextColumn()
			ui:text("A0 Cell 0")
			do
				local rows_height = TEXT_BASE_HEIGHT * 2
				if (ui:beginTable("table_nested2", 2, ImGui.TableFlags_Borders | ImGui.TableFlags_Resizable | ImGui.TableFlags_Reorderable | ImGui.TableFlags_Hideable)) then
					ui:tableSetupColumn("B0")
					ui:tableSetupColumn("B1")
					ui:tableHeadersRow()

					ui:tableNextRow(ImGui.TableRowFlags_None, rows_height)
					ui:tableNextColumn()
					ui:text("B0 Cell 0")
					ui:tableNextColumn()
					ui:text("B0 Cell 1")
					ui:tableNextRow(ImGui.TableRowFlags_None, rows_height)
					ui:tableNextColumn()
					ui:text("B1 Cell 0")
					ui:tableNextColumn()
					ui:text("B1 Cell 1")

					ui:endTable()
				end
			end
			ui:tableNextColumn() ui:text("A0 Cell 1")
			ui:tableNextColumn() ui:text("A1 Cell 0")
			ui:tableNextColumn() ui:text("A1 Cell 1")
			ui:endTable()
		end
		ui:treePop()
	end

	if (open_action ~= -1) then 
		ui:setNextItemOpen(open_action ~= 0)
	end
	
	if (ui:treeNode("Row height")) then
		helpMarker(ui, "You can pass a 'min_row_height' to TableNextRow().\n\nRows are padded with 'style.CellPadding.y' on top and bottom, so effectively the minimum row height will always be >= 'style.CellPadding.y * 2.0f'.\n\nWe cannot honor a _maximum_ row height as that would requires a unique clipping rectangle per row.")
		if (ui:beginTable("table_row_height", 1, ImGui.TableFlags_BordersOuter | ImGui.TableFlags_BordersInnerV)) then
			for row = 0, 9 do
				local min_row_height = TEXT_BASE_HEIGHT * 0.30 * row
				ui:tableNextRow(ImGui.TableRowFlags_None, min_row_height)
				ui:tableNextColumn()
				ui:text(("min_row_height = %.2f"):format(min_row_height))
			end
			ui:endTable()
		end
		ui:treePop()
	end

	if (open_action ~= -1) then
		ui:setNextItemOpen(open_action ~= 0)
	end
	if (ui:treeNode("Outer size")) then
		-- Showcasing use of ImGui.TableFlags_NoHostExtendX and ImGui.TableFlags_NoHostExtendY
		-- Important to that note how the two flags have slightly different behaviors!
		ui:text("Using NoHostExtendX and NoHostExtendY:")

		pushStyleCompact(ui)
		flags[15] = ui:checkboxFlags("ImGui.TableFlags_NoHostExtendX", flags[15], ImGui.TableFlags_NoHostExtendX)
		ui:sameLine() helpMarker(ui, "Make outer width auto-fit to columns, overriding outer_size.x value.\n\nOnly available when ScrollX/ScrollY are disabled and Stretch columns are not used.")
		flags[15] = ui:checkboxFlags("ImGui.TableFlags_NoHostExtendY", flags[15], ImGui.TableFlags_NoHostExtendY)
		ui:sameLine() helpMarker(ui, "Make outer height stop exactly at outer_size.y (prevent auto-extending table past the limit).\n\nOnly available when ScrollX/ScrollY are disabled. Data below the limit will be clipped and not visible.")
		popStyleCompact(ui)

		local outer_size_w = 0
		local outer_size_h = TEXT_BASE_HEIGHT * 5.5
		if (ui:beginTable("table1", 3, flags[15], outer_size_w, outer_size_h)) then
			for row = 0, 9 do
				ui:tableNextRow()
				for column = 0, 2 do
					ui:tableNextColumn()
					ui:text(("Cell %d,%d"):format(column, row))
				end
			end
			ui:endTable()
		end
		ui:sameLine()
		ui:text("Hello!")
		
		ui:spacing()
		
		ui:text("Using explicit size:")
		if (ui:beginTable("table2", 3, ImGui.TableFlags_Borders | ImGui.TableFlags_RowBg, TEXT_BASE_WIDTH * 30, 0)) then
			for row = 0, 4 do
				ui:tableNextRow()
				for column = 0, 2 do
					ui:tableNextColumn()
					ui:text(("Cell %d,%d"):format(column, row))
				end
			end
			ui:endTable()
		end
		ui:sameLine()
		if (ui:beginTable("table3", 3, ImGui.TableFlags_Borders | ImGui.TableFlags_RowBg, TEXT_BASE_WIDTH * 30, 0)) then
			for row = 0, 2 do
				ui:tableNextRow(0, TEXT_BASE_HEIGHT * 1.5)
				for column = 0, 2 do
					ui:tableNextColumn()
					ui:text(("Cell %d,%d"):format(column, row))
				end
			end
			ui:endTable()
		end

		ui:treePop()
	end

	if (open_action ~= -1) then
		ui:setNextItemOpen(open_action ~= 0)
	end
	
	if (ui:treeNode("Background color")) then

		pushStyleCompact(ui)
		flags[16] = ui:checkboxFlags("ImGui.TableFlags_Borders", flags[16], ImGui.TableFlags_Borders)
		flags[16] = ui:checkboxFlags("ImGui.TableFlags_RowBg", flags[16], ImGui.TableFlags_RowBg)
		ui:sameLine() helpMarker(ui, "ImGui.TableFlags_RowBg automatically sets RowBg0 to alternative colors pulled from the Style.")
		
		row_bg_type = ui:combo("row bg type", row_bg_type, "None\0Red\0Gradient\0")
		row_bg_target = ui:combo("row bg target", row_bg_target, "RowBg0\0RowBg1\0") ui:sameLine() helpMarker(ui, "Target RowBg0 to override the alternating odd/even colors,\nTarget RowBg1 to blend with them.")
		cell_bg_type = ui:combo("cell bg type", cell_bg_type, "None\0Blue\0") ui:sameLine() helpMarker(ui, "We are colorizing cells to B1->C2 here.")
		assert(row_bg_type >= 0 and row_bg_type <= 2)
		assert(row_bg_target >= 0 and row_bg_target <= 1)
		assert(cell_bg_type >= 0 and cell_bg_type <= 1)
		popStyleCompact(ui)

		if (ui:beginTable("table1", 5, flags[16])) then
			for row = 0, 5 do
				ui:tableNextRow()

				-- Demonstrate setting a row background color with 'ui:tableSetBgColor(ImGui.TableBgTarget_RowBgX, ...)'
				-- We use a transparent color so we can see the one behind in case our target is RowBg1 and RowBg0 was already targeted by the ImGui.TableFlags_RowBg flag.
				if (row_bg_type ~= 0) then
					--local row_bg_color = ui:getColorU32(row_bg_type == 1 ? ImVec4(0.7, 0.3, 0.3) : ImVec4(0.2f + row * 0.1, 0.2, 0.2)) -- Flat or Gradient?
					local row_bg_color = 0
					if (row_bg_type == 1) then 
						row_bg_color = ui:colorConvertRGBtoHEX(0.7, 0.3, 0.3)
					else
						row_bg_color = ui:colorConvertRGBtoHEX(0.2 + row * 0.1, 0.2, 0.2)
					end
					ui:tableSetBgColor(ImGui.TableBgTarget_RowBg0 + row_bg_target, row_bg_color, 0.65)
				end

				-- Fill cells
				for column = 0, 4 do
					ui:tableSetColumnIndex(column)
					ui:text("A" .. row .. "0" .. column)

					-- Change background of Cells B1->C2
					-- Demonstrate setting a cell background color with 'ui:tableSetBgColor(ImGui.TableBgTarget_CellBg, ...)'
					-- (the CellBg color will be blended over the RowBg and ColumnBg colors)
					-- We can also pass a column number as a third parameter to TableSetBgColor() and do this outside the column loop.
					if (row >= 1 and row <= 2 and column >= 1 and column <= 2 and cell_bg_type == 1) then
						local cell_bg_color = ui:colorConvertRGBtoHEX(0.3, 0.3, 0.7)
						ui:tableSetBgColor(ImGui.TableBgTarget_CellBg, cell_bg_color, 0.65)
					end
				end
			end
			ui:endTable()
		end
		ui:treePop()
	end

	if (open_action ~= -1) then
		ui:setNextItemOpen(open_action ~= 0)
	end
	if (ui:treeNode("Tree view")) then
		if (ui:beginTable("3ways", 3, flags[17])) then
			-- The first column will use the default _WidthStretch when ScrollX is Off and _WidthFixed when ScrollX is On
			ui:tableSetupColumn("Name", ImGui.TableColumnFlags_NoHide)
			ui:tableSetupColumn("Size", ImGui.TableColumnFlags_WidthFixed, TEXT_BASE_WIDTH * 12)
			ui:tableSetupColumn("Type", ImGui.TableColumnFlags_WidthFixed, TEXT_BASE_WIDTH * 18)
			ui:tableHeadersRow()
			
			displayNode(ui, nodes[1])
			
			ui:endTable()
		end
		ui:treePop()
	end

	if (open_action ~= -1) then
		ui:setNextItemOpen(open_action ~= 0)
	end
	if (ui:treeNode("Item width")) then
		helpMarker(ui, [[
Showcase using PushItemWidth() and how it is preserved on a per-column basis.
Note that on auto-resizing non-resizable fixed columns, querying the content width for e.g. right-alignment doesn't make sense.]])
		if (ui:beginTable("table_item_width", 3, ImGui.TableFlags_Borders)) then
			ui:tableSetupColumn("small")
			ui:tableSetupColumn("half")
			ui:tableSetupColumn("right-align")
			ui:tableHeadersRow()

			for row = 0, 2 do
				ui:tableNextRow()
				if (row == 0) then
					-- Setup ItemWidth once (instead of setting up every time, which is also possible but less efficient)
					local w = ui:getContentRegionAvail()
					
					ui:tableSetColumnIndex(0)
					ui:pushItemWidth(TEXT_BASE_WIDTH * 3) -- Small
					ui:tableSetColumnIndex(1)
					ui:pushItemWidth(-w * 0.5)
					ui:tableSetColumnIndex(2)
					ui:pushItemWidth(-1) -- Right-aligned
				end
				
				-- Draw our contents
				
				ui:pushID(row)
				ui:tableSetColumnIndex(0)
				dummy_f = ui:sliderFloat("float0", dummy_f, 0, 1)
				ui:tableSetColumnIndex(1)
				dummy_f = ui:sliderFloat("float1", dummy_f, 0, 1)
				ui:tableSetColumnIndex(2)
				dummy_f = ui:sliderFloat("float2", dummy_f, 0, 1)
				ui:popID()
			end
			ui:endTable()
		end
		ui:treePop()
	end

	-- Demonstrate using TableHeader() calls instead of TableHeadersRow()
	if (open_action ~= -1) then
		ui:setNextItemOpen(open_action ~= 0)
	end
	if (ui:treeNode("Custom headers")) then
		local COLUMNS_COUNT = 3
		if (ui:beginTable("table_custom_headers", COLUMNS_COUNT, ImGui.TableFlags_Borders | ImGui.TableFlags_Reorderable | ImGui.TableFlags_Hideable)) then
			ui:tableSetupColumn("Apricot")
			ui:tableSetupColumn("Banana")
			ui:tableSetupColumn("Cherry")
			
			-- Instead of calling TableHeadersRow() we'll submit custom headers ourselves
			ui:tableNextRow(ImGui.TableRowFlags_Headers)
			
			local isx = ui:getStyle():getItemInnerSpacing()
			for column = 1, COLUMNS_COUNT do
				ui:tableSetColumnIndex(column - 1)
				local column_name = ui:tableGetColumnName(column - 1) -- Retrieve name passed to TableSetupColumn()
				ui:pushID(column)
				ui:pushStyleVar(ImGui.StyleVar_FramePadding, 0, 0)
				column_selected[column] = ui:checkbox("##checkall", column_selected[column])
				ui:popStyleVar()
				ui:sameLine(0, isx)
				ui:tableHeader(column_name)
				ui:popID()
			end
			
			for row = 1, 5 do 
				ui:tableNextRow()
				for column = 1, 3 do
					local label = ("Cell %d,%d"):format(column, row)
					ui:tableSetColumnIndex(column - 1)
					ui:selectable(label, column_selected[column])
				end
			end
			ui:endTable()
		end
		ui:treePop()
	end
	
	-- Demonstrate creating custom context menus inside columns, while playing it nice with context menus provided by TableHeadersRow()/TableHeader()
	if (open_action ~= -1) then
		ui:setNextItemOpen(open_action ~= 0)
	end
	if (ui:treeNode("Context menus")) then
		helpMarker(ui, "By default, right-clicking over a TableHeadersRow()/TableHeader() line will open the default context-menu.\nUsing ImGui.TableFlags_ContextMenuInBody we also allow right-clicking over columns body.")
		
		pushStyleCompact(ui)
		flags[18] = ui:checkboxFlags("ImGui.TableFlags_ContextMenuInBody", flags[18], ImGui.TableFlags_ContextMenuInBody)
		popStyleCompact(ui)

		-- Context Menus: first example
		-- [1.1] Right-click on the TableHeadersRow() line to open the default table context menu.
		-- [1.2] Right-click in columns also open the default table context menu (if ImGui.TableFlags_ContextMenuInBody is set)
		local COLUMNS_COUNT = 3
		if (ui:beginTable("table_context_menu", COLUMNS_COUNT, flags[18])) then
			ui:tableSetupColumn("One")
			ui:tableSetupColumn("Two")
			ui:tableSetupColumn("Three")
			
			-- [1.1] Right-click on the TableHeadersRow() line to open the default table context menu.
			ui:tableHeadersRow()
			
			-- Submit dummy contents
			for row = 0, 3 do
				ui:tableNextRow()
				for column = 0, COLUMNS_COUNT - 1 do
					ui:tableSetColumnIndex(column)
					ui:text(("Cell %d,%d"):format(column, row))
				end
			end
			ui:endTable()
		end

		-- Context Menus: second example
		-- [2.1] Right-click on the TableHeadersRow() line to open the default table context menu.
		-- [2.2] Right-click on the ".." to open a custom popup
		-- [2.3] Right-click in columns to open another custom popup
		helpMarker(ui, "Demonstrate mixing table context menu (over header), item context button (over button) and custom per-colum context menu (over column body).")
		
		if (ui:beginTable("table_context_menu_2", COLUMNS_COUNT, flags[19])) then
			ui:tableSetupColumn("One")
			ui:tableSetupColumn("Two")
			ui:tableSetupColumn("Three")
			
			-- [2.1] Right-click on the TableHeadersRow() line to open the default table context menu.
			ui:tableHeadersRow()
			for row = 0, 3 do
				ui:tableNextRow()
				for column = 0, COLUMNS_COUNT - 1 do
					-- Submit dummy contents
					ui:tableSetColumnIndex(column)
					ui:text(("Cell %d,%d"):format(column, row))
					ui:sameLine()
					
					-- [2.2] Right-click on the ".." to open a custom popup
					ui:pushID(row * COLUMNS_COUNT + column)
					ui:smallButton("..")
					if (ui:beginPopupContextItem()) then
						ui:text(("This is the popup for Button(\"..\") in Cell %d,%d"):format(column, row))
						if (ui:button("Close")) then
							ui:closeCurrentPopup()
						end
						ui:endPopup()
					end
					ui:popID()
				end
			end
			
			-- [2.3] Right-click anywhere in columns to open another custom popup
			-- (instead of testing for !IsAnyItemHovered() we could also call OpenPopup() with ImGuiPopupFlags_NoOpenOverExistingPopup
			-- to manage popup priority as the popups triggers, here "are we hovering a column" are overlapping)
			local hovered_column = -1
			for column = 0, COLUMNS_COUNT do
				ui:pushID(column)
				if ((ui:tableGetColumnFlags(column) & ImGui.TableColumnFlags_IsHovered) > 0) then
					hovered_column = column
				end
				
				if (hovered_column == column and not ui:isAnyItemHovered() and ui:isMouseReleased(KeyCode.MOUSE_RIGHT)) then
					ui:openPopup("MyPopup")
				end
				
				if (ui:beginPopup("MyPopup")) then
					if (column == COLUMNS_COUNT) then
						ui:text("This is a custom popup for unused space after the last column.")
					else
						ui:text("This is a custom popup for Column " .. column)
					end
					
					if (ui:button("Close")) then
						ui:closeCurrentPopup()
					end
					ui:endPopup()
				end
				ui:popID()
			end
			
			ui:endTable()
			ui:text("Hovered column: " .. hovered_column)
		end
		ui:treePop()
	end

	-- Demonstrate creating multiple tables with the same ID
	if (open_action ~= -1) then
		ui:setNextItemOpen(open_action ~= 0)
	end
	
	if (ui:treeNode("Synced instances")) then
		helpMarker(ui, "Multiple tables with the same identifier will share their settings, width, visibility, order etc.")
		for n = 0, 2 do
			local buf = "Synced Table "..n
			local open = ui:collapsingHeader(buf, nil, ImGui.TreeNodeFlags_DefaultOpen)
			if (open and ui:beginTable("Table", 3, ImGui.TableFlags_Resizable | ImGui.TableFlags_Reorderable | ImGui.TableFlags_Hideable | ImGui.TableFlags_Borders | ImGui.TableFlags_SizingFixedFit | ImGui.TableFlags_NoSavedSettings)) then
				ui:tableSetupColumn("One")
				ui:tableSetupColumn("Two")
				ui:tableSetupColumn("Three")
				ui:tableHeadersRow()
				for cell = 0, 8 do
					ui:tableNextColumn()
					ui:text("this cell " .. cell)
				end
				ui:endTable()
			end
		end
		ui:treePop()
	end
	
    if (open_action ~= -1) then
        ui:setNextItemOpen(open_action ~= 0)
	end
	
    if (ui:treeNode("Sorting")) then
        -- Options
        
        pushStyleCompact(ui)
        flags[20] = ui:checkboxFlags("ImGui.TableFlags_SortMulti", flags[20], ImGui.TableFlags_SortMulti)
        ui:sameLine() helpMarker(ui, "When sorting is enabled: hold shift when clicking headers to sort on multiple column. TableGetSortSpecs() may return specs where (SpecsCount > 1).")
        flags[20] = ui:checkboxFlags("ImGui.TableFlags_SortTristate", flags[20], ImGui.TableFlags_SortTristate)
        ui:sameLine() helpMarker(ui, "When sorting is enabled: allow no sorting, disable default sorting. TableGetSortSpecs() may return specs where (SpecsCount == 0).")
        popStyleCompact(ui)

        if (ui:beginTable("table_sorting", 4, flags[20], 0, TEXT_BASE_HEIGHT * 15, 0)) then
            -- Declare columns
            -- We use the "user_id" parameter of TableSetupColumn() to specify a user id that will be stored in the sort specifications.
            -- This is so our sort function can identify a column given our own identifier. We could also identify them based on their index!
            -- Demonstrate using a mixture of flags among available sort-related flags:
            -- - ImGuiTableColumnFlags_DefaultSort
            -- - ImGuiTableColumnFlags_NoSort / ImGui.TableColumnFlags_NoSortAscending / ImGui.TableColumnFlags_NoSortDescending
            -- - ImGui.TableColumnFlags_PreferSortAscending / ImGui.TableColumnFlags_PreferSortDescending
            ui:tableSetupColumn("ID",       ImGui.TableColumnFlags_DefaultSort          | ImGui.TableColumnFlags_WidthFixed,   0, MyItemColumnID_ID)
            ui:tableSetupColumn("Name",                                                   ImGui.TableColumnFlags_WidthFixed,   0, MyItemColumnID_Name)
            ui:tableSetupColumn("Action",   ImGui.TableColumnFlags_NoSort               | ImGui.TableColumnFlags_WidthFixed,   0, MyItemColumnID_Action)
            ui:tableSetupColumn("Quantity", ImGui.TableColumnFlags_PreferSortDescending | ImGui.TableColumnFlags_WidthStretch, 0, MyItemColumnID_Quantity)
            ui:tableSetupScrollFreeze(0, 1) -- Make row always visible
            ui:tableHeadersRow()

            -- Sort our data if sort specs have been changed!
			
			local sorts_specs = ui:tableGetSortSpecs()
            if (sorts_specs) then
                if (sorts_specs:isSpecsDirty()) then
                    s_current_sort_specs = sorts_specs -- Store in variable accessible by the sort function.
					
                    if (#items > 1) then
						table.sort(items, compareWithSortSpecs)
					end
                    sorts_specs:setSpecsDirty(false)
                end
			end
			
            -- Demonstrate using clipper for large vertical lists
            for row_n = 1, 50 do
                -- Display a data item
                local item = items[row_n]
				
                ui:pushID(item.id)
				
                ui:tableNextRow()
                ui:tableNextColumn()
                ui:text(("%04d"):format(item.id))
				
                ui:tableNextColumn()
                ui:text(item.name)
				
                ui:tableNextColumn()
                ui:smallButton("None")
				
                ui:tableNextColumn()
                ui:text(item.quantity)
				
                ui:popID()
            end
			--[[
			clipper:beginClip(50)            
            while (clipper:step()) do
                for row_n = clipper:getDisplayStart() + 1, clipper:getDisplayEnd() do
                    -- Display a data item
                    local item = items[row_n]
					
                    ui:pushID(item.id)
					
                    ui:tableNextRow()
                    ui:tableNextColumn()
                    ui:text(("%04d"):format(item.id))
					
                    ui:tableNextColumn()
                    ui:text(item.name)
					
                    ui:tableNextColumn()
                    ui:smallButton("None")
					
                    ui:tableNextColumn()
                    ui:text(item.quantity)
					
                    ui:popID()
                end
            end
			]]
            ui:endTable()
        end
        ui:treePop()
    end

	ui:popID()

	if (disable_indent) then
		ui:popStyleVar()
	end
end
