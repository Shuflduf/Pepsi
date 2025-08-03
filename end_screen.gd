extends Control

@export var wave_time_scene: PackedScene

var wave_times = []:
    set(new):
        wave_times = new
        for child in %WaveTimes.get_children():
            child.queue_free()
        for time in new:
            var new_wave_time: WaveTime = wave_time_scene.instantiate()
            %WaveTimes.add_child(new_wave_time)
            new_wave_time.time_value.text = str(time["value"])
            new_wave_time.wave_name.text = time["wave_name"]

        #%WaveTimes.remove_child()

func _ready() -> void:
    wave_times = [
        {"wave_name": "GAMING", "value": 5935.23},
        {"wave_name": "GAMING2", "value": 5.23}
    ]
