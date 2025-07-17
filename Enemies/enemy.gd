class_name Enemy
extends PhysicsEntity

signal died

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@export var immobile: bool = false
@export var starting_health = 5

var is_hit = false
var hit_cooldown = 0.0
var player: Player = null
var original_pos: Vector3 = Vector3.ZERO

var health = starting_health

func _ready() -> void:
    player = get_tree().get_first_node_in_group(&"Player")
    original_pos = global_position
    if immobile:
        mass = 10000
        collision_layer |= 0001

func _physics_process(delta: float) -> void:
    if immobile:
        linear_velocity = Vector3.ZERO
        return

    #hit_cooldown += delta
    #if is_on_floor() and hit_cooldown > 1.0:
        #is_hit = false
        #hit_cooldown = 0.0

    if player and !is_hit:
        agent.target_position = player.global_position
        var cur_pos = global_position
        var next_path_pos = agent.get_next_path_position()
        var dir = cur_pos.direction_to(next_path_pos)
        DebugDraw2D.set_text("dir", dir)
        if dir.y > 0.7 and is_on_floor():
            apply_central_impulse(Vector3.UP * jump_height)

        dir = Vector3(dir.x, 0.0, dir.z).normalized()

        #dir.y = 0
        apply_central_force(dir * delta * ground_speed)

        var look_dir = atan2(dir.x, dir.z)
        $Visuals.rotation.y = lerp_angle($Visuals.rotation.y, look_dir, delta * 10)

func hit(damage: int):
    if $HitCooldown.time_left > 0:
        return

    DebugDraw2D.set_text("hit", [damage, name, Time.get_ticks_msec()], 0, Color.WHITE, 1.0)
    is_hit = true
    health -= damage
    $HitCooldown.start()
    if health <= 0:
        die()

func die():
    queue_free()
    died.emit()


func _on_hit_cooldown_timeout() -> void:
    is_hit = false
