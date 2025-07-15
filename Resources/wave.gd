class_name Wave
extends RefCounted

# 6x6 2d array of positive ints
var heights: Array[Array]
var name: String = "if you see this something didnt work"

func _init() -> void:
    set_size()

func set_size():
    heights.resize(6)
    for x in heights.size():
        var col = heights[x]
        heights[x].resize(6)
        for y in col.size():
            heights[x][y] = 0

func obj() -> Dictionary:
    return {
        "heights": heights,
        "name": name
    }

func from_json(data_str: String):
    var data = JSON.parse_string(data_str)
    name = data["name"]
    var new_heights = data["heights"]
    for x in new_heights.size():
        var col = new_heights[x]
        for y in col.size():
            var value: int = new_heights[x][y]
            prints(x, y, value)
            #print(heights)
            heights[x][y] = value
