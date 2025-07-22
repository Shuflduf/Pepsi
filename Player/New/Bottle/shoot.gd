extends BottleComponent

@export var mode: BottleComponent
@export var drinkable: BottleComponent
@export var visuals: BottleVisuals

func _process(delta: float) -> void:
    if mode.current_mode == mode.BottleMode.Firing and mode.is_ready:
        #if !%Pour.playing:
            #%Pour.play()

        drinkable.ammo -= delta * 50
        drinkable.check_ammo()
        #fizz -= delta / 3
        #shot.emit(fizz, ranged_damage)
    #else:
        #%Pour.stop()

    if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        aim()
    else:
        unaim()

func aim():
    if mode.current_mode != mode.BottleMode.Ranged:
        return
    if !mode.is_ready:
        return

    mode.current_mode = mode.BottleMode.Firing
    mode.is_ready = false
    visuals.play_anim(&"aim")

func unaim():
    if mode.current_mode != mode.BottleMode.Firing:
        return
    if !mode.is_ready:
        return

    #%Particles.emitting = false
    mode.current_mode = mode.BottleMode.Ranged
    mode.is_ready = false
    visuals.play_anim(&"unaim")

func _ready() -> void:
    visuals.animation_finished.connect(_on_visuals_animation_finished)

func _on_visuals_animation_finished(anim_name: StringName) -> void:
    mode.is_ready = true
    match anim_name:
        &"aim":
            visuals.play_anim(&"firing")
            #%Particles.emitting = true
        &"unaim":
            visuals.play_anim(&"ranged")
            #drinkable.check_ammo()
