extends BottleComponent

@export var look_around: PlayerComponent

func _ready() -> void:
    look_around.looked_around.connect(_on_looked_around)

func _on_looked_around(amount: float):
    get_parent().value += amount / 30000
