class_name MapConfig
extends Resource

var level_name: String = "New Level"
var tile_size: int = 5
var map_size: int = 6
var height_scale: int = 1

func obj() -> Dictionary:
    return {
        "level_name": level_name,
        "tile_size": tile_size,
        "map_size": map_size,
        "height_scale": height_scale,
    }

func from_obj(data: Dictionary):
    level_name = data["level_name"]
    tile_size = data["tile_size"]
    map_size = data["map_size"]
    height_scale = data["height_scale"]
