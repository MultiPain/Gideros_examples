--app:setBackgroundColor(0x323232)

local function LoadResources()
	Game.TILE_TEXTURE = Texture.new("gfx/TILE.png", true)
end

local function LoadApp()
	local TS = os.clock()
	require "Easing"
	require "SceneManager"
	
	LoadResources()
	
	local manager = SceneManager.new{
		["Game"] = GameScene
	}
	manager:changeScene("Game")
	stage:addChild(manager)
	
	Game.manager = manager
	
	print("Loading time:", os.clock() - TS, "s.")
end

Core.asyncCall(LoadApp)