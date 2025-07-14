class_name Enemy
extends PhysicsEntity

@onready var agent: NavigationAgent3D = $NavigationAgent3D

var hit = false
var hit_cooldown = 0.0

func _physics_process(delta: float) -> void:
    hit_cooldown += delta
    if is_on_floor() and hit_cooldown > 0.1:
        hit = false
        hit_cooldown = 0.0

    var player: RigidBody3D = get_tree().get_first_node_in_group(&"Player")
    if player and !hit:
        agent.target_position = player.global_position
        var cur_pos = global_position
        var next_path_pos = agent.get_next_path_position()
        var dir = cur_pos.direction_to(next_path_pos)
        if dir.y > -0.9 and is_on_floor():
            print("JUMP")
            apply_central_impulse(Vector3.UP * 12)
        dir = Vector3(dir.x, 0.0, dir.z).normalized()


        #dir.y = 0
        apply_central_force(dir * delta * ground_speed)

        var look_dir = atan2(dir.x, dir.z)
        $Visuals.rotation.y = lerp_angle($Visuals.rotation.y, look_dir, delta * 10)
