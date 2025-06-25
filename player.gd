extends RigidBody3D

@onready var ui: Control = $UI
@onready var pepsi_bar: TextureProgressBar = $UI/TextureProgressBar

func _process(delta: float) -> void:
    pepsi_bar.value -= delta * 10
