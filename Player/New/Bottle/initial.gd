extends BottleComponent

@export var mode: BottleComponent
@export var visuals: BottleVisuals
@export var fizz: BottleComponent

func _ready() -> void:
    visuals.play_anim(&"reload_catch")
    fizz.value = 0.0
