extends Enemy

@export var base_speed = 1000.0
@export var boosted_speed = 3000.0
@export var base_damage = 8
@export var boosted_damage = 12

var can_attack = true

func _physics_process(delta: float) -> void:
    if immobile:
        linear_velocity = Vector3.ZERO
        return

    if player and !in_hitstun:
        var dist = global_position.distance_to(player.global_position)

        var target = player.global_position
        var dir = global_position.direction_to(target)

        if dist < 2.0 and can_attack:

            max_air_speed *= 2
            #apply_central_impulse(dir * 0.01)
            linear_velocity = dir
            can_attack = false
            in_hitstun = true
            $HitstunTimer.start()
        else:
            target = player.global_position + Vector3(0.0, 1.0, 0.0)
            dir = global_position.direction_to(target)
            apply_central_force(dir * delta * ground_speed)

        var look_dir = atan2(dir.x, dir.z)
        $Visuals.rotation.y = lerp_angle($Visuals.rotation.y, look_dir, delta * 10)

    ground_speed = boosted_speed if is_boosted else base_speed


func hit(damage_amount: int):
    super(damage_amount)
    $HitstunTimer.start()


func _on_attack_cooldown_timeout() -> void:
    can_attack = true
    max_air_speed /= 2


func _on_body_entered(body: Node) -> void:
    if body is PhysicsEntity:
        damage(body, boosted_damage if is_boosted else base_damage)

func is_on_floor():
    return false
