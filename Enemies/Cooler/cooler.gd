extends Enemy

var connected_enemies: Dictionary[Enemy, GPUParticles3D] = {}

func _physics_process(delta: float) -> void:
    super(delta)
    var enemies = $DetectionArea.get_overlapping_bodies()

    for e in connected_enemies.keys():
        if e not in enemies:
            print("remove")
            connected_enemies[e].queue_free()
            connected_enemies.erase(e)

    for e: Enemy in enemies:
        if e == self:
            continue

        e.is_boosted = true
        e.boosted_timer.start()
        if e not in connected_enemies.keys():
            var new_particles = %TemplateParticles.duplicate()
            new_particles.emitting = true
            %TemplateParticles.get_parent().add_child(new_particles)
            connected_enemies[e] = new_particles
        var look_at_pos = e.global_position + Vector3(0, 1, 0)
        connected_enemies[e].look_at(look_at_pos)

    if player == null:
        return
    var look_vec = global_position.direction_to(player.global_position)
    var look_dir = atan2(look_vec.x, look_vec.z)
    $Visuals.rotation.y = lerp_angle($Visuals.rotation.y, look_dir, delta * 10)

    %DetectionShape.shape.radius = 15.0 if is_boosted else 10.0

func hit(damage_amount: int):
    super(damage_amount)
    var random_tile_pos = Vector2i(
        randi_range(0, map_config.map_size - 1),
        randi_range(0, map_config.map_size - 1)
    )
    var tile_height = current_wave_heights[random_tile_pos.x][random_tile_pos.y]
    var new_real_pos = Vector3(
        random_tile_pos.x * map_config.tile_size,
        tile_height * map_config.height_scale,
        random_tile_pos.y * map_config.tile_size,
    )
    global_position = new_real_pos
    # add like fx when tp, like a line connecting old pos to new pos
