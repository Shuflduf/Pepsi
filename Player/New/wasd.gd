extends PlayerComponent

@export var cam_pivot: Node3D
@export var run_particles: GPUParticles3D
@export var run_sfx: AudioStreamPlayer3D
@export var walk_fx_speed = 1.0

var walk_fx_cooldown = 0.0
var walk_fx_cooldown_timer = 0.3
var speed_factor = 1.0

func _physics_process(delta: float) -> void:
    DebugDraw2D.set_text("pos", player.global_position)
    var input_dir = Input.get_vector(&"left", &"right", &"forward", &"backward")
    var direction = input_dir.rotated(-cam_pivot.global_rotation.y)
    var move_dir = Vector3(
        direction.x,
        0,
        direction.y
    )

    player.apply_central_force(move_dir * delta * player.ground_speed)

    walk_fx_cooldown -= delta
    if walk_fx_cooldown <= 0.0 and not direction.is_zero_approx() and player.is_on_floor():
        reset_fx_cooldown()
        run_sfx.pitch_scale = randf_range(0.9, 1.1)
        run_sfx.play()
        run_particles.restart()

    if !player.is_on_floor():
        reset_fx_cooldown()

func reset_fx_cooldown():
    walk_fx_cooldown = walk_fx_cooldown_timer / speed_factor / walk_fx_speed
