extends PlayerComponent

signal pressed(interacted: CollisionObject3D)

@export var raycast: RayCast3D
@export var crosshair: ColorRect
@export var interacting_color: Color

func _input(event: InputEvent) -> void:
    if raycast.is_colliding():
        crosshair.color = interacting_color
        if event is InputEventMouseButton && event.is_pressed():
            if event.button_index == MOUSE_BUTTON_LEFT:
                var interacted = raycast.get_collider()
                pressed.emit(interacted)
    else:
        crosshair.color = Color.WHITE
                #if interacted is Area3D:
                    #pressed.emit(interacted)
                #elif interacted is BottleProp:
                    #interacted.use()
                    #game_started.emit()
