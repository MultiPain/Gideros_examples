local layers = Layers.new("main", "middle", "ui")

layers:addTop(Pixel.new(0xff0000, 1, 128, 32)) -- add to top most layer 

-- You can choose layer by name or index
layers:add(1, Pixel.new(0x00ff00, 1, 32, 128)) -- add to first layer (by index)
layers:add("middle", Pixel.new(0x0000ff, 1, 64, 64)) -- add to "middle" layer (by name)
-- same as previous
--layers:add(2, Pixel.new(0x0000ff, 1, 64, 64))

-- local middle = layers:getLayer("middle")
-- local middle = layers:getLayer(2)
-- middle:clear() -- remove all layer childs
-- 
-- layers:removeAllLayers() -- remove all layers from screen and memory

stage:addChild(layers)