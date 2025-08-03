extends PopupPanel

signal map_config_changed(config: MapConfig)

var current_map_config: MapConfig = MapConfig.new()

func _on_tile_size_box_value_changed(value: float) -> void:
    current_map_config.tile_size = int(value)
    map_config_changed.emit(current_map_config)


func _on_map_size_box_value_changed(value: float) -> void:
    current_map_config.map_size = int(value)
    map_config_changed.emit(current_map_config)


func _on_height_scale_box_value_changed(value: float) -> void:
    current_map_config.height_scale = int(value)
    map_config_changed.emit(current_map_config)


func _on_name_edit_text_submitted(new_text: String) -> void:
    current_map_config.level_name = new_text
    map_config_changed.emit(current_map_config)
