extends PlayerComponent

signal jumped

@export var jump_sfx: AudioStreamPlayer3D
@export var land_particles: GPUParticles3D
@export var land_sfx: AudioStreamPlayer3D
@export var jump_particles: GPUParticles3D

var time_off_ground = 0.0
var jump_enabled = true

func _physics_process(delta: float) -> void:
    time_off_ground += delta
    if time_off_ground > 0.1 and player.is_on_floor():
        land_sfx.play()
        land_particles.restart()

    if player.is_on_floor():
        time_off_ground = 0.0

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_pressed():
        if event.is_action_pressed(&"jump") and player.is_on_floor():
            if not jump_enabled:
                return
            #$JumpParticles.restart()
            player.apply_central_impulse(Vector3.UP * player.jump_height)
            #%Jump.play()
            jump_particles.restart()
            jump_sfx.play()
            jumped.emit()
