@tool
extends Node3D

@export var destination: Node3D
@export var portal_cam: Camera3D

func _process(delta: float) -> void:
    var current_cam: Camera3D
    if Engine.is_editor_hint():
        current_cam = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
    else:
        current_cam = get_viewport().get_camera_3d()

    var rel_transform = global_transform.affine_inverse() * current_cam.global_transform

    portal_cam.global_transform = destination.global_transform * rel_transform

    print(rel_transform)
