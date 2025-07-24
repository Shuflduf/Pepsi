class_name Map
extends NavigationRegion3D

signal wave_complete

@export var enemies: AllEnemyData
@export var smooth = false

const OFFSET = -10
const MULT = 2

var wave_to_spawn: Wave
var enemies_spawned = 0

func set_wave(wave: Wave):
    for enemy in %Enemies.get_children():
        enemy.queue_free()

    wave_to_spawn = wave
    for x in wave.heights.size():
        var col = wave.heights[x]
        for y in col.size():
            var value = col[y]

            var pillar: AnimatableBody3D = %Parts.get_child(x).get_child(y)
            var pillar_pos = (value * MULT) + OFFSET

            if !smooth:
                pillar.position.y = pillar_pos
                %SpawnTimer.start(0.01)
            else:
                var tween = get_tree().create_tween() \
                    .set_ease(Tween.EASE_IN_OUT) \
                    .set_trans(Tween.TRANS_CUBIC)

                tween.tween_property(pillar, "position:y", pillar_pos, randf_range(0.7, 1.5))
                %SpawnTimer.start()

func spawn_enemy(enemy: int, pillar_pos: Vector3):
    #var enemy = wave.enemies[x][y]
    if enemy != -1:
        var enemy_node: Enemy = enemies.enemies[enemy].scene.instantiate()
        %Enemies.add_child(enemy_node)
        enemy_node.global_position = pillar_pos
        enemy_node.global_position.y += 10
        enemy_node.died.connect(_on_enemy_died)

func spawn_all_enemies():
    for enemy in %Enemies.get_children():
        enemy.queue_free()

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
                    spawn_enemy(enemy_to_spawn, pillar.global_position)
                )
            else:
                spawn_enemy(enemy_to_spawn, pillar.global_position)

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
    elif body is Player:
        body.global_position = Vector3.UP * 20

func show_wave_info():
    if !smooth:
        return
    %NameLabel.text = wave_to_spawn.name
    %EnemyLabel.text = "%d Enemies" % enemies_spawned
    %UIAnim.play(&"show")
