extends BottleComponent

@export var visuals: BottleVisuals

enum BottleMode {
    Melee,
    Ranged,
    Firing,
}
var current_mode := BottleMode.Ranged
var is_ready = false
var can_switch = true

func switch():
    if not is_ready:
        return
    if not can_switch:
        return
    #throw_strength = 0.0
    #visuals.update_throw_strength(0.0)
    is_ready = false
    match current_mode:
        BottleMode.Ranged:
            visuals.play_anim(&"switch_melee")
            current_mode = BottleMode.Melee
        BottleMode.Melee:
            visuals.play_anim(&"switch_ranged")
            current_mode = BottleMode.Ranged
        BottleMode.Firing:
            is_ready = true

func _ready() -> void:
    visuals.animation_finished.connect(_on_visuals_animation_finished)

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action_pressed(&"switch"):
        switch()

func _on_visuals_animation_finished(anim_name: StringName) -> void:
    is_ready = true
    match anim_name:
        &"switch_melee":
            visuals.play_anim(&"melee")
        &"switch_ranged":
            visuals.play_anim(&"ranged")
