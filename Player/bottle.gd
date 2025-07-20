extends Node

@onready var visuals: BottleVisuals = %Visuals
@export var bottle_prop: PackedScene
@export var melee_damage = 3
@export var throw_damage = 2
@export var ranged_damage = 1
@export var discard_damage = 4

signal swung(damage: int)
signal shot(fizz: float, damage: int)
signal bottle_spawned(bottle: RigidBody3D)
signal drank(delta: float)

var pepsi_pos = Vector2.ZERO

enum PepsiState {
    Melee,
    Ranged,
    Firing,
}

var is_pepsi_ready = false
var ammo = 100.0:
    set(value):
        ammo = value
        visuals.value = value
var fizz = 0.0:
    set(value):
        fizz = value
        visuals.fizz = value
        fizz_set()

var current_state = PepsiState.Ranged
var speed_scale = 1.0

func _ready() -> void:
    visuals.play_anim(&"reload_catch")

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        visuals.offset -= event.relative


func _process(delta: float) -> void:
    visuals.offset = lerp(visuals.offset, Vector2.ZERO, delta * 20)
    #if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and is_pepsi_ready and current_state == PepsiState.Ranged:


    if current_state == PepsiState.Firing and is_pepsi_ready:
        ammo -= delta * 50
        check_ammo()

        fizz -= delta / 3

        shot.emit(fizz, ranged_damage)

    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        swing()
        drink(delta)

    if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        aim()
        if current_state == PepsiState.Melee:
            throw()
    else:
        unaim()

    if Input.is_action_pressed(&"debug_throw"):
        throw(false, true)


func check_ammo():
    DebugDraw2D.set_text("ammo", [ammo, current_state, is_pepsi_ready])
    if ammo < 0:
        if current_state == PepsiState.Firing:
            unaim()
        else:
            throw(true)
        #else:

        #is_pepsi_ready = false
        #throw()
        #visuals.play_anim(&"reload_catch")

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action_pressed(&"switch"):
        switch_state()

func switch_state():
    if !is_pepsi_ready:
        return
    is_pepsi_ready = false
    match current_state:
        PepsiState.Ranged:
            visuals.play_anim(&"switch_melee")
            current_state = PepsiState.Melee
        PepsiState.Melee:
            visuals.play_anim(&"switch_ranged")
            current_state = PepsiState.Ranged
        PepsiState.Firing:
            is_pepsi_ready = true

func drink(delta: float):
    if current_state != PepsiState.Ranged:
        return
    if !is_pepsi_ready:
        return

    ammo -= delta * 50
    check_ammo()
    drank.emit(delta)

func aim():
    if current_state != PepsiState.Ranged:
        return
    if !is_pepsi_ready:
        return

    current_state = PepsiState.Firing
    is_pepsi_ready = false
    visuals.play_anim(&"aim")

func unaim():
    if current_state != PepsiState.Firing:
        return
    if !is_pepsi_ready:
        return

    %Particles.emitting = false
    current_state = PepsiState.Ranged
    is_pepsi_ready = false
    visuals.play_anim(&"unaim")

func swing():
    if current_state != PepsiState.Melee:
        return
    if !is_pepsi_ready:
        return

    is_pepsi_ready = false
    visuals.play_anim(&"swing", speed_scale)

    swung.emit(melee_damage)
    fizz += 0.2

func throw(is_discard = false, debug = false):
    if !debug:
        #if current_state == current_state.Firing && ammo < 0
        #if current_state != PepsiState.Melee:
            #return
        if !is_pepsi_ready:
            return

    is_pepsi_ready = false
    ammo = 100
    fizz = 0

    var new_bottle: RigidBody3D = bottle_prop.instantiate()
    add_child(new_bottle)
    match current_state:
        PepsiState.Melee:
            new_bottle.position = %MeleeStartPos.global_position
            new_bottle.rotation = %MeleeStartPos.global_rotation
        PepsiState.Ranged:
            new_bottle.position = %RangedStartPos.global_position
            new_bottle.rotation = %RangedStartPos.global_rotation

    new_bottle.damage = throw_damage if !is_discard else discard_damage
    bottle_spawned.emit(new_bottle)

    visuals.play_anim(&"reload_catch")


func fizz_set():
    var lifetime = clampf(fizz / 2, 0.2, 1.0)
    %Particles.lifetime = lifetime
    %Particles.process_material.spread = remap(lifetime, 0.2, 1.0, 5.0, 1.0)
    var box_size = remap(lifetime, 0.2, 1.0, 2.0, 0.5)
    var box_length = remap(lifetime, 0.2, 1.0, 10.0, 40.0)
    (%RangedBox.shape as BoxShape3D).size = Vector3(
        box_size,
        box_size,
        box_length,
    )
    %RangedBox.position.z = -box_length / 2

func _on_anim_handler_animation_finished(anim_name: StringName) -> void:
    match anim_name:
        &"reload_catch":
            visuals.play_anim(&"ranged")
            is_pepsi_ready = true
            current_state = PepsiState.Ranged
            #ammo = 100
            #fizz = 0
        &"reload_throw":
            ammo = 100
            fizz = 0
            visuals.play_anim(&"reload_catch")
        &"switch_melee":
            is_pepsi_ready = true
            visuals.play_anim(&"melee")
        &"switch_ranged":
            is_pepsi_ready = true
            visuals.play_anim(&"ranged")
        &"swing":
            is_pepsi_ready = true
            visuals.play_anim(&"melee")
        &"aim":
            is_pepsi_ready = true
            visuals.play_anim(&"firing")
            %Particles.emitting = true
        &"unaim":
            is_pepsi_ready = true
            visuals.play_anim(&"ranged")
            check_ammo()
            #if ammo < 0:
                #throw()

func _physics_process(delta: float) -> void:
    fizz = clamp(fizz - (delta / 2), 0, 10)
