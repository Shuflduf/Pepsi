class_name Enemy
extends PhysicsEntity

signal died

@onready var boosted_timer: Timer = $BoostedTimer
@onready var agent: NavigationAgent3D = $NavigationAgent3D

@export var immobile: bool = false
@export var starting_health = 5
@export var damage_indicator_scene: PackedScene
@export var damage_indicator_offset: float = 0.0

var is_hit = false
var in_hitstun = false
var hit_cooldown = 0.0
var player: PhysicsEntity = null
var disabled = false
var is_boosted = false:
    set(new):
        is_boosted = new
        $BoostedParticles.emitting = new

var health = starting_health

var current_wave_heights: Array
var map_tile_size = 5
var map_size = 6
var map_resolution = 2

func _ready() -> void:
    if immobile:
        mass = 10000
        # part of the world
        collision_layer |= 1
    #var actual_col = collision_layer
    #var actual_pos = position
    #collision_layer = 0
    $Visuals.rotate_y(randf_range(-PI, PI))
    freeze = true
    var vis_pos = $Visuals.position.y
    $Visuals.position.y -= 5.0

    var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property($Visuals, ^"position:y", vis_pos, 1.0)
    await tween.finished

    $Visuals.position.y = vis_pos
    freeze = false
    player = get_tree().get_first_node_in_group(&"Player")


func _physics_process(delta: float) -> void:
    if immobile:
        linear_velocity = Vector3.ZERO
        return

    hit_cooldown += delta
    if is_on_floor() and hit_cooldown > 0.1:
        in_hitstun = false
        hit_cooldown = 0.0

    if player and !is_hit and !in_hitstun:
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

func hit(damage_amount: int):
    if $HitCooldown.time_left > 0:
        return

    $HitParticles.restart()
    DebugDraw2D.set_text("hit", [damage_amount, name, Time.get_ticks_msec()], 0, Color.WHITE, 1.0)
    spawn_damage_indicator(damage_amount)

    is_hit = true
    health -= damage_amount
    $HitCooldown.start()
    if health <= 0:
        die()

func spawn_damage_indicator(damage_dealt: int):
    var damage_indic: DamageIndicator = damage_indicator_scene.instantiate()
    damage_indic.set_damage(damage_dealt)
    get_tree().root.add_child(damage_indic)
    damage_indic.global_position = global_position
    damage_indic.global_position.y += damage_indicator_offset

func die():
    died.emit()
    collision_layer = 0
    collision_mask = 0
    $Visuals.hide()
    disabled = true
    if $HitParticles.emitting:
        await $HitParticles.finished

    queue_free()

func _on_hit_cooldown_timeout() -> void:
    is_hit = false

static func damage(target_player: PhysicsEntity, amount: int):
    var health_component = target_player.find_child(^"Health")
    if health_component is Health:
        health_component.hit(amount)


func _on_boosted_timer_timeout() -> void:
    is_boosted = false
