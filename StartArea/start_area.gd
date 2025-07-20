extends Node3D

@export var tutorial_scene: PackedScene

var moving_liquid = false

func _physics_process(delta: float) -> void:
    if moving_liquid:
        $Liquid.position.y += delta / 5

    var liquid_pos = $Liquid.global_position.y + 0.3
    var above_player = liquid_pos > $SlowPlayer.camera.global_position.y
    if above_player:
        $SlowPlayer.fade_away()

func _on_slow_player_game_started() -> void:
    $WorldEnvironment.environment.sky.sky_material.energy_multiplier = 0.1
    moving_liquid = true
    $Props/Lamp.turn_purple()
    $Props/Lamp2.turn_purple()


func _on_slow_player_transition_started() -> void:
    print("bAAAAA")
    var transition: SceneTransition = Transition
    transition.set_color(Color("060207"))
    transition.transition_started.connect(func():
        print("AAAAA")
        queue_free()
        )
    transition.transition_to(tutorial_scene)
