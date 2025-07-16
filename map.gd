class_name Map
extends NavigationRegion3D

@export var enemies: AllEnemyData

const OFFSET = -10
const MULT = 2

func set_wave(wave: Wave):
    for enemy in %Enemies.get_children():
        enemy.queue_free()

    for x in wave.heights.size():
        var col = wave.heights[x]
        for y in col.size():
            var value = col[y]

            var pillar: CSGBox3D = %Parts.get_child(x).get_child(y)
            var pillar_pos = (value * MULT) + OFFSET
            pillar.position.y = pillar_pos

            var enemy = wave.enemies[x][y]
            if enemy != -1:
                var enemy_node: Enemy = enemies.enemies[enemy].scene.instantiate()
                %Enemies.add_child(enemy_node)
                enemy_node.global_position = pillar.global_position
                enemy_node.global_position.y += 10
                prints("spawned", enemy_node, enemy, enemy_node.global_position)

func get_wave() -> Wave:
    var new_wave = Wave.new()
    for x in %Parts.get_child_count():
        var col = %Parts.get_child(x)
        for y in col.get_child_count():
            var part = col.get_child(y)
            new_wave.heights[x][y] = (part.position.y - OFFSET) / MULT

    return new_wave
