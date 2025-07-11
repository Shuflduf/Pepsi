class_name PhysicsEntity
extends RigidBody3D

@export var ground_speed = 4500.0
@export var max_speed = 8.5
@export var max_air_speed = 6.5
@export var drag = 0.15

func is_on_floor() -> bool:
    if test_move(transform, Vector3.DOWN*0.1 * get_physics_process_delta_time() ):
        return true
    else:
        return false

# stolen from egress which stole it from something else idk
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
