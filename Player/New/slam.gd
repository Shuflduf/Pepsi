extends PlayerComponent

@export var slam_hitbox: Area3D
@export var slam_sfx: AudioStreamPlayer3D

var slam_height = 0.0
var slamming = false

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action_pressed(&"slam") and !player.is_on_floor():
        if !slamming:
            slamming = true
            slam_height = player.global_position.y

func _physics_process(_delta: float) -> void:
    if player.is_on_floor():
        if slamming:
            deal_slam_damage()

        slamming = false

    elif slamming:
        player.linear_velocity.y = -30

func deal_slam_damage():
    slam_sfx.play(0.08)
    #%Slam.play(0.08)
    #$SlamParticles.restart()
    var slam_diff = slam_height - player.global_position.y
    var slam_damage = ceili(slam_diff / 10.0)
    var slam_knockback = clamp(slam_diff / 20, 2.0, INF)
    for enemy: Enemy in slam_hitbox.get_overlapping_bodies():
        enemy.hit(slam_damage)
        var real_dir = enemy.position - player.global_position
        var flat_dir = (real_dir * Vector3(1, 0, 1)).normalized()
        var knockback_dir = Vector3(
            flat_dir.x,
            1.0,
            flat_dir.z
        ) * slam_knockback
        enemy.in_hitstun = true
        enemy.apply_central_impulse(knockback_dir)
