local function hex2rgb(hex)
	local r = (hex >> 16) / 255
	local g = (hex >> 8 & 0xff) / 255
	local b = (hex & 0xff) / 255
	return r,g,b
end

local ShadowShader = Shader.new("vShader", "fShader", 0, 
	{
		{name="vMatrix",type=Shader.CMATRIX,sys=Shader.SYS_WVP,vertex=true},
		{name="vTexInfo",type=Shader.CFLOAT4,sys=Shader.SYS_TEXTUREINFO,vertex=true},
		{name="fResolution",type=Shader.CFLOAT2,vertex=false},
		
		{name="LightRadius",type=Shader.CFLOAT,vertex=false},
		{name="LightSmooth",type=Shader.CFLOAT,vertex=false},
		{name="ShapeType",type=Shader.CINT,vertex=false},
		{name="ObjectPos",type=Shader.CFLOAT2,vertex=false},
		{name="RectSize",type=Shader.CFLOAT2,vertex=false},
		{name="RectRotation",type=Shader.CFLOAT,vertex=false},
		{name="CircleRadius",type=Shader.CFLOAT,vertex=false},
	},{
		{name="vVertex",type=Shader.DFLOAT,mult=3,slot=0,offset=0},
		{name="vColor",type=Shader.DUBYTE,mult=4,slot=1,offset=0},
		{name="vTexCoord",type=Shader.DFLOAT,mult=2,slot=2,offset=0},
	}
)

Light = Core.class(Sprite)

function Light:init(tex, r, color, alpha, shadowColor, shadowAlpha)
	self.r = r
	self.d = 2*r
	self.smooth = 1
	
	self.drawCalls = 0
	
	self.rt = RenderTarget.new(self.d, self.d, true)
	self.shadow = Bitmap.new(self.rt)
	self.shadow:setShader(ShadowShader)
	
	self.canvas = RenderTarget.new(self.d, self.d, true)
	self.completeShadow = Bitmap.new(self.canvas)
	self:addChild(self.completeShadow)
	if tex then 
		local r,g,b = hex2rgb(color)
		
		self.lightSourceImg = Bitmap.new(tex)
		self.lightSourceImg:setScale(self.d / tex:getWidth())
		self.lightSourceImg:setColorTransform(r,g,b,alpha)
		self.canvas:draw(self.lightSourceImg)
		self.drawSrcImg = true
	end
end

function Light:setColor(color, alpha)
	if self.lightSourceImg then 
		local r,g,b = hex2rgb(color)
		self.lightSourceImg:setColorTransform(r,g,b,alpha)
	end
end

function Light:update(nearbyObjects)
	if #nearbyObjects == 0 then return end
	
	ShadowShader:setConstant("fResolution", Shader.CFLOAT2, 1, {self.d,self.d})
	ShadowShader:setConstant("LightRadius",Shader.CFLOAT, 1, self.r)
	ShadowShader:setConstant("LightSmooth",Shader.CFLOAT, 1, self.smooth)
	
	self.canvas:clear(0,0)
	if self.drawSrcImg then 
		self.canvas:draw(self.lightSourceImg)
	end
	local sx,sy = self:getPosition()
	sx += self.r
	sy += self.r
	self.drawCalls = 0
	for i,v in ipairs(nearbyObjects) do 
		local x,y = v:getPosition()
		local mx = v.w and math.max(v.w,v.h) or v.r*2
		local d = (x-sx)^2+(y-sy)^2
		if d < (self.r+mx/2)^2 then
			local lx,ly = self:globalToLocal(x,y)
			
			if v.type == "rect" then 
				ShadowShader:setConstant("ObjectPos", Shader.CFLOAT2, 1, {lx - v.w / 2,ly - v.h / 2})
				ShadowShader:setConstant("ShapeType", Shader.CINT, 1, 1)
				ShadowShader:setConstant("RectSize", Shader.CFLOAT2, 1, {v.w,v.h})
				ShadowShader:setConstant("RectRotation", Shader.CFLOAT, 1, ^<v:getRotation())
			elseif v.type == "circle" then 
				ShadowShader:setConstant("ObjectPos", Shader.CFLOAT2, 1, {lx,ly})
				ShadowShader:setConstant("ShapeType", Shader.CINT, 1, 0)
				ShadowShader:setConstant("CircleRadius", Shader.CFLOAT, 1, v.r)
			end
			
			self.canvas:draw(self.shadow)
			self.drawCalls += 1
		end
	end
end

function Light:setSmooth(v)
	self.smooth = v
end
