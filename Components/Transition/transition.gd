class_name SceneTransition
extends Control

signal transition_started
signal transition_finished

var transitioning = false

func set_color(col: Color):
    $Rect.material.set_shader_parameter(&"target_color", col)

func transition_to(scene: PackedScene):
    if transitioning:
        return
    transitioning = true

    var tween = get_tree().create_tween()
    var loaded = scene.instantiate()
    var rect_material: ShaderMaterial = $Rect.material
    rect_material.set_shader_parameter(&"upside_down", false)
    rect_material.set_shader_parameter(&"height", -1.0)
    tween.tween_property(rect_material, ^"shader_parameter/height", 1, 1.0)
    tween.tween_callback(transition_started.emit)
    tween.tween_callback(get_tree().root.add_child.bind(loaded))

    tween.tween_property($Rect, ^"material:shader_parameter/upside_down", true, 0.0)
    tween.tween_property($Rect, ^"material:shader_parameter/height", -2, 0.0)
    tween.tween_property($Rect, ^"material:shader_parameter/height", 0.1, 1.0)
    tween.tween_callback(transition_finished.emit)
    tween.finished.connect(func(): transitioning = false)
