extends Enemy

func _ready() -> void:
    mass = 10000
    collision_layer |= 1

#func _physics_process(delta: float) -> void:
    #if death_inevitable and not $HitParticles.emmiting:
        #queue_free()
