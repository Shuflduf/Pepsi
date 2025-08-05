extends BottleComponent

@export var player: PhysicsEntity
@export var slam: PlayerComponent

func _physics_process(_delta: float) -> void:
    var vel_length = player.linear_velocity.length()
    get_parent().value += vel_length / (1000 if !slam.slamming else 2000)
