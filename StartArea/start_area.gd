extends Node3D

@export var tutorial_scene: PackedScene
@export var player_cam: Camera3D

var moving_liquid = false
var started_already = false

func _ready() -> void:
    var effect: AudioEffectFilter = AudioServer.get_bus_effect(1, 0)
    effect.cutoff_hz = 50

func _physics_process(delta: float) -> void:
    if moving_liquid:
        $Liquid.position.y += delta / 5

    var liquid_pos = $Liquid.global_position.y + 0.3
    var above_player = liquid_pos > player_cam.global_position.y
    #if above_player:
        #$SlowPlayer.fade_away()

func _on_slow_player_game_started() -> void:
    if started_already:
        return
    started_already = true

    MusicPlayer.playing = false

    $WorldEnvironment.environment.sky.sky_material.energy_multiplier = 0.1
    moving_liquid = true
    $Props/Lamp.turn_purple()
    $Props/Lamp2.turn_purple()
    await get_tree().create_timer(3.0).timeout
    $WorldEnvironment.environment.sky.sky_material.energy_multiplier = 0.3
    var tween = get_tree().create_tween()
    tween.tween_property($Noise, ^"volume", 0.1, 10.0)


func _on_slow_player_transition_started() -> void:
    await get_tree().create_timer(1.0).timeout
    var transition: SceneTransition = Transition
    transition.set_color(Color("060207"))
    transition.transition_started.connect(func():
        queue_free()
    )
    transition.transition_to(tutorial_scene)


func _on_interations_pressed(interacted: CollisionObject3D) -> void:
    if interacted is Area3D:
        print("button")
        %VendingMachine.button_pressed(interacted)
    elif interacted is BottleProp:
        print("bottle")
