class_name Health
extends Node

@export var hit_cooldown: Timer
@export var health_bar: Range
@export var damage_label: Label

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
    show_damage_label(damage)

func show_damage_label(damage: int):
    var new_label = damage_label.duplicate()
    damage_label.get_parent().add_child(new_label)
    new_label.position.y = 20.0
    new_label.text = "-%d" % damage
    new_label.show()

    var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(new_label, ^"position:y", -20.0, 1.0).set_ease(Tween.EASE_OUT)
    tween.tween_callback(new_label.queue_free)
