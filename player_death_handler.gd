extends Node3D

signal transitioned

@export var player: PhysicsEntity
@export var from: String
@export_file("*.tscn") var start_area_path

var died_already = false

func _ready() -> void:
    var health_comp = player.get_component("Health")
    if health_comp:
        health_comp.died.connect(_on_player_died)

func _on_player_died():
    if died_already:
        return
    died_already = true
    var tween = get_tree().create_tween()
    tween.set_ignore_time_scale(true)
    tween.tween_property(Engine, ^"time_scale", 0.0, 2.0)
    tween.parallel().tween_property($ExitOverlay, ^"color:a", 1.0, 2.0)
    tween.tween_callback(start_transition)
    print("dieeee")

func start_transition():
    Engine.time_scale = 1.0
    var target_scene = load(start_area_path)
    var transition = Transition
    transition.set_color(Color.AZURE)
    transition.transition_to(target_scene)
    transition.transition_data = { "from": from }
    transition.transition_started.connect(transitioned.emit)
