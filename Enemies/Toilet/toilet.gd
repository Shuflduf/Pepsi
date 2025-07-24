extends Enemy

@export var base_speed = 3000.0
@export var boosted_speed = 5000.0
@export var base_damage = 5
@export var boosted_damage = 12

func _on_body_entered(body: Node) -> void:
    if body is PhysicsEntity:
        damage(body, boosted_damage if is_boosted else base_damage)

func _physics_process(delta: float) -> void:
    super(delta)
    ground_speed = boosted_speed if is_boosted else base_speed
