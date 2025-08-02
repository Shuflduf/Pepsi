extends Node3D

@export var enemies: EntityList
@export var waves: Array[BasicWave]

var messages = [
    [
        "This game revolves around beating hordes of enemies in Waves",
        "The most basic enemy is the Toilet"
    ],
    [
        "Fridges launch projectiles in your direction of movement",
        "It can be countered by moving better"
    ],
    [
        "Microwaves are little annoying bugs that fly around and ruin you day",
        "(Drinking restores health)"
    ],
    [
        "todo",
        "todo"
    ],
]

var current_wave = 3

func spawn_next_wave():
    print("spawning")
    for enemy in waves[current_wave].list:
        var new_enemy: Enemy = enemies.entities[enemy.enemy_id].scene.instantiate()
        new_enemy.position = enemy.pos
        new_enemy.died.connect(_on_enemy_died)
        if enemy.enemy_id == 3:
             print("yea thats a cooler")
             new_enemy.on_hit.connect(_on_cooler_hit.bind(new_enemy))
        $Enemies.add_child(new_enemy)

#func spawn_enemy(index: int):
    #var new_enemy
    #
    #$Enemies.add_child(new_enemy)

func _on_cooler_hit(cooler: Enemy):
    print("AAAAAAAAAAAAA")
    #cooler.global_position.y += 10.0
    var real_pos = Vector3(
        4.0 * randi_range(0, 4),
        0.0,
        4.0 * randi_range(0, 4)
    )
    real_pos -= Vector3(8, 0, 8)
    cooler.global_position = real_pos

func _on_enemy_died():
    print($Enemies.get_child_count())
    if $Enemies.get_child_count() <= 1:
        $StartTimer.start()
        print("next wave")
        current_wave += 1


func _on_start_timer_timeout() -> void:
    #spawn_enemy(0)
    $MainLabel.text = messages[current_wave][0]
    $SubLabel.text = messages[current_wave][1]
    $Anim.play(&"show")
