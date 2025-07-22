extends PlayerComponent

@export var cam_pivot: Node3D

func _physics_process(delta: float) -> void:
    var input_dir = Input.get_vector(&"left", &"right", &"forward", &"backward")
    var direction = input_dir.rotated(-cam_pivot.rotation.y)
    var move_dir = Vector3(
        direction.x,
        0,
        direction.y
    )

    player.apply_central_force(move_dir * delta * player.ground_speed)
