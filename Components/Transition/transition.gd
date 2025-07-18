class_name SceneTransition
extends Control

signal transition_started
signal transition_finished


func transition_to(scene: PackedScene):
    var tween = get_tree().create_tween()
    var loaded = scene.instantiate()
    tween.tween_property($Rect, ^"material:shader_parameter/height", 1, 1.0)
    tween.tween_callback(transition_started.emit)
    tween.tween_callback(get_tree().root.add_child.bind(loaded))

    tween.tween_property($Rect, ^"material:shader_parameter/height", -1, 1.0)
