extends Control

@export var wave_time_scene: PackedScene

var damage_taken = 0:
    set(new):
        damage_taken = new
        %DamageLabel.text = str(damage_taken)
var level_name = "[LEVEL NAME]":
    set(new):
        level_name = new
        %LevelComplete.text = "%s Complete!" % new
var wave_times = []:
    set(new):
        wave_times = new
        for child in %WaveTimes.get_children():
            child.queue_free()
        for time in new:
            var new_wave_time: WaveTime = wave_time_scene.instantiate()
            %WaveTimes.add_child(new_wave_time)
            new_wave_time.time_value.text = str(time["value"]).pad_decimals(2)
            new_wave_time.wave_name.text = time["wave_name"]

        %FullLevelTime.text = str(
            new.map(func(val): return val["value"]).\
            reduce(func(accum, next): return accum + next)
        ).pad_decimals(2)

        #%WaveTimes.remove_child()

func _ready() -> void:
    level_name = "AAAAASAVOLSIAH"
    wave_times = [
        {"wave_name": "GAMING", "value": 59.23},
        {"wave_name": "GAMING2", "value": 5.23}
    ]
