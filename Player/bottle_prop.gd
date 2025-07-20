class_name BottleProp
extends RigidBody3D

var init_velocity: Vector3
var touched_ground = false
var damage: int

func _on_body_entered(body: Node) -> void:
    if touched_ground:
        return

    if body is Enemy:
        var hit_vec = init_velocity
        hit_vec.y = clamp(hit_vec.y, 0.3, 1)
        var mult = 20
        body.apply_central_impulse(hit_vec * mult)
        body.in_hitstun = true
        body.hit(damage)

    await get_tree().create_timer(0.01).timeout
    after_bounce()

func after_bounce():
    touched_ground = true
    physics_material_override.absorbent = true
    linear_velocity /= 2
    angular_velocity /= 20

func set_size(scalar: float):
    $pepsi.scale *= scalar
    $CollisionShape3D.scale *= scalar

func use():
    #print("AAAAAAAAAA")
    pass
