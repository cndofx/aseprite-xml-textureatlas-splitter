-- http://www.lua.org/pil/19.3.html
local function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0
    local iter = function()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end

local function numerical_then_alphabetical_sort(a, b)
    local num_a = tonumber(a)
    local num_b = tonumber(b)
    if num_a and num_b then
        return num_a < num_b
    elseif num_a and not num_b then
        return true
    elseif not num_a and num_b then
        return false
    else
        return a < b
    end
end

-- prompt user for the xml file to use
local dialog = Dialog("XML TextureAtlas Splitter")
dialog:label { id = "desc", label = "", text = "Choose the location of the XML file:" }
dialog:file { id = "file", label = "Choose a file:", open = true, entry = true }
dialog:combobox { id = "target", label = "Copy to:", option = "Frames", options = { "Frames", "Layers" } }
dialog:button { id = "ok", text = "OK", focus = true }
dialog:button { text = "Cancel" }
dialog:show()

local ddata = dialog.data
if not ddata.ok then return end

-- load xml data from file
local xml = io.open(ddata.file, "r")
if not xml then
    return app.alert("Unable to read xml.")
end

-- parse xml data
local xml_sprites = {}
for line in xml:lines() do
    for node in line:gmatch("<(%a+)%s* ") do
        if node == "SubTexture" then
            local name = line:match("name=\"([^\"]+)\"")
            xml_sprites[name] = {}
            xml_sprites[name]["name"] = name
            xml_sprites[name]["flipX"] = line:match("flipX=\"(%a+)\"")
            xml_sprites[name]["flipY"] = line:match("flipY=\"(%a+)\"")

            xml_sprites[name]["frameWidth"] = line:match("frameWidth=\"(%d+)\"")
            xml_sprites[name]["frameHeight"] = line:match("frameHeight=\"(%d+)\"")
            xml_sprites[name]["frameX"] = line:match("frameX=\"(%-?%d+)\"")
            xml_sprites[name]["frameY"] = line:match("frameY=\"(%-?%d+)\"")
            xml_sprites[name]["width"] = line:match("width=\"(%d+)\"")
            xml_sprites[name]["height"] = line:match("height=\"(%d+)\"")
            xml_sprites[name]["x"] = line:match("x=\"(%d+)\"")
            xml_sprites[name]["y"] = line:match("y=\"(%d+)\"")
        end
    end
end

-- get bounds of the sprite to create
local bounds = Rectangle()
for _, xml_sprite in pairs(xml_sprites) do
    local rect = Rectangle(0, 0, xml_sprite["frameWidth"], xml_sprite["frameHeight"])
    bounds = bounds:union(rect)
end

-- get currently active sprite
local source_sprite = app.sprite
if not source_sprite then
    return app.alert("You must have an image open!")
end

-- create the new sprite and copy individual sprites into new layers/frames
local new_sprite = Sprite(bounds.width, bounds.height)

for _, xml_sprite in pairsByKeys(xml_sprites, numerical_then_alphabetical_sort) do
    local x = xml_sprite["x"]
    local y = xml_sprite["y"]
    local width = xml_sprite["width"]
    local height = xml_sprite["height"]
    source_sprite.selection:select(Rectangle(x, y, width, height))

    app.sprite = source_sprite
    app.command.CopyMerged()
    app.sprite = new_sprite

    if ddata.target == "Layers" then
        -- copy sprites to layers
        app.command.NewLayer { fromClipboard = true }
        app.activeLayer.name = xml_sprite["name"]
    elseif ddata.target == "Frames" then
        -- copy sprites to frames
        new_sprite:newEmptyFrame()
        app.cel = new_sprite:newCel(app.activeLayer, app.frame)
        app.command.Paste()
        print("pasted sprite onto frame " .. tostring(app.frame.frameNumber))
    end

    local new_x = xml_sprite["frameX"] * -1
    local new_y = xml_sprite["frameY"] * -1
    local cel = app.cel
    cel.position = Point(new_x, new_y)
    print("moved name=" ..
        xml_sprite["name"] .. " to position x: " .. tostring(new_x) .. ", y: " .. tostring(new_y))
end

if ddata.target == "Layers" then
    new_sprite:deleteLayer(new_sprite.layers[1])
elseif ddata.target == "Frames" then
    new_sprite:deleteFrame(new_sprite.frames[1])
end
