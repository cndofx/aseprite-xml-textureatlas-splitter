local xml = io.open(
    "/home/taylor/.local/share/Steam/steamapps/common/DefendersQuest/deluxe_gl/assets/gfx/_hd/defenders/mcguffin/h/atlas.xml",
    "r"
)
if not xml then return end

local sprites = {}

for line in xml:lines() do
    print("\n")
    for node in line:gmatch("<(%a+)%s* ") do
        if node == "SubTexture" then
            local name = line:match("name=\"([^\"]+)\"")
            sprites[name] = {}
            sprites[name]["name"] = name
            sprites[name]["flipX"] = line:match("flipX=\"(%a+)\"")
            sprites[name]["flipY"] = line:match("flipY=\"(%a+)\"")

            sprites[name]["frameWidth"] = line:match("frameWidth=\"(%d+)\"")
            sprites[name]["frameHeight"] = line:match("frameHeight=\"(%d+)\"")
            sprites[name]["frameX"] = line:match("frameX=\"(%d+)\"")
            sprites[name]["frameY"] = line:match("frameY=\"(%d+)\"")
            sprites[name]["width"] = line:match("width=\"(%d+)\"")
            sprites[name]["height"] = line:match("height=\"(%d+)\"")
            sprites[name]["x"] = line:match("x=\"(%d+)\"")
            sprites[name]["y"] = line:match("y=\"(%d+)\"")

            print("name = " .. sprites[name]["name"])
            print("flipX = " .. sprites[name]["flipX"])
            print("flipY = " .. sprites[name]["flipY"])
            print("x = " .. sprites[name]["x"])
            print("y = " .. sprites[name]["y"])
        end
    end
end
