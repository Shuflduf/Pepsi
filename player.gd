extends RigidBody3D

@export var mouse_sens: float = 0.01
@export var jump_height = 5.0
@export var walking_speed = 4500.0
@export var max_speed = 8.5
@export var max_air_speed = 6.5
@export var drag = 0.15

var pepsi_pos = Vector2.ZERO

enum PepsiState {
    Melee,
    Ranged,
    Aiming,
}

var is_pepsi_ready = false
var ammo = 100:
    set(value):
        %AnimHandler.value = value
    get():
        return %AnimHandler.value

var current_state = PepsiState.Ranged
var vision_system: VisionSystem

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    %AnimHandler.play_anim(&"reload_catch")
    
    # Initialize vision system
    vision_system = VisionSystem.new()
    add_child(vision_system)
    vision_system.object_detected.connect(_on_object_detected)
    vision_system.object_lost.connect(_on_object_lost)

func _process(delta: float) -> void:
    %AnimHandler.offset = lerp(%AnimHandler.offset, Vector2.ZERO, delta * 20)
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and is_pepsi_ready and current_state == PepsiState.Ranged:
        ammo -= delta * 50
        check_ammo()

    if current_state == PepsiState.Aiming:
        ammo -= delta * 50
        check_ammo()

    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        swing()

    if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        aim()
    else:
        unaim()
    
    # Debug vision system
    if vision_system:
        _debug_vision_system()

func _debug_vision_system():
    if not vision_system:
        return
    
    var detected_objects = vision_system.get_detected_objects()
    DebugDraw2D.begin_text_group("vision_debug", 200, Color.CYAN, false)
    DebugDraw2D.set_text("=== VISION SYSTEM ===", "", 0)
    DebugDraw2D.set_text("Status", "Active", 1)
    DebugDraw2D.set_text("Objects Detected", str(detected_objects.size()), 2)
    DebugDraw2D.set_text("FOV Angle", str(vision_system.fov_angle) + "°", 3)
    DebugDraw2D.set_text("Max Range", str(vision_system.max_range) + "m", 4)
    DebugDraw2D.set_text("Press V", "Toggle visualization", 5)
    DebugDraw2D.set_text("", "", 6)
    
    for i in range(min(detected_objects.size(), 5)):  # Show max 5 objects
        var obj = detected_objects[i]
        if obj and is_instance_valid(obj):
            var distance = global_position.distance_to(obj.global_position)
            DebugDraw2D.set_text("• " + obj.name, 
                "%.1fm" % distance, 7 + i)
    
    DebugDraw2D.end_text_group()
    
    # Also show help text
    DebugDraw2D.begin_text_group("controls", 1000, Color.WHITE, false)
    DebugDraw2D.set_text("=== CONTROLS ===", "", 0)
    DebugDraw2D.set_text("WASD", "Move", 1)
    DebugDraw2D.set_text("Mouse", "Look around", 2)
    DebugDraw2D.set_text("Space", "Jump", 3)
    DebugDraw2D.set_text("V", "Toggle vision debug", 4)
    DebugDraw2D.set_text("E", "Switch weapon mode", 5)
    DebugDraw2D.set_text("Mouse L/R", "Attack/Aim", 6)
    DebugDraw2D.end_text_group()

func _on_object_detected(object: Node3D, distance: float):
    print("Vision: Detected ", object.name, " at distance ", distance)

func _on_object_lost(object: Node3D):
    print("Vision: Lost ", object.name)

func toggle_vision_debug():
    if vision_system:
        vision_system.show_debug_visualization = !vision_system.show_debug_visualization
        print("Vision debug visualization: ", "ON" if vision_system.show_debug_visualization else "OFF")

func check_ammo():
    if ammo < 0:
        unaim()
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
            apply_central_impulse(Vector3.UP * jump_height)
        if event.is_action_pressed(&"ui_cancel"):
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
        if event.keycode == KEY_V:
            toggle_vision_debug()

func switch_state():
    if !is_pepsi_ready:
        return
    is_pepsi_ready = false
    match current_state:
        PepsiState.Ranged:
            %AnimHandler.play_anim(&"switch_melee")
            current_state = PepsiState.Melee
        PepsiState.Melee:
            %AnimHandler.play_anim(&"switch_ranged")
            current_state = PepsiState.Ranged
        PepsiState.Aiming:
            is_pepsi_ready = true

func aim():
    if current_state != PepsiState.Ranged:
        return
    if !is_pepsi_ready:
        return

    current_state = PepsiState.Aiming
    is_pepsi_ready = false
    %AnimHandler.play_anim(&"aim")

func unaim():
    if current_state != PepsiState.Aiming:
        return
    if !is_pepsi_ready:
        return

    %Particles.emitting = false
    current_state = PepsiState.Ranged
    is_pepsi_ready = false
    %AnimHandler.play_anim(&"unaim")

func swing():
    if current_state != PepsiState.Melee:
        return
    if !is_pepsi_ready:
        return

    is_pepsi_ready = false
    %AnimHandler.play_anim(&"swing")

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
        &"swing":
            is_pepsi_ready = true
            %AnimHandler.play_anim(&"melee")
        &"aim":
            is_pepsi_ready = true
            %AnimHandler.play_anim(&"firing")
            %Particles.emitting = true
        &"unaim":
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
