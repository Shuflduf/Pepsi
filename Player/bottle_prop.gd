extends RigidBody3D

var init_velocity: Vector3


func _on_body_entered(body: Node) -> void:
    if body is Enemy:
        var hit_vec = init_velocity
        #DebugDraw3D.draw_arrow_ray(body.global_position, hit_vec, hit_vec.length() * 10, Color.YELLOW, 1)
        #body.apply_central_impulse(hit_vec)
        #body.hit = true

        hit_vec.y = clamp(hit_vec.y, 0.3, 1)
        var mult = 20
        body.apply_central_impulse(hit_vec * mult)
        body.hit = true
