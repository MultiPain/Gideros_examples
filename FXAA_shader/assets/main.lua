app @ application
N @ 500

app:setBackgroundColor(0)
local random = math.random

local function makeShot(x,y)
	line=Shape.new()
	line:setLineStyle(10,random()*256*256*256)
	line:beginPath()
	local sz=math.random(30)
	line:moveTo(0,sz)
	line:lineTo(0,-sz)
	line:endPath()
	local ang=random()*math.pi*2
	line.dy=-math.cos(ang)
	line.dx=math.sin(ang)
	line.life=500
	line:setRotation(ang*180/math.pi)
	line:setPosition(x,y)
	return line
end

local function choose(...) local t = {...} return t[random(#t)] end

----------------------------
------- CREATE SCENE -------
----------------------------
local minX, minY, maxX, maxY = app:getLogicalBounds()
local W = -minX + maxX
local H = -minY + maxY

local Scene = Sprite.new()

local tex = Texture.new("DOG.png", false) --< no filtering
local btm = Bitmap.new(tex)
Scene:addChild(btm)

for i = 1, N do 
	local line = makeShot(random(W), random(H))
	Scene:addChild(line)
end
----------------------------
------- SHADER SETUP -------
----------------------------

----------------------------
--------- UNIFORMS ---------
----------------------------
local POSITION = 0.5
local STROKE = 0.001
local FXAA_SPAN_MAX = 2
local FXAA_REDUCE_D1 = 4
local FXAA_REDUCE_D2 = 128
----------------------------
------ SHADER OBJECT -------
----------------------------
local shader = Shader.new("vs","fs",0,
{
	{name="vMatrix",type=Shader.CMATRIX,sys=Shader.SYS_WVP,vertex=true},
	{name="fColor",type=Shader.CFLOAT4,sys=Shader.SYS_COLOR,vertex=false},
	{name="fTexture",type=Shader.CTEXTURE,vertex=false},
	
	{name="fPos",type=Shader.CFLOAT,vertex=false},
	{name="fStroke",type=Shader.CFLOAT,vertex=false},
	{name="fResolution",type=Shader.CFLOAT2,vertex=false},
	{name="FXAA_SPAN_MAX",type=Shader.CFLOAT2,vertex=false},
	
	{name="FXAA_REDUCE_D1",type=Shader.CFLOAT2,vertex=false},
	{name="FXAA_REDUCE_D2",type=Shader.CFLOAT2,vertex=false},
},
{
	{name="vVertex",type=Shader.DFLOAT,mult=3,slot=0,offset=0},
	{name="vColor",type=Shader.DUBYTE,mult=4,slot=1,offset=0},
	{name="vTexCoord",type=Shader.DFLOAT,mult=2,slot=2,offset=0},
})
-- INITAL UNIFORM VALUES  --
shader:setConstant("fResolution", Shader.CFLOAT2, 1, {W, H})
shader:setConstant("fPos", Shader.CFLOAT, 1, POSITION)
shader:setConstant("fStroke", Shader.CFLOAT, 1, STROKE)
shader:setConstant("FXAA_SPAN_MAX", Shader.CFLOAT, 1, FXAA_SPAN_MAX)
shader:setConstant("FXAA_REDUCE_D1", Shader.CFLOAT, 1, FXAA_REDUCE_D1)
shader:setConstant("FXAA_REDUCE_D2", Shader.CFLOAT, 1, FXAA_REDUCE_D2)
----------------------------
------- apply shader -------
----------------------------

local rt = RenderTarget.new(Scene:getSize())

local ActualScene = Bitmap.new(rt)
ActualScene:setShader(shader)
stage:addChild(ActualScene)
ActualScene:setPosition(minX,minY)
stage:addEventListener("enterFrame", function()
	rt:clear(0,0)
	rt:draw(Scene)
end)

----------------------------
------------ UI ------------
----------------------------
local UI = SUI.new("mouse")
stage:addChild(UI)

local gr = UI:hGroup(0, 10)
gr:add(UI:hSlider(0,1,POSITION,false, {Pixel.new(0x323232,1,200,20), Pixel.new(0xffffff,1,20,20)}, function(obj,value) POSITION = value shader:setConstant("fPos", Shader.CFLOAT, 1, POSITION) end):addValueText("FXAA / Original"))
gr:add(UI:hSlider(0,0.1,STROKE,false, {Pixel.new(0x323232,1,200,20), Pixel.new(0xffffff,1,20,20)}, function(obj,value) STROKE = value shader:setConstant("fStroke", Shader.CFLOAT, 1, STROKE) end):addValueText("Stroke"))
gr:add(UI:hSlider(1,32,FXAA_SPAN_MAX,true, {Pixel.new(0x323232,1,200,20), Pixel.new(0xffffff,1,20,20)}, function(obj,value) FXAA_SPAN_MAX = value shader:setConstant("FXAA_SPAN_MAX", Shader.CFLOAT, 1, FXAA_SPAN_MAX) end):addValueText("FXAA_SPAN_MAX"))
gr:add(UI:hSlider(1,32,FXAA_REDUCE_D1,true, {Pixel.new(0x323232,1,200,20), Pixel.new(0xffffff,1,20,20)}, function(obj,value) FXAA_REDUCE_D1 = value shader:setConstant("FXAA_REDUCE_D1", Shader.CFLOAT, 1, FXAA_REDUCE_D1) end):addValueText("FXAA_REDUCE_D1"))
gr:add(UI:hSlider(1,256,FXAA_REDUCE_D2,true, {Pixel.new(0x323232,1,200,20), Pixel.new(0xffffff,1,20,20)}, function(obj,value) FXAA_REDUCE_D2 = value shader:setConstant("FXAA_REDUCE_D2", Shader.CFLOAT, 1, FXAA_REDUCE_D2)end):addValueText("FXAA_REDUCE_D2"))