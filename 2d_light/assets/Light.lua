local function hex2rgb(hex)
	local r = (hex >> 16) / 255
	local g = (hex >> 8 & 0xff) / 255
	local b = (hex & 0xff) / 255
	return r,g,b
end

local LightShader = Shader.new("vLight", "fLight", 0, 
	{
		{name="vMatrix",type=Shader.CMATRIX,sys=Shader.SYS_WVP,vertex=true},
		{name="fColor",type=Shader.CFLOAT4,sys=Shader.SYS_COLOR,vertex=false},
		{name="fTexture",type=Shader.CTEXTURE,vertex=false},
		{name="fResolution",type=Shader.CFLOAT,vertex=false},
		
		{name="fResolution",type=Shader.CFLOAT,vertex=false},		
		{name="rectPos",type=Shader.CFLOAT2,vertex=false},		
		{name="rectSize",type=Shader.CFLOAT2,vertex=false},		
		{name="lightColor",type=Shader.CFLOAT4,vertex=false},		
		{name="lightRadius",type=Shader.CFLOAT,vertex=false},		
		{name="lightPower",type=Shader.CFLOAT,vertex=false},
	},{
		{name="vVertex",type=Shader.DFLOAT,mult=3,slot=0,offset=0},
		{name="vColor",type=Shader.DUBYTE,mult=4,slot=1,offset=0},
		{name="vTexCoord",type=Shader.DFLOAT,mult=2,slot=2,offset=0},
	}
)

LightShader:setConstant("fResolution", Shader.CFLOAT2, 1, {4,4})
LightShader:setConstant("rectPos", Shader.CFLOAT2, 1, {0,0})
LightShader:setConstant("rectSize", Shader.CFLOAT2, 1, {0,0})

Light = Core.class(Sprite)

function Light:init(world, radius, color, alpha, tex)
	self.world = world
	self.r = radius
	
	local r,g,b = hex2rgb(color)
	
	self.lightSourceImg = Bitmap.new(tex)
	self.lightSourceImg:setScale((self.r * 2) / tex:getWidth())
	self.lightSourceImg:setColorTransform(r,g,b,alpha)
	
	self.rt = RenderTarget.new(self.r * 2, self.r * 2)
	self.shadow = Bitmap.new(self.rt)
	self.shadow:setShader(LightShader)
	
	self.canvas = RenderTarget.new(self.r * 2, self.r * 2)
	self.canvas:draw(self.lightSourceImg)
	self.completeShadow = Bitmap.new(self.canvas)
	self:addChild(self.completeShadow)
end

function Light:update()
	local x,y = self:getPosition()
	
	local list, len = self.world:queryRect(x,y,self.r*2,self.r*2)
	
	if len > 0 then 
		LightShader:setConstant("fResolution", Shader.CFLOAT2, 1, {self.r*2,self.r*2})
		
		self.canvas:clear(0,0)
		self.canvas:draw(self.lightSourceImg)
		for i,rect in ipairs(list) do 
			local bx,by = rect:getPosition()
			local bw,bh = rect:getSize()
			local lx,ly = self:globalToLocal(bx,by)
			
			LightShader:setConstant("rectPos", Shader.CFLOAT2, 1, {lx,ly})
			LightShader:setConstant("rectSize", Shader.CFLOAT2, 1, {bw,bh})
			
			self.canvas:draw(self.shadow)
		end
	end
end


function Light:setPosition(x, y)
	Sprite.setPosition(self, x, y)
	self:update()
end