extends PlayerComponent

@export var mode: BottleComponent
@export var visuals: BottleVisuals
@export var health_bar: Range
@export var fizz_bar: Range
@export var shoot_particles: GPUParticles3D

@export var swingable: BottleComponent
@export var drinkable: BottleComponent
@export var fizz: BottleComponent
@export var speed_increase: BottleComponent

@export var wasd: PlayerComponent
@export var jump: PlayerComponent

var bottle_state = Tutorial.TutorialState.NoBottle:
    set(new):
        bottle_state = new

        var bottle_enabled = new != Tutorial.TutorialState.NoBottle
        mode.is_ready = bottle_enabled
        visuals.visible = bottle_enabled
        health_bar.visible = bottle_enabled
        fizz_bar.visible = bottle_enabled
        shoot_particles.visible = bottle_enabled

        if bottle_enabled:
            mode.is_ready = false
            fizz.value = 0.0
            drinkable.ammo = 100.0
            visuals.hide()
            get_tree().create_timer(0.2).timeout.connect(visuals.show)
            visuals.play_anim(&"reload_catch")

        match new:
            Tutorial.TutorialState.ShootOnly:
                mode.can_switch = false

            Tutorial.TutorialState.FullBottle:
                mode.can_switch = true


        print(new)

func handicap():
    speed_increase.disabled = true
    player.ground_speed = 1500.0
    wasd.speed_factor = 0.5
    jump.jump_enabled = false

func _physics_process(_delta: float) -> void:
    if bottle_state == Tutorial.TutorialState.NoBottle:
        mode.is_ready = false
