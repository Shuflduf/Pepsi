extends Node3D

@onready var buttons = [
    $VendingMachine/Cube_014,
    $VendingMachine/Cube_032,
    $VendingMachine/Cube_033,
    $VendingMachine/Cube_034,
    $VendingMachine/Cube_035,
]

@export var bottle: PackedScene

var being_pressed: bool

#func _physics_process(delta: float) -> void:
    #for button in buttons:
        #var tween =


func _on_slow_player_pressed(area: Area3D) -> void:
    if being_pressed:
        return
    being_pressed = true

    var button: MeshInstance3D = area.get_parent()

    var tween = get_tree().create_tween().set_trans(Tween.TRANS_CIRC)
    tween.tween_property(button, ^"position:x", -0.05, 0.5).set_ease(Tween.EASE_IN)
    tween.tween_property(button, ^"position:x", 0, 0.5).set_ease(Tween.EASE_OUT)
    tween.tween_callback(func(): being_pressed = false)
    tween.tween_callback(spawn_bottle)

func spawn_bottle():
    var new_bottle: RigidBody3D = bottle.instantiate()

    add_child(new_bottle)
    new_bottle.set_size(0.5)
    new_bottle.global_position = $BottleSpawnPos.global_position
