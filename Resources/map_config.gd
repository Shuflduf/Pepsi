class_name MapConfig
extends Resource

var tile_size: int = 5
var map_size: int = 6
var height_scale: int = 2

func obj() -> Dictionary:
    return {
        "tile_size": tile_size,
        "map_size": map_size,
        "height_scale": height_scale,
    }

func from_obj(data: Dictionary):
    tile_size = data["tile_size"]
    map_size = data["map_size"]
    height_scale = data["height_scale"]
