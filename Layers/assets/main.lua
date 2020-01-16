local layers = Layers.new("middle") -- create 1 layer
layers:addLayer("top") -- add another one on top 
layers:addLayer("im_gona_be_removed", 1) -- add another one to the bottom

layers:removeLayer("im_gonna_be_removed") -- delete first layer
layers:addLayer("im_also_gonna_be_removed", 1)
layers:removeLayer(1) -- delete first layer

layers:addLayer("bottom", 1) -- add layer to the bottom (again)
--layers:addLayer("bottom", 1) -- ERROR you cant replace existing layer
--layers:addLayer("we_need_to_go_deeper", 1) -- now we have structure: 
-- 1 - we_need_to_go_deeper
-- 2 - bottom
-- 3 - middle
-- 4 - top

layers:addTop(Pixel.new(0xff0000, 1, 128, 32)) -- add to top most layer 
-- You can choose layer by name or index
layers:add(1, Pixel.new(0x00ff00, 1, 32, 128)) -- add to first layer (by index)
layers:add("middle", Pixel.new(0x0000ff, 1, 64, 64)) -- add to "middle" layer (by name)
-- same as previous
--layers:add(2, Pixel.new(0x0000ff, 1, 64, 64))

-- local middle = layers:getLayer("middle") -- get layer object by name
-- local middle = layers:getLayer(2) -- get layer object by index 
-- middle:clear() -- remove all layer childs
-- 
-- layers:removeAllLayers() -- remove all layers from screen and memory

print("Total amount of layers:", layers:getNumChildren()) -- to get amount of layers, simply use getNumChildren() method

stage:addChild(layers)
