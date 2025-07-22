extends BottleComponent

@export var mode: BottleComponent
@export var visuals: BottleVisuals

func _ready() -> void:
    visuals.play_anim(&"reload_catch")
