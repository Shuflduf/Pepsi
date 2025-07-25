extends Node3D

var is_moving = false

func _process(_delta: float) -> void:
    is_moving = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            %PreviewCam.position.z += event.factor
        elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
            %PreviewCam.position.z -= event.factor
        %PreviewCam.position.z = clampf(%PreviewCam.position.z, 0.0, 300.0)

    if event is InputEventMouseMotion and is_moving:
        $Pivot.rotate_x(-event.relative.y / 100.0)
        $Pivot.rotation.x = clamp($Pivot.rotation.x, -PI / 2.0, 0)
        rotate_y(-event.relative.x / 100.0)
