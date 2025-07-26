extends BottleComponent

@export var player: PhysicsEntity
@export var player_info: BottleComponent
@export var mode: BottleComponent
@export var drinkable: BottleComponent
@export var visuals: BottleVisuals
@export var fizz: BottleComponent
@export var throw: BottleComponent
@export var hitbox: Area3D
@export var shoot_particles: GPUParticles3D
@export var shoot_sfx: AudioStreamPlayer3D

func _physics_process(delta: float) -> void:
    if mode.current_mode == mode.BottleMode.Firing and mode.is_ready:
        if !shoot_sfx.playing:
            shoot_sfx.play()

        drinkable.ammo -= delta * 50
        drinkable.check_ammo()
        fizz.value -= delta
        shoot(1)
        #shot.emit(fizz, ranged_damage)
    else:
        shoot_sfx.stop()

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

    shoot_particles.emitting = false
    mode.current_mode = mode.BottleMode.Ranged
    mode.is_ready = false
    visuals.play_anim(&"unaim")

func _ready() -> void:
    visuals.animation_finished.connect(_on_visuals_animation_finished)
    fizz.fizz_changed.connect(_on_fizz_changed)
    throw.threw.connect(_on_threw)

func _on_visuals_animation_finished(anim_name: StringName) -> void:
    mode.is_ready = true
    match anim_name:
        &"aim":
            visuals.play_anim(&"firing")
            shoot_particles.emitting = true
        &"unaim":
            visuals.play_anim(&"ranged")
            #drinkable.check_ammo()

func _on_fizz_changed(new_fizz: float):
    var lifetime = clampf(new_fizz / 2, 0.2, 1.0)
    shoot_particles.lifetime = lifetime
    shoot_particles.process_material.spread = remap(lifetime, 0.2, 1.0, 5.0, 1.0)
    var box_size = remap(lifetime, 0.2, 1.0, 2.0, 0.5)
    var box_length = remap(lifetime, 0.2, 1.0, 10.0, 40.0)
    var hitbox_box = hitbox.get_child(0)
    var hitbox_shape: BoxShape3D = hitbox_box.shape
    hitbox_shape.size = Vector3(
        box_size,
        box_size,
        box_length,
    )
    hitbox_box.position.z = -box_length / 2

func _on_threw():
    shoot_particles.emitting = false

func shoot(damage: int) -> void:
    var look_vec = player_info.get_look_vec()
    if !player.is_on_floor():
        var force = -look_vec * 10 * sqrt(fizz.value + 1)
        player.apply_central_force(force)

    for body: Enemy in hitbox.get_overlapping_bodies():
        body.apply_central_force(look_vec * 10)
        body.hit(damage)
        body.hit_immunity()
