app @ application
app:setBackgroundColor(0x323232)

local GAMMA = 2.2
local COLORS = {
	{0xff0000, 0x00ff00},
	{0x00ff00, 0x0000ff},
	{0x0000ff, 0xff0000},
	{0xff00ff, 0xffff00},
	{0xffff00, 0x00ffff},
}
local minX,minY,maxX,maxY = app:getLogicalBounds()
local W = -minX + maxX --app:getLogicalWidth()
local H = -minY + maxY --app:getLogicalHeight()

local shader = Shader.new("vs","fs",0,
{
	{name="vMatrix",type=Shader.CMATRIX,sys=Shader.SYS_WVP,vertex=true},
	{name="fColor",type=Shader.CFLOAT4,sys=Shader.SYS_COLOR,vertex=false},
	{name="fTexture",type=Shader.CTEXTURE,vertex=false},
	
	{name="fGamma",type=Shader.CFLOAT,vertex=false},
},
{
	{name="vVertex",type=Shader.DFLOAT,mult=3,slot=0,offset=0},
	{name="vColor",type=Shader.DUBYTE,mult=4,slot=1,offset=0},
	{name="vTexCoord",type=Shader.DFLOAT,mult=2,slot=2,offset=0},
})
shader:setConstant("fGamma", Shader.CFLOAT, 1, GAMMA)
local function gradient(w, h, c1, c2)
	local m = Mesh.new()
	m:setVertexArray(0,0, w,0, w,h, 0,h)
	m:setIndexArray(1,2,3, 1,3,4)
	m:setColorArray(c1, 1.0, c1, 1.0, c2, 1.0, c2, 1.0)
	
	local rt = RenderTarget.new(w,h)
	rt:draw(m)
	return Bitmap.new(rt)
end

local UI = SUI.new("mouse")
UI:setPosition(minX, minY)
local gr = UI:vGroup(0,0)

local n = #COLORS*2
local GW = W / n
for i,c in ipairs(COLORS) do
	local grad1 = gradient(GW, H - 25, c[1], c[2])
	grad1:setShader(shader)
	gr:add(grad1)
	
	local grad2 = gradient(GW, H - 25, c[1], c[2])
	gr:add(grad2)
end

local gr2 = UI:hGroup(0,5)
gr2:add(UI:hSlider(0,3,GAMMA,false,{Pixel.new(0xf0f0f0, 1, W, 20), Pixel.new(0x323232, 1, 20, 20)},function(obj,value) shader:setConstant("fGamma", Shader.CFLOAT, 1, value) end):addValueText("Gamma"))
gr2:add(gr)
stage:addChild(UI)