class_name Health
extends Node

@export var hit_cooldown: Timer
@export var health_bar: Range

var can_be_hit = true
var health = 100

func _ready() -> void:
    hit_cooldown.timeout.connect(_on_cooldown_timeout)

func _on_cooldown_timeout():
    can_be_hit = true

func hit(damage: int):
    if !can_be_hit:
        return
    health -= damage
    hit_cooldown.start()
    can_be_hit = false
    print(damage)
    health_bar.value = health
    #show_damage_label(damage)
