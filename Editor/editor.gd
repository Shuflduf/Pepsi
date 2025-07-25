extends Control

var wave = 0
var current_state: Array[Wave] = []
var map_config: MapConfig = MapConfig.new()

#_ready
    #update_map()
func _ready() -> void:
    update_cam_pos(map_config)


func current_wave() -> Wave:
    if current_state.size() < wave + 1:
        var new_wave = Wave.new()
        new_wave.resize(map_config.map_size)
        current_state.push_back(new_wave)

    return current_state[wave]

func update_map():
    %Map.set_wave(current_wave())

# HEIGHTS
func _on_height_updated_height(x: int, y: int, new_val: int) -> void:
    current_wave().heights[x][y] = new_val
    update_map()

# ENEMIES
func _on_enemies_updated_enemies(x: int, y: int, new_val: int) -> void:
    current_wave().enemies[x][y] = new_val
    update_map()

# EXTRA
func _on_extra_switched_wave(new_wave: int) -> void:
    wave = new_wave
    update_map()
    %Height.update_buttons(current_wave().heights)
    %Enemies.update_buttons(current_wave().enemies)


func _on_extra_deleted_wave(del_wave: int) -> void:
    current_state.remove_at(del_wave)


func _on_save_dialog_file_selected(path: String) -> void:
    var file = FileAccess.open(path, FileAccess.WRITE)
    var data = {
        "waves": current_state.map(func(w): return w.obj()),
        "config": map_config.obj()
    }
    file.store_string(str(data))

func _on_load_dialog_file_selected(path: String) -> void:
    current_state = []
    var file_contents = FileAccess.get_file_as_string(path)
    var data = JSON.parse_string(file_contents)
    for wave_data in data:
        var new_wave = Wave.new()
        new_wave.from_obj(wave_data)
        current_state.push_back(new_wave)

    %Extra.update_options(current_state.map(func(w): return w.name))
    _on_extra_switched_wave(0)


func _on_extra_name_changed(new_name: String) -> void:
    current_wave().name = new_name


func _on_map_config_panel_map_config_changed(config: MapConfig) -> void:
    map_config = config
    %Map.create_from_config(config)
    update_cam_pos(config)
    current_state = []
    wave = 0
    #_on_extra_switched_wave(wave)
    %Extra.reset()
    %Height.create_buttons(config.map_size)
    #%PreviewCam.position.x =
    #%PreviewCam.position.z = config.map_size * config.tile_size + config.tile_size


func update_cam_pos(config: MapConfig):
    var center = (config.map_size * config.tile_size / 2.0) - config.tile_size / 2.0
    var center_pos = Vector3(center, 0.0, center)
    %CamOrbit.position = center_pos
