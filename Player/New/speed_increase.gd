extends BottleComponent

@export var player: PhysicsEntity
@export var increased_speed = 6000.0
@export var increased_max = 10.0
@export var increased_max_air = 8.0

@onready var base_speed = player.ground_speed
@onready var max_speed = player.max_speed
@onready var max_air_speed = player.max_air_speed

var factor = 1.0

func _physics_process(_delta: float) -> void:
    player.ground_speed = remap(factor, 1.0, 2.0, base_speed, increased_speed)
    player.max_speed = remap(factor, 1.0, 2.0, max_speed, increased_max)
    player.max_air_speed = remap(factor, 1.0, 2.0, max_air_speed, increased_max_air)

    var vel_length = player.linear_velocity.length()
    factor = clamp(factor - (vel_length / 1500), 1.0, 10.0)

    DebugDraw2D.set_text("speed", factor)
