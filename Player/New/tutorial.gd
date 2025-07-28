extends PlayerComponent

@export var mode: BottleComponent
@export var visuals: BottleVisuals
@export var health_bar: Range
@export var fizz_bar: Range
@export var shoot_particles: GPUParticles3D

@export var drinkable: BottleComponent
@export var fizz: BottleComponent

var bottle_enabled = false:
    set(new):
        bottle_enabled = new

        mode.is_ready = bottle_enabled
        visuals.visible = bottle_enabled
        health_bar.visible = bottle_enabled
        fizz_bar.visible = bottle_enabled
        shoot_particles.visible = bottle_enabled

func _physics_process(_delta: float) -> void:
    if not bottle_enabled:
        mode.is_ready = false

func _ready() -> void:
    bottle_enabled = false

func base_bottle():
    mode.can_switch = false
    mode.is_ready = false
    fizz.value = 0.0
    drinkable.ammo = 100.0
    visuals.hide()
    get_tree().create_timer(0.2).timeout.connect(visuals.show)
    visuals.play_anim(&"reload_catch")
