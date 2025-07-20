extends Enemy

@onready var anim: AnimationPlayer = $Visuals/fridge/AnimationPlayer

@export var projectile: PackedScene

func _ready() -> void:
    super()
    await get_tree().create_timer(randf_range(0.0, 1.0)).timeout
    $Cooldown.start()

func _on_cooldown_timeout() -> void:
    anim.play(&"Attack")
    if player == null:
        return
    if disabled:
        return

    await get_tree().create_timer(0.5).timeout

    var target_dir = calculate_lead_velocity_with_gravity(
        player.global_position,
        player.linear_velocity,
        global_position,
        40.0
    )

    DebugDraw3D.draw_ray(global_position, target_dir, target_dir.length(), Color.BLUE, 2.0)

    var new_projectile: RigidBody3D = projectile.instantiate()
    new_projectile.linear_velocity = target_dir
    add_child(new_projectile)
    new_projectile.global_position = %SpawnPos.global_position



func _physics_process(delta: float) -> void:
    super(delta)
    var target_dir = get_aim_dir()
    if target_dir != Vector3.ZERO:
        $Visuals.rotation.y = lerp_angle($Visuals.rotation.y, atan2(target_dir.x, target_dir.z), delta * 10)


func get_aim_dir() -> Vector3:
    if player == null:
        return Vector3.ZERO

    var player_move_dir = player.linear_velocity
    var offset = player_move_dir
    var target_pos = player.global_position + offset
    var target_dir = target_pos - global_position

    return target_dir

# https://www.youtube.com/watch?v=aKd32I0uwAQ
func calculate_lead_velocity_with_gravity(
    player_pos: Vector3,
    player_vel: Vector3,
    enemy_pos: Vector3,
    projectile_speed: float,
) -> Vector3:
    var to_player = player_pos - enemy_pos
    var best_v = Vector3.ZERO
    var found = false

    # search for time to intercept
    var min_t = 0.01
    var max_t = 5.0
    var step_t = 0.01
    var t = min_t
    while t < max_t:
        t += step_t
        # predict future player position
        var future_player_pos = player_pos + player_vel * t
        # what velocity do we need to reach that point in t seconds, accounting for gravity
        var required_velocity = (future_player_pos - enemy_pos - 0.5 * get_gravity() * t * t) / t
        var speed = required_velocity.length()
        if abs(speed - projectile_speed) < 0.5: # allow small error
            best_v = required_velocity.normalized() * projectile_speed
            found = true
            break # take first valid solution

    if found:
        return best_v
    else:
        # fall back: fire directly at player
        var direct_velocity = (to_player.normalized() * projectile_speed)
        return direct_velocity
