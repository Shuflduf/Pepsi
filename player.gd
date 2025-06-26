extends RigidBody3D

@onready var ui: Control = $UI
@onready var pepsi_bar: TextureProgressBar = $UI/TextureProgressBar

@export var mouse_sens: float = 0.01

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
    $UI/AnimatedSprite2D.play(&"default")
    $UI/AnimatedSprite2D.animation_finished.connect(func():
        $UI/TextureProgressBar.show()
        $UI/AnimatedSprite2D.hide()
    )
    pepsi_bar.value -= delta * 10

func is_on_floor() -> bool:
    if test_move(transform, Vector3.DOWN*0.1 * get_physics_process_delta_time() ):
        return true
    else:
        return false

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_pressed():
        if event.is_action_pressed("jump") and is_on_floor():
            apply_central_impulse(Vector3.UP * 5)
        if event.is_action_pressed("ui_cancel"):
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        rotate_y(-event.relative.x * mouse_sens)

        $CamPivot.rotate_x(-event.relative.y * mouse_sens)
        $CamPivot.rotation.x = clamp($CamPivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))
