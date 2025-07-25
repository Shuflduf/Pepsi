class_name MapPillar
extends AnimatableBody3D

func set_size(size: int):
    var shape: BoxShape3D = $CollisionShape3D.shape
    shape.x = size
    shape.z = size
    var mesh: BoxMesh = $MeshInstance3D.mesh
    mesh.size.x = size
    mesh.size.z = size
