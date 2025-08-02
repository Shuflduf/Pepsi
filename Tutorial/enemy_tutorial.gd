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
        "This game revolves around beating\nhordes of enemies in Waves",
        "The most basic enemy is the Toilet"
    ],
]

var current_wave = 3

func empty_map_config() -> MapConfig:
    var conf = MapConfig.new()
    conf.map_size = 5
    conf.tile_size = 4
    return conf

func spawn_next_wave():
    print("spawning")
    for enemy in waves[current_wave].list:
        var new_enemy: Enemy = enemies.entities[enemy.enemy_id].scene.instantiate()
        new_enemy.position = enemy.pos
        new_enemy.died.connect(_on_enemy_died)
        new_enemy.map_config = empty_map_config()
        new_enemy.current_wave_heights = Wave.empty_2d_arr(5, 0)
        $Enemies.add_child(new_enemy)

#func spawn_enemy(index: int):
    #var new_enemy
    #
    #$Enemies.add_child(new_enemy)

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
