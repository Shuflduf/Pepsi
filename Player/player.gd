class_name Player
extends PhysicsEntity

@export var mouse_sens: float = 0.01

var speed_factor = 1.0

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
        $Bottle.fizz += event.relative.length() / 10000
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

    var vel_length = linear_velocity.length()
    $Bottle.fizz += vel_length / 800
    speed_factor = clamp(speed_factor - (vel_length / 1000), 1.0, 10.0)
    update_speed_values()
    DebugDraw2D.set_text("speed", [speed_factor, ground_speed, max_air_speed])

func get_look_vec() -> Vector3:
    var look_dir = %Camera3D.global_rotation
    var look_vec = Vector3(
        -sin(look_dir.y),
        sin(look_dir.x),
        -cos(look_dir.y)
    ).normalized()
    return look_vec

func update_speed_values():
    ground_speed = remap(speed_factor, 1.0, 2.0, 4500.0, 6000.0)
    max_speed = remap(speed_factor, 1.0, 2.0, 8.5, 10.0)
    max_air_speed = remap(speed_factor, 1.0, 2.0, 6.5, 8.0)

func _on_bottle_swung(damage: int):
    for body in %MeleeHitbox.get_overlapping_bodies():
        #var body: Enemy = %MeleeHitbox.get_overlapping_bodies()[0]
        if body is not Enemy:
            continue

        var hit_dir = get_look_vec()
        hit_dir.y = clamp(hit_dir.y, 0.3, 1)
        var mult = 20
        body.apply_central_impulse(hit_dir * mult)
        #body.is_hit = true
        #body.health -= damage
        body.in_hitstun = true
        body.hit(damage)


func _on_bottle_shot(fizz: float, damage: int) -> void:
    if !is_on_floor():
        var fire_dir = get_look_vec()
        apply_central_force(-fire_dir * 4 * sqrt(fizz + 1))

    for body: Enemy in %RangedHitbox.get_overlapping_bodies():
        body.apply_central_force(get_look_vec() * 10)
        body.hit(damage)


func _on_bottle_bottle_spawned(bottle: RigidBody3D) -> void:
    bottle.linear_velocity = linear_velocity
    bottle.linear_velocity += get_look_vec() * 20
    bottle.init_velocity = bottle.linear_velocity.normalized()
    bottle.angular_velocity = get_look_vec().rotated(Vector3.UP, PI/2) * 30


func _on_bottle_drank(delta: float) -> void:
    speed_factor += delta
    update_speed_values()
