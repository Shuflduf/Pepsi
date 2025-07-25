extends Enemy

func _physics_process(delta: float) -> void:
    super(delta)
    var enemies = $DetectionArea.get_overlapping_bodies()
    $ConnectionParticles/Template.emitting = false
    for e: Enemy in enemies:
        if e == self:
            continue
        e.is_boosted = true
        e.boosted_timer.start()
        DebugDraw3D.draw_arrow(global_position, e.global_position, Color.GREEN, 0.5, true)
        $ConnectionParticles/Template.emitting = true
        var look_at_pos = e.global_position + Vector3(0, 1, 0)
        $ConnectionParticles/Template.look_at(look_at_pos)

    if player == null:
        return
    var look_vec = global_position.direction_to(player.global_position)
    var look_dir = atan2(look_vec.x, look_vec.z)
    $Visuals.rotation.y = lerp_angle($Visuals.rotation.y, look_dir, delta * 10)

func hit(damage_amount: int):
    super(damage_amount)
    var random_tile_pos = Vector2i(
        randi_range(0, map_size - 1),
        randi_range(0, map_size - 1)
    )
    var tile_height = current_wave_heights[random_tile_pos.x][random_tile_pos.y]
    var new_real_pos = Vector3(
        (random_tile_pos.x - 3) * map_tile_size + map_tile_size / 2.0,
        tile_height * map_resolution,
        (random_tile_pos.y - 3) * map_tile_size + map_tile_size / 2.0,
    )
    global_position = new_real_pos
    # add like fx when tp, like a line connecting old pos to new pos
