extends Control

@export var world_scene: PackedScene
@export var start_area_scene: PackedScene

var transitioning = false

func _ready() -> void:
    get_viewport().get_window().files_dropped.connect(_on_files_dropped)

func _on_files_dropped(files: PackedStringArray):
    print(files)
    var file_path = files[0]
    if file_path.get_extension() != "pepsi":
        return
    Transition.transition_data = { "level_path": file_path }
    Transition.transition_to(world_scene)
    Transition.transition_started.connect(queue_free)

func _on_start_pressed() -> void:
    if transitioning:
        return
    transitioning = true

    var trans: SceneTransition = Transition
    trans.transition_started.connect(_on_transition_started)
    trans.transition_to(start_area_scene)


func _on_transition_started():
    queue_free()

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action_pressed(&"switch"):
        Transition.transition_to(preload("res://Editor/editor.tscn"))
        Transition.transition_started.connect(queue_free)
