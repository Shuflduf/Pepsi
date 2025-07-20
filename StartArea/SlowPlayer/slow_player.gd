extends PhysicsEntity

signal pressed(area: Area3D)
signal game_started
signal transition_started

@export var mouse_sens: float = 0.004
@onready var camera: Camera3D = %Camera3D

var selecting = false
var fading_away = false
var transitioning = false

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_pressed():
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

    elif event is InputEventMouseButton && event.is_pressed():
        if event.button_index == MOUSE_BUTTON_LEFT:
            if %Raycast.is_colliding():
                var interacted = %Raycast.get_collider()
                if interacted is Area3D:
                    pressed.emit(interacted)
                elif interacted is BottleProp:
                    interacted.use()
                    game_started.emit()

func _physics_process(delta: float) -> void:
    var input_dir = Input.get_vector(&"left", &"right", &"forward", &"backward")
    var direction = input_dir.rotated(-$CamPivot.global_rotation.y)
    var move_dir = Vector3(
        direction.x,
        0,
        direction.y
    )

    apply_central_force(move_dir * delta * ground_speed)

    selecting = %Raycast.is_colliding()
    if selecting:
        %Crosshair.color = Color.AQUAMARINE
    else:
        %Crosshair.color = Color.WHITE

    DebugDraw2D.set_text("test", selecting)


    if fading_away:
        %Fade.value += delta * 30
        if %Fade.value >= 100:
            if !transitioning:
                transitioning = true
                transition_started.emit()

func fade_away():
    fading_away = true
