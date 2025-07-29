class_name Enemy
extends PhysicsEntity

signal died

@onready var boosted_timer: Timer = $BoostedTimer
@onready var agent: NavigationAgent3D = $NavigationAgent3D

@export var immobile: bool = false
@export var starting_health = 5
@export var damage_indicator_scene: PackedScene
@export var damage_indicator_offset: float = 0.0

var can_take_damage = true
var in_hitstun = false
var hit_cooldown = 0.0
var player: PhysicsEntity = null
var disabled = false
var is_boosted = false:
    set(new):
        is_boosted = new
        $BoostedParticles.emitting = new

var health = starting_health
var death_inevitable = false

var current_wave_heights: Array
var map_config: MapConfig

func _ready() -> void:
    if immobile:
        mass = 10000
        collision_layer |= 1

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

    if player and !in_hitstun:
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

func hit_immunity():
    if not can_take_damage:
        return
    can_take_damage = false
    %HitImmunity.start()

func hit(damage_amount: int):
    if %HitImmunity.time_left > 0:
        return
    if death_inevitable:
        return

    if can_take_damage:
        $HitParticles.restart()
        %HitstunTimer.start()
        in_hitstun = true
        spawn_damage_indicator(damage_amount)
        health -= damage_amount
        if health <= 0:
            die()

func spawn_damage_indicator(damage_dealt: int):
    var damage_indic: DamageIndicator = damage_indicator_scene.instantiate()
    damage_indic.set_damage(damage_dealt)
    get_tree().root.add_child(damage_indic)
    damage_indic.global_position = global_position
    damage_indic.global_position.y += damage_indicator_offset

func die():
    death_inevitable = true
    died.emit()
    collision_layer = 0
    collision_mask = 0
    $Visuals.hide()
    disabled = true
    if $HitParticles.emitting:
        await $HitParticles.finished

    queue_free()

func _on_hit_cooldown_timeout() -> void:
    can_take_damage = true

static func damage(target_player: PhysicsEntity, amount: int):
    var health_component = target_player.find_child("Health")
    if health_component is Health:
        health_component.hit(amount)


func _on_boosted_timer_timeout() -> void:
    is_boosted = false


func _on_hitstun_timer_timeout() -> void:
    in_hitstun = false
