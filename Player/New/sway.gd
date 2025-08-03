extends BottleComponent

@export var visuals: BottleVisuals

func _process(delta: float) -> void:
    visuals.offset = lerp(visuals.offset, Vector2.ZERO, delta * 20)

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        visuals.offset -= event.relative * Engine.time_scale
