class_name DamageIndicator
extends Label3D

@export var lifetime = 1.0
@export var damage_colors: Array[Color]

var is_rainbow = false

func set_damage(damage: int):
    text = str(damage)
    font_size += damage * 32
    if damage < damage_colors.size() - 1:
        modulate = damage_colors[damage]
    else:
        is_rainbow = true

func _ready() -> void:
    scale = Vector3.ZERO
    var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(self, ^"scale", Vector3.ONE, 1.0)
    tween \
        .parallel() \
        .tween_property(self, ^"position:y", position.y + 5, 2.0) \
        .set_ease(Tween.EASE_OUT)
    tween \
        .tween_property(self, ^"position:y", position.y + 10, 2.0) \
        .set_ease(Tween.EASE_IN)
    tween.parallel().tween_property(self, ^"scale", Vector3.ZERO, 1.0)
    tween.tween_callback(queue_free)

func _process(delta: float) -> void:
    if is_rainbow:
        modulate.s = 1
        modulate.h += delta
