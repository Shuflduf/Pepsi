class_name Wave
extends Resource

# 6x6 2d array of positive ints
var heights: Array
var enemies: Array

var name: String = "if you see this something didnt work"

var nav_mesh: NavigationMesh

func _init() -> void:
    heights = empty_2d_arr(6, 0)
    enemies = empty_2d_arr(6, -1)

func empty_2d_arr(size: int, val: Variant) -> Array:
    var new_arr = []
    for x in range(size):
        var row = []
        for y in range(size):
            row.append(val)
        new_arr.append(row)

    return new_arr

func obj() -> Dictionary:
    return {
        "heights": heights,
        "enemies": enemies,
        "name": name
    }

func from_obj(data: Dictionary):
    heights = data["heights"].map(func(col): return col.map(func(val): return int(val)))
    enemies = data["enemies"].map(func(col): return col.map(func(val): return int(val)))
    name = data["name"]

#func from_json(data_str: String):
    #var data = JSON.parse_string(data_str)
    #name = data["name"]
    #var new_heights = data["heights"]
    #for x in new_heights.size():
        #var col = new_heights[x]
        #for y in col.size():
            #var value: int = new_heights[x][y]
            #prints(x, y, value)
            ##print(heights)
            #heights[x][y] = value
