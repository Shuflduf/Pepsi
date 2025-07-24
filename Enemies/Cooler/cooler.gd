extends Enemy

func _physics_process(delta: float) -> void:
    super(delta)
    var enemies = $DetectionArea.get_overlapping_bodies()
    for e: Enemy in enemies:
        e.is_boosted = true
        e.boosted_timer.start()
        DebugDraw3D.draw_arrow(global_position, e.global_position, Color.GREEN, 0.5, true)

    if player == null:
        return
    var look_vec = global_position.direction_to(player.global_position)
    var look_dir = atan2(look_vec.x, look_vec.z)
    $Visuals.rotation.y = lerp_angle($Visuals.rotation.y, look_dir, delta * 10)
