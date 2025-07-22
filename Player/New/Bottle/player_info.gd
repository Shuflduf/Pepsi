extends BottleComponent

@export var camera: Camera3D

func get_look_vec() -> Vector3:
    var look_dir = camera.global_rotation
    var look_vec = Vector3(
        -sin(look_dir.y),
        sin(look_dir.x),
        -cos(look_dir.y)
    ).normalized()
    return look_vec
