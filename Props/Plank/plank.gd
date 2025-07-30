class_name Plank
extends Node3D

func attempt_break(tutorial_component: PlayerComponent):
    if tutorial_component.bottle_state != Tutorial.TutorialState.FullBottle:
        return
    if tutorial_component.mode.current_mode != BMode.BottleMode.Melee:
        return

    await tutorial_component.swingable.swung
    _on_swung()


func _on_swung():
    $Particles.restart()

    $plank.queue_free()
    $Static.queue_free()
    $Area.queue_free()


func _on_gpu_particles_3d_finished() -> void:
    queue_free()
