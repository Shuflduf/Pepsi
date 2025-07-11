class_name Enemy
extends RigidBody3D

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@export var walking_speed = 4500.0
@export var max_speed = 8.5
@export var max_air_speed = 6.5
@export var drag = 0.15

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
        #if dir.y > -0.9 and is_on_floor():
            #print("JUMP")
            #apply_central_impulse(Vector3.UP * 6)

        dir.y = 0
        apply_central_force(dir * delta * walking_speed)

        #var look_point: Vector3 = $Visuals.global_position + dir
        #look_point = look_point.rotated(Vector3.UP, PI)
        #$Visuals.look_at(look_point)
        var look_dir = atan2(dir.x, dir.z)
        $Visuals.rotation.y = lerp_angle($Visuals.rotation.y, look_dir, delta * 10)



func is_on_floor() -> bool:
    if test_move(transform, Vector3.DOWN*0.1 * get_physics_process_delta_time() ):
        return true
    else:
        return false

func _integrate_forces(state):
    var xz_velocity = Vector2(state.linear_velocity.x, state.linear_velocity.z)

    # Apply drag if the rigid body is on the ground
    if is_on_floor():
        var drag_force = -drag * state.linear_velocity
        state.linear_velocity += drag_force

        # Max speed while on ground
        if xz_velocity.length() > max_speed:

            # Limit X and Z velocity
            xz_velocity = Vector2(state.linear_velocity.x, state.linear_velocity.z)
            var limitedVelXZ = xz_velocity.normalized() * max_speed
            state.linear_velocity.x = limitedVelXZ.x
            state.linear_velocity.z = limitedVelXZ.y
    else:

        # Max speed while in air
        if xz_velocity.length() > max_air_speed:

            # Limit X and Z velocity
            xz_velocity = Vector2(state.linear_velocity.x, state.linear_velocity.z)
            var limitedVelXZ = xz_velocity.normalized() * max_air_speed
            state.linear_velocity.x = limitedVelXZ.x
            state.linear_velocity.z = limitedVelXZ.y

    # Stop the character if speed is low enough
    if state.linear_velocity.length() < 0.1:
        state.linear_velocity = Vector3.ZERO
