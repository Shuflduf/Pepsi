extends RigidBody3D

@export var mouse_sens: float = 0.01

@export var walking_speed = 4500.0
@export var max_speed = 8.5
@export var max_air_speed = 6.5
@export var drag = 0.15

var pepsi_pos = Vector2.ZERO

enum PepsiState {
    Melee,
    Ranged
}

var is_pepsi_ready = false
var ammo = 100:
    set(value):
        %AnimHandler.value = value
    get():
        return %AnimHandler.value

var current_state = PepsiState.Ranged

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    %AnimHandler.play_anim(&"reload_catch")

func _process(delta: float) -> void:
    %AnimHandler.offset = lerp(%AnimHandler.offset, Vector2.ZERO, delta * 20)
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and is_pepsi_ready and current_state == PepsiState.Ranged:
        ammo -= delta * 50
        check_ammo()

func check_ammo():
    if ammo < 0:
        is_pepsi_ready = false
        %AnimHandler.play_anim(&"reload_throw")

func is_on_floor() -> bool:
    if test_move(transform, Vector3.DOWN*0.1 * get_physics_process_delta_time() ):
        return true
    else:
        return false

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_pressed():
        if event.is_action_pressed(&"switch"):
            switch_state()
        if event.is_action_pressed(&"jump") and is_on_floor():
            apply_central_impulse(Vector3.UP * 5)
        if event.is_action_pressed(&"ui_cancel"):
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

func switch_state():
    is_pepsi_ready = false
    print("switching")
    match current_state:
        PepsiState.Ranged:
            %AnimHandler.play_anim(&"switch_melee")
            #%PepsiAnim.play(&"switch_melee")
            current_state = PepsiState.Melee
        PepsiState.Melee:
            %AnimHandler.play_anim(&"switch_ranged")
            #%PepsiAnim.play(&"switch_ranged")
            current_state = PepsiState.Ranged

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        %AnimHandler.offset -= event.relative

        $CamPivot.rotate_y(-event.relative.x * mouse_sens)

        %Camera3D.rotate_x(-event.relative.y * mouse_sens)
        %Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-89), deg_to_rad(89))


func _on_anim_handler_animation_finished(anim_name: StringName) -> void:
    match anim_name:
        &"reload_catch":
            %AnimHandler.play_anim(&"ranged")
            is_pepsi_ready = true
        &"reload_throw":
            ammo = 100
            %AnimHandler.play_anim(&"reload_catch")
        &"switch_melee":
            is_pepsi_ready = true
            %AnimHandler.play_anim(&"melee")
        &"switch_ranged":
            is_pepsi_ready = true
            %AnimHandler.play_anim(&"ranged")

func _physics_process(delta: float) -> void:
    var input_dir = Input.get_vector(&"left", &"right", &"forward", &"backward")
    var direction = input_dir.rotated(-$CamPivot.rotation.y)
    var move_dir = Vector3(
        direction.x,
        0,
        direction.y
    )

    apply_central_force(move_dir * delta * walking_speed)

# stolen from egress which stole it from something else idk
func _integrate_forces(state):
    var xz_velocity = Vector2(state.linear_velocity.x, state.linear_velocity.z)

    # Apply drag if the rigid body is on the ground
    if is_on_floor():
        var drag_force = -drag * state.linear_velocity
        state.linear_velocity += drag_force

        # Max speed while on ground
        if xz_velocity.length() > max_speed:

            # Limit X and Z velocity
            xz_velocity = Vector2(state.linear_velocity.x, state.linear_velocity.z)
            var limitedVelXZ = xz_velocity.normalized() * max_speed
            state.linear_velocity.x = limitedVelXZ.x
            state.linear_velocity.z = limitedVelXZ.y
    else:

        # Max speed while in air
        if xz_velocity.length() > max_air_speed:

            # Limit X and Z velocity
            xz_velocity = Vector2(state.linear_velocity.x, state.linear_velocity.z)
            var limitedVelXZ = xz_velocity.normalized() * max_air_speed
            state.linear_velocity.x = limitedVelXZ.x
            state.linear_velocity.z = limitedVelXZ.y

    # Stop the character if speed is low enough
    if state.linear_velocity.length() < 0.1:
        state.linear_velocity = Vector3.ZERO
