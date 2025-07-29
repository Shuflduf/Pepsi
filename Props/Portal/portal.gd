@tool
extends Node3D

@export var destination: Node3D
@export var portal_cam: Camera3D

func _process(_delta: float) -> void:
    var current_cam: Camera3D
    var viewport_size: Vector2i

    if Engine.is_editor_hint():
        var viewport = EditorInterface.get_editor_viewport_3d(0)
        current_cam = viewport.get_camera_3d()
        viewport_size = viewport.size
    else:
        current_cam = get_viewport().get_camera_3d()
        viewport_size = get_viewport().size

    $SubViewport.size = viewport_size / 2.0

    var m = destination.global_transform * $Mesh.global_transform.inverse() * current_cam.global_transform
    portal_cam.global_transform = m

func open():
    %Anim.play(&"open")

func close():
    %Anim.play_backwards(&"open")


func _on_player_area_body_entered(body: PhysicsEntity) -> void:
    #if body.linear_velocity
    var flat_vel = Vector2(
        body.linear_velocity.x,
        body.linear_velocity.z
    ).normalized()
    var portal_face_dir = Vector2(
        sin(global_rotation.y),
        cos(global_rotation.y)
    )
    var dot_res = flat_vel.dot(-portal_face_dir)

    var pivot: Node3D = body.find_child("CamPivot")
    var cam: Camera3D = pivot.find_child("Camera3D")

    #var cam_look_dir = Vector2(
        #sin(cam.global_rotation.y),
        #cos(cam.global_rotation.y)
    #)

    if dot_res > 0.7:
        body.global_position = destination.global_position

        pivot.global_rotation.y = portal_cam.global_rotation.y
        cam.global_rotation.x = portal_cam.global_rotation.x

        #pivot.global_rotation.y += destination.global_rotation.y
        #cam.global_rotation.x = destination.global_rotation.x
        #body.global_rotation =
