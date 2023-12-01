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

-- load xml data from file
local xml = io.open(
    "/home/taylor/.local/share/Steam/steamapps/common/DefendersQuest/deluxe_gl/assets/gfx/_hd/defenders/mcguffin/h/atlas.xml",
    "r"
)
if not xml then
    return app.alert("Unable to read xml.")
end

-- parse xml data
local xml_sprites = {}
for line in xml:lines() do
    print("\n")
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

            print("name = " .. xml_sprites[name]["name"])
            print("flipX = " .. xml_sprites[name]["flipX"])
            print("flipY = " .. xml_sprites[name]["flipY"])
            print("frameWidth = " .. xml_sprites[name]["frameWidth"])
            print("frameHeight = " .. xml_sprites[name]["frameHeight"])
            print("frameX = " .. xml_sprites[name]["frameX"])
            print("frameY = " .. xml_sprites[name]["frameY"])
            print("x = " .. xml_sprites[name]["x"])
            print("y = " .. xml_sprites[name]["y"])
        end
    end
end

-- get bounds of the sprite to create
local bounds = Rectangle()
for _, xml_sprite in pairs(xml_sprites) do
    local rect = Rectangle(0, 0, xml_sprite["frameWidth"], xml_sprite["frameHeight"])
    bounds = bounds:union(rect)
end
print(tostring(bounds))

-- get currently active sprite
local source_sprite = app.sprite
if not source_sprite then
    return app.alert("You must have an image open!")
end

-- create the new sprite and copy individual sprites into new layers
local new_sprite = Sprite(bounds.width, bounds.height)
local first_layer = new_sprite.layers[1]

print(source_sprite.filename)

for _, xml_sprite in pairsByKeys(xml_sprites) do
    if true then
        local x = xml_sprite["x"]
        local y = xml_sprite["y"]
        local width = xml_sprite["width"]
        local height = xml_sprite["height"]
        source_sprite.selection:select(Rectangle(x, y, width, height))

        app.sprite = source_sprite
        app.command.CopyMerged()
        app.sprite = new_sprite
        app.command.NewLayer { fromClipboard = true }
        app.activeLayer.name = xml_sprite["name"]

        local cel = app.cel
        cel.position = Point(
            xml_sprite["frameX"] * -1,
            xml_sprite["frameY"] * -1)
    end
end

new_sprite:delete_layer(first_layer)
new_sprite.selection:deselect()
