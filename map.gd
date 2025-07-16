class_name Map
extends NavigationRegion3D

@export var enemies: AllEnemyData
@export var smooth = false

const OFFSET = -10
const MULT = 2

var wave_to_spawn: Wave

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

                tween.tween_property(pillar, "position:y", pillar_pos, 1)
                %SpawnTimer.start()




func spawn_enemy(enemy: int, pillar_pos: Vector3):
    #var enemy = wave.enemies[x][y]
    if enemy != -1:
        var enemy_node: Enemy = enemies.enemies[enemy].scene.instantiate()
        %Enemies.add_child(enemy_node)
        enemy_node.global_position = pillar_pos
        enemy_node.global_position.y += 10

func spawn_all_enemies():
    for enemy in %Enemies.get_children():
        enemy.queue_free()

    for x in wave_to_spawn.heights.size():
        var col = wave_to_spawn.heights[x]
        for y in col.size():
            var pillar: AnimatableBody3D = %Parts.get_child(x).get_child(y)
            spawn_enemy(wave_to_spawn.enemies[x][y], pillar.global_position)


func _on_spawn_timer_timeout() -> void:
    spawn_all_enemies()
    bake_navigation_mesh()
