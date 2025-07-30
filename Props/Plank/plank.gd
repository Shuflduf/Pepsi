class_name Plank
extends Node3D

var swung_connect = false

#func _on_area_area_entered(area: Area3D) -> void:
    #print(area.owner)

func attempt_break(tutorial_component: PlayerComponent):
    if tutorial_component.bottle_state != Tutorial.TutorialState.FullBottle:
        return

    await tutorial_component.swingable.swung
    _on_swung()
    #print(tutorial_component.swingable)
    #if not swung_connect:
        ## disconnect all other signals
        #for sig: Dictionary in tutorial_component.swingable.swung.get_connections():
            #var sig_call = sig["callable"]
            #tutorial_component.swingable.swung.disconnect(sig_call)
#
        #tutorial_component.swingable.swung.connect(_on_swung)
        #swung_connect = true

func _on_swung():
    $Particles.restart()

    $plank.queue_free()
    $Static.queue_free()
    $Area.queue_free()

    #print("AAAAAAAAA")


func _on_gpu_particles_3d_finished() -> void:
    queue_free()
