class_name Wave
extends RefCounted

# 6x6 2d array of positive ints
var heights: Array[Array]

func _init() -> void:
    set_size()

func set_size():
    heights.resize(6)
    for x in heights.size():
        var col = heights[x]
        heights[x].resize(6)
        for y in col.size():
            heights[x][y] = 0
    print(heights)

func json() -> String:
    var obj = { "heights": heights }
    var data_str = JSON.stringify(obj)

    from_json(data_str)
    return data_str

func from_json(data_str: String):
    var obj = JSON.parse_string(data_str)
    print(obj)
    var new_heights = obj["heights"]
    for x in new_heights.size():
        var col = new_heights[x]
        for y in col.size():
            var value: int = new_heights[x][y]
            prints(x, y, value)
            #print(heights)
            heights[x][y] = value
