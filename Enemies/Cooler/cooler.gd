extends Enemy

func _physics_process(delta: float) -> void:
    var enemies = $DetectionArea.get_overlapping_bodies()
    for e in enemies:
        DebugDraw3D.draw_arrow(global_position, e.global_position, Color.GREEN, 0.5, true)
