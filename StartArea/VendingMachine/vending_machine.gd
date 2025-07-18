extends Node3D

@onready var buttons = [
    $VendingMachine/Cube_014,
    $VendingMachine/Cube_032,
    $VendingMachine/Cube_033,
    $VendingMachine/Cube_034,
    $VendingMachine/Cube_035,
]

var being_pressed: Array[MeshInstance3D]

#func _physics_process(delta: float) -> void:
    #for button in buttons:
        #var tween =


func _on_slow_player_pressed(area: Area3D) -> void:
    var button: MeshInstance3D = area.get_parent()
    if button in being_pressed:
        return
    being_pressed.append(button)
    #button.position.x = -0.1
    var tween = get_tree().create_tween().set_trans(Tween.TRANS_CIRC)
    tween.tween_property(button, ^"position:x", -0.1, 0.5).set_ease(Tween.EASE_IN)
    tween.tween_callback(spawn_bottle)
    # just wait
    #tween.tween_property(button, ^"position:x", -0.1, 0.5)
    tween.tween_property(button, ^"position:x", 0, 0.5).set_ease(Tween.EASE_OUT)
    tween.tween_callback(being_pressed.erase.bind(button))

func spawn_bottle():
    pass
