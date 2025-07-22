extends BottleComponent

@export var hitbox: Area3D
@export var player_info: BottleComponent
@export var mode: BottleComponent
@export var fizz: BottleComponent
@export var visuals: BottleVisuals

func swing(damage: int):
    if mode.current_mode != mode.BottleMode.Melee:
        return
    if !mode.is_ready:
        return
#
    #%Swing.play()
    mode.is_ready = false
    visuals.play_anim(&"swing")
#
    #swung.emit(melee_damage)
    fizz.value += 0.2

    for body in hitbox.get_overlapping_bodies():
        if body is not Enemy:
            continue

        #%Hit.play(0.05)
        var hit_dir = player_info.get_look_vec()
        hit_dir.y = clamp(hit_dir.y, 0.3, 1)
        var mult = 20
        body.apply_central_impulse(hit_dir * mult)
        #body.is_hit = true
        #body.health -= damage
        body.in_hitstun = true
        body.hit(damage)


func _process(_delta: float) -> void:
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        swing(80)

func _on_anim_handler_animation_finished(anim_name: StringName) -> void:
    if anim_name == &"swing":
        mode.is_ready = true
        visuals.play_anim(&"melee")
