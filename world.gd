extends Node3D

@export_file("*.pepsi") var level_path: String
@export var start_area: PackedScene

var level: Array
var current_wave = 0

func _ready() -> void:
    var data = JSON.parse_string(FileAccess.get_file_as_string(level_path))
    var config = MapConfig.new()
    config.from_obj(data["config"])
    level = data["waves"].map(func(w):
        var new_wave = Wave.new()
        new_wave.from_obj(w)
        return new_wave
    )
    %Map.create_from_config(config)
    $WaitTimer.start(3.0)
    $Player2.global_position = %Map.player_spawn_pos()


func _on_wait_timer_timeout() -> void:
    %Map.set_wave(level[current_wave])


func _on_map_wave_complete() -> void:
    if current_wave + 1 < level.size():
        current_wave += 1
        $WaitTimer.start()
    else:
        %Map.finish()


func _on_player_death_handler_transitioned() -> void:
    queue_free()


func _on_map_map_complete() -> void:
    var transition = Transition
    transition.set_color(Color.AZURE)
    transition.transition_to(start_area)
    transition.transition_started.connect(queue_free)
    transition.transition_data = { "from": "world" }
