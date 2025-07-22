extends PlayerComponent

signal looked_around(amount: float)

@export var cam_pivot: Node3D
@export var camera: Camera3D
@export var mouse_sens = 0.004

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        looked_around.emit(event.relative.length())
        #$Bottle.fizz += event.relative.length() / 10000
        cam_pivot.rotate_y(-event.relative.x * mouse_sens)

        camera.rotate_x(-event.relative.y * mouse_sens)
        camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action_pressed(&"ui_cancel"):
        match Input.mouse_mode:
            Input.MOUSE_MODE_VISIBLE:
                Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            Input.MOUSE_MODE_CAPTURED:
                Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
