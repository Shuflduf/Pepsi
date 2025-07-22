extends PlayerComponent

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_pressed():
        if event.is_action_pressed(&"jump") and player.is_on_floor():
            #$JumpParticles.restart()
            player.apply_central_impulse(Vector3.UP * player.jump_height)
            #%Jump.play()
