extends Enemy



func _on_body_entered(body: Node) -> void:
    if body is PhysicsEntity:
        damage(body, 5)
