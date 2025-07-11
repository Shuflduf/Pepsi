extends Node

@onready var visuals: BottleVisuals = %Visuals

signal swung
signal fly(fizz: float)

var pepsi_pos = Vector2.ZERO

enum PepsiState {
    Melee,
    Ranged,
    Firing,
}

var is_pepsi_ready = false
var ammo = 100:
    set(value):
        ammo = value
        visuals.value = value
var fizz = 0.0:
    set(value):
        fizz = value
        visuals.fizz = value

var current_state = PepsiState.Ranged

func _ready() -> void:
    visuals.play_anim(&"reload_catch")

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        visuals.offset -= event.relative

func _process(delta: float) -> void:
    visuals.offset = lerp(visuals.offset, Vector2.ZERO, delta * 20)
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and is_pepsi_ready and current_state == PepsiState.Ranged:
        ammo -= delta * 50
        check_ammo()

    if current_state == PepsiState.Firing:
        ammo -= delta * 50
        check_ammo()
        if is_pepsi_ready:
            fizz -= delta * 2
            fly.emit(fizz)

    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        swing()

    if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        aim()
    else:
        unaim()


func check_ammo():
    if ammo < 0:
        unaim()
        is_pepsi_ready = false
        visuals.play_anim(&"reload_throw")

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_pressed():
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
    visuals.play_anim(&"swing")

    swung.emit()
    fizz += 0.5

func _on_anim_handler_animation_finished(anim_name: StringName) -> void:
    match anim_name:
        &"reload_catch":
            visuals.play_anim(&"ranged")
            is_pepsi_ready = true
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

func _physics_process(delta: float) -> void:
    fizz = clamp(fizz - (delta / 2), 0, 10)
