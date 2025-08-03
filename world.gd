extends Node3D

@export_file("*.pepsi") var level_path: String
@export var start_area: PackedScene

var level: Array
var current_wave = 0
var config: MapConfig

var time_on_waves = []
var current_wave_time = 0.0
var all_damage_taken = 0
var counting = false

var can_transition = false

func _physics_process(delta: float) -> void:
    DebugDraw2D.set_text("time", [time_on_waves, current_wave_time])
    if counting:
        current_wave_time += delta

func _ready() -> void:
    var data = JSON.parse_string(FileAccess.get_file_as_string(level_path))
    config = MapConfig.new()
    config.from_obj(data["config"])
    level = data["waves"].map(func(w):
        var new_wave = Wave.new()
        new_wave.from_obj(w)
        return new_wave
    )
    %Map.create_from_config(config)
    $WaitTimer.start(3.0)
    $Player2.global_position = %Map.player_spawn_pos()
    var health_comp = $Player2.get_component("Health")
    if health_comp:
        health_comp.damage_taken.connect(_on_player_damage_taken)

func _on_player_damage_taken(damage: int):
    all_damage_taken += damage
    print(all_damage_taken)

func _on_wait_timer_timeout() -> void:
    %Map.set_wave(level[current_wave])
    counting = true


func _on_map_wave_complete() -> void:
    counting = false
    time_on_waves.append({ "wave_name": level[current_wave].name, "value": current_wave_time })
    if current_wave + 1 < level.size():
        current_wave_time = 0.0
        current_wave += 1
        $WaitTimer.start()
    else:
        %Map.finish()


func _on_player_death_handler_transitioned() -> void:
    queue_free()


func _on_map_map_complete() -> void:
    $EndScreen.wave_times = time_on_waves
    $EndScreen.level_name = config.level_name
    $EndScreen.damage_taken = all_damage_taken
    get_tree().get_first_node_in_group(&"LookAround").switch_modes()
    %Anim.play(&"end_screen")
    can_transition = true

func finish():
    var transition = Transition
    transition.set_color(Color.AZURE)
    transition.transition_to(start_area)
    transition.transition_started.connect(queue_free)
    transition.transition_data = { "from": "world" }


func _on_finish_pressed() -> void:
    if not can_transition:
        return
    finish()
