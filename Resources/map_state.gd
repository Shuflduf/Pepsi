class_name MapState
extends RefCounted

# 6x6 2d array of positive ints
var heights: Array[Array]

func _init() -> void:
    heights.resize(6)
    for x in heights:
        x.resize(6)

func json() -> String:
    return ""
