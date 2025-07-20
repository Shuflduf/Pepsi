extends RigidBody3D

var touched_ground = false

func _on_body_entered(body: Node) -> void:
    if body is Enemy:
        return
    if touched_ground:
        return

    touched_ground = true
    $FallbackTimer.start()
    if body is Player:
        body.apply_central_impulse(Vector3.UP * 4)
        body.hit(3)


func _on_fallback_timer_timeout() -> void:
    queue_free()


func _on_despawn_timer_timeout() -> void:
    queue_free()
