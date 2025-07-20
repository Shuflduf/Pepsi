extends Node3D

# mesh: #524e15
# light: #baa625

func _physics_process(delta: float) -> void:
    $Light.light_energy = 0.2 + randf_range(-0.01, 0.01)

func turn_purple():
    $Light.hide()
    $Cylinder_005.hide()
    await get_tree().create_timer(3.0).timeout
    $Light.show()
    $Cylinder_005.show()
    $Light.light_color = Color("372538")
    var light_mesh: ArrayMesh = $Cylinder_005.mesh
    var light_material: StandardMaterial3D  = light_mesh.surface_get_material(0)
    light_material.emission = Color("3b163d")
