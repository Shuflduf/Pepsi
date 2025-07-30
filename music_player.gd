extends AudioStreamPlayer

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.is_pressed():
        if event.keycode == KEY_F2:
            AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0))
