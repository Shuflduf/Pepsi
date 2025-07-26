class_name Map
extends NavigationRegion3D

signal wave_complete

@export var enemies: EntityList
@export var props: EntityList
@export var smooth = false
@export var map_pillar: PackedScene

var wave_to_spawn: Wave
var enemies_spawned = 0

var current_config: MapConfig

func get_center_pos() -> float:
    var center_pos = (current_config.tile_size * current_config.map_size / 2.0) - current_config.tile_size / 2.0
    return center_pos

func _ready() -> void:
    create_from_config(MapConfig.new())


func create_from_config(config: MapConfig):
    current_config = config
    for c in %Parts.get_children():
        c.free()

    for x in config.map_size:
        var col = Node3D.new()
        %Parts.add_child(col)
        col.position.x = config.tile_size * x

        for y in config.map_size:
            var pillar: MapPillar = map_pillar.instantiate()
            col.add_child(pillar)
            pillar.set_size(config.tile_size)
            pillar.position.z = config.tile_size * y

    #config.height_scale
    var center_pos = get_center_pos()
    $Base.position = Vector3(center_pos, -500, center_pos)
    $Base.size.x = config.tile_size * config.map_size
    $Base.size.z = $Base.size.x

    reset_enemies()
    #var new_wave = Wave.new()
    #new_wave.resize(config.map_size)
    #set_wave(new_wave)

func reset_enemies():
    print("deleting")
    for enemy in %Enemies.get_children():
        enemy.queue_free()



func set_wave(wave: Wave):
    #reset_entites()
    for prop in get_tree().get_nodes_in_group(&"Prop"):
        prop.queue_free()

    wave_to_spawn = wave
    for x in wave.heights.size():
        var col = wave.heights[x]
        for y in col.size():
            var value = col[y]

            var pillar: AnimatableBody3D = %Parts.get_child(x).get_child(y)
            var prop = wave.props[x][y]
            if prop != -1:
                var new_prop = props.entities[prop].scene.instantiate()
                new_prop.position.y = 45.0
                pillar.add_child(new_prop)
                print(new_prop.global_position)

            var pillar_pos = (value * current_config.height_scale)

            if !smooth:
                pillar.position.y = pillar_pos
                %SpawnTimer.start(0.01)
            else:
                var tween = get_tree().create_tween() \
                    .set_ease(Tween.EASE_IN_OUT) \
                    .set_trans(Tween.TRANS_CUBIC)

                tween.tween_property(pillar, "position:y", pillar_pos, randf_range(0.7, 1.5))
                %SpawnTimer.start()

func spawn_enemy(enemy: int, spawn_pos: Vector3):
    #var enemy = wave.enemies[x][y]
    if enemy != -1:
        var enemy_node: Enemy = enemies.entities[enemy].scene.instantiate()
        %Enemies.add_child(enemy_node)
        enemy_node.map_config = current_config
        enemy_node.current_wave_heights = wave_to_spawn.heights
        enemy_node.global_position = spawn_pos
        enemy_node.died.connect(_on_enemy_died)

func spawn_all_enemies():
    reset_enemies()

    enemies_spawned = 0

    for x in wave_to_spawn.heights.size():
        var col = wave_to_spawn.heights[x]
        for y in col.size():
            var enemy_to_spawn = wave_to_spawn.enemies[x][y]
            if enemy_to_spawn != -1:
                enemies_spawned += 1
            var pillar: AnimatableBody3D = %Parts.get_child(x).get_child(y)
            if smooth:
                get_tree().create_timer(randf_range(0.0, 1.0)).timeout.connect(func():
                    spawn_enemy(enemy_to_spawn, pillar.global_position + Vector3(0, 45, 0))
                )
            else:
                spawn_enemy(enemy_to_spawn, pillar.global_position + Vector3(0, 45, 0))

func _on_spawn_timer_timeout() -> void:
    spawn_all_enemies()
    bake_navigation_mesh()
    show_wave_info()

func _on_enemy_died():
    # -1 because queuefree doesnt work fast enough
    var enemies_alive = %Enemies.get_child_count() - 1
    if enemies_alive <= 0:
        wave_complete.emit()


func _on_kill_barrier_body_entered(body: Node3D) -> void:
    if body is Enemy:
        body.die()
    elif body is PhysicsEntity and body.has_component("Player"):
        body.global_position = player_spawn_pos()

func show_wave_info():
    if !smooth:
        return
    %NameLabel.text = wave_to_spawn.name
    %EnemyLabel.text = "%d Enemies" % enemies_spawned
    %UIAnim.play(&"show")

func player_spawn_pos() -> Vector3:
    var center_pos = get_center_pos()
    return Vector3(
        center_pos,
        20.0,
        center_pos
    )
