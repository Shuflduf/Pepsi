extends Node3D

@export_file("*.pepsi") var level_path: String

var level: Array
var current_wave = 0

func _ready() -> void:
    var data = JSON.parse_string(FileAccess.get_file_as_string(level_path))
    print(data)
    level = data.map(func(w):
        var new_wave = Wave.new()
        new_wave.from_obj(w)
        return new_wave
    )
    print(level)
    $WaitTimer.start()


func _on_wait_timer_timeout() -> void:
    %Map.set_wave(level[current_wave])
