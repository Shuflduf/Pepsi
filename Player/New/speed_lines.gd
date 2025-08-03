extends PlayerComponent

@export var speed_particles: GPUParticles3D
@export var max_alpha = 0.3

@onready var material: StandardMaterial3D = speed_particles.draw_pass_1.surface_get_material(0)

func _physics_process(delta: float) -> void:
    var speed = player.linear_velocity.length()
    DebugDraw2D.set_text("speed", speed)
    var alpha = remap(speed, 0.0, 12.0, -0.5, 0.3)
    alpha = min(alpha, max_alpha)
    set_alpha(alpha)

func set_alpha(alpha: float):
    if alpha < 0.0:
        alpha = 0.0
    material.albedo_color.a = alpha
