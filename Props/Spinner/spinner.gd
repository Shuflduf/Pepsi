extends Node3D

var active = false
var connected_signal = false
var jump_scale = 0.0
var player: PhysicsEntity
var fizz_component: BottleComponent
var speed_component: BottleComponent

func _on_area_3d_body_entered(body: Node3D) -> void:
    if body.is_in_group(&"Player") and not connected_signal:
        player = body
        get_relevant_components()
        body.get_component("Jump").jumped.connect(_on_player_jumped)
        connected_signal = true

func get_relevant_components():
    var bottle = player.find_child("Bottle")
    if !bottle:
        return
    fizz_component = bottle.find_child("Fizz")
    speed_component = bottle.find_child("SpeedIncrease")

func _physics_process(delta: float) -> void:
    if $Area3D.has_overlapping_bodies():
        jump_scale += delta * 8 * speed_component.factor
        jump_scale = minf(jump_scale, 20.0 * speed_component.factor)
        add_fizz(delta)
        DebugDraw2D.set_text("jump", jump_scale)

        #player.linear_velocity = Vector3.ZERO
        player.global_rotation.y += jump_scale * delta
        player.global_position = lerp(player.global_position, global_position, delta * 3)
    else:
        jump_scale = 0.0

func _on_player_jumped():
    player.apply_central_impulse(Vector3.UP * jump_scale)

    #var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
    #tween.tween_property(player, ^"rotation:y", jump_scale / 40.0, 0.2).as_relative()

func add_fizz(delta: float):

    fizz_component.value += delta * jump_scale * 0.08
