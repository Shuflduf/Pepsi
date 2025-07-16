class_name Player
extends PhysicsEntity

@export var mouse_sens: float = 0.01

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_pressed():
        if event.is_action_pressed(&"jump") and is_on_floor():
            apply_central_impulse(Vector3.UP * jump_height)
        if event.is_action_pressed(&"ui_cancel"):
            match Input.mouse_mode:
                Input.MOUSE_MODE_VISIBLE:
                    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
                Input.MOUSE_MODE_CAPTURED:
                    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        $CamPivot.rotate_y(-event.relative.x * mouse_sens)

        %Camera3D.rotate_x(-event.relative.y * mouse_sens)
        %Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-89), deg_to_rad(89))


func _physics_process(delta: float) -> void:
    var input_dir = Input.get_vector(&"left", &"right", &"forward", &"backward")
    var direction = input_dir.rotated(-$CamPivot.rotation.y)
    var move_dir = Vector3(
        direction.x,
        0,
        direction.y
    )

    apply_central_force(move_dir * delta * ground_speed)

func get_look_vec() -> Vector3:
    var look_dir = %Camera3D.global_rotation
    var look_vec = Vector3(
        -sin(look_dir.y),
        sin(look_dir.x),
        -cos(look_dir.y)
    ).normalized()
    return look_vec

func _on_bottle_swung():
    if %MeleeHitbox.has_overlapping_bodies():
        var body: Enemy = %MeleeHitbox.get_overlapping_bodies()[0]
        var hit_dir = get_look_vec()
        hit_dir.y = clamp(hit_dir.y, 0.3, 1)
        var mult = 20
        body.apply_central_impulse(hit_dir * mult)
        body.hit = true


func _on_bottle_fly(fizz: float) -> void:
    if !is_on_floor():
        var fire_dir = get_look_vec()
        apply_central_force(-fire_dir * 4 * (fizz + 1))


func _on_bottle_bottle_spawned(bottle: RigidBody3D) -> void:
    bottle.linear_velocity = linear_velocity
    bottle.linear_velocity += get_look_vec() * 20
    bottle.init_velocity = bottle.linear_velocity.normalized()
    bottle.angular_velocity = get_look_vec().rotated(Vector3.UP, PI/2) * 30
