extends Enemy

@onready var anim: AnimationPlayer = $Visuals/fridge/AnimationPlayer

@export var projectile: PackedScene

func _on_cooldown_timeout() -> void:
    anim.play(&"Attack")

    var target_dir = get_aim_dir()

    #DebugDraw3D.draw_arrow(global_position, target_pos, Color.GREEN, 0.1, false, 1)

    var new_projectile: RigidBody3D = projectile.instantiate()
    new_projectile.linear_velocity = Vector3(
        target_dir.x,
        10.0,
        target_dir.z
    )
    add_child(new_projectile)
    new_projectile.global_position = %SpawnPos.global_position

func _physics_process(delta: float) -> void:
    super(delta)
    var target_dir = get_aim_dir()
    $Visuals.rotation.y = lerp_angle($Visuals.rotation.y, atan2(target_dir.x, target_dir.z), delta * 10)


func get_aim_dir() -> Vector3:
    var player_move_dir = player.linear_velocity
    var offset = player_move_dir * 1
    var target_pos = player.global_position + offset
    var target_dir = target_pos - global_position

    return target_dir
