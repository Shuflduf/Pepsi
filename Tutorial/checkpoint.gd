class_name Checkpoint
extends Area3D

@export var hint_labels: Node3D

func _ready() -> void:
    if hint_labels:
        hint_labels.hide()

func show_labels():
    if hint_labels:
        hint_labels.show()
