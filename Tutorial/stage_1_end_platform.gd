extends CSGBox3D


func _on_area_3d_body_entered(body: Node3D) -> void:
    $Portal.open()


func _on_area_3d_body_exited(body: Node3D) -> void:
    $Portal.close()
