extends Control

@export var world_scene: PackedScene

func _on_start_pressed() -> void:
    var trans: SceneTransition = Transition
    trans.transition_started.connect(_on_transition_started)
    trans.transition_to(world_scene)


func _on_transition_started():
    queue_free()
