extends Node3D

@export var enemies: EntityList
@export var waves: Array[BasicWave]
@export var start_area_scene: PackedScene

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
        "Coolers boost all other enemies",
        "In most cases, everything is a lot faster"
    ],
]

var current_wave = 3
var fighting_enemies = false

func spawn_next_wave():
    print("spawning")
    for enemy in waves[current_wave].list:
        var new_enemy: Enemy = enemies.entities[enemy.enemy_id].scene.instantiate()
        new_enemy.position = enemy.pos
        if enemy.enemy_id == 3:
             print("yea thats a cooler")
             new_enemy.on_hit.connect(_on_cooler_hit.bind(new_enemy))
        $Enemies.add_child(new_enemy)
    fighting_enemies = true

#func spawn_enemy(index: int):
    #var new_enemy
    #
    #$Enemies.add_child(new_enemy)

func _on_cooler_hit(cooler: Enemy):
    var real_pos = Vector3(
        4.0 * randi_range(0, 4),
        0.0,
        4.0 * randi_range(0, 4)
    )
    real_pos -= Vector3(8, 0, 8)
    cooler.global_position = real_pos


func finish_wave():
    fighting_enemies = false
    current_wave += 1
    prints(current_wave, waves.size())
    if current_wave >= waves.size():
        print("AAAAA")
        $Anim.play(&"finish")
    else:
        $StartTimer.start()


func _on_start_timer_timeout() -> void:
    #spawn_enemy(0)
    $MainLabel.text = messages[current_wave][0]
    $SubLabel.text = messages[current_wave][1]
    $Anim.play(&"show")


func _on_kill_barrier_body_entered(body: Node3D) -> void:
    if body is Enemy:
        body.die()
    elif body.is_in_group(&"Player"):
        body.global_position = Vector3.UP * 20.0
        var health = body.get_component(^"Health")
        if health:
            health.hit(health.health / 2.0)


func _on_exit_trigger_body_entered(_body: Node3D) -> void:
    $ExitOverlay.show()
    var transition = Transition
    transition.transition_data = { "from": "enemy_tutorial" }
    transition.set_color(Color.WHITE)
    transition.transition_to(start_area_scene)
    transition.transition_started.connect(queue_free)


func _on_check_timer_timeout() -> void:
    if $Enemies.get_child_count() <= 0 and fighting_enemies:
        finish_wave()
