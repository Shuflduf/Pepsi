extends Node3D

func _physics_process(delta: float) -> void:
    $Light.light_energy = 0.2 + randf_range(-0.01, 0.01)
