extends Node3D

@export var base_player_scene: PackedScene
@export var tutorial_component: PlayerComponent

enum TutorialState {
    NoBottle,
    ShootOnly,
    FullBottle,
}

var current_state := TutorialState.ShootOnly
var picked_up_bottle = true

func _on_interations_pressed(interacted: CollisionObject3D) -> void:
    if interacted is Area3D:
        print("button")
        %VendingMachine.button_pressed(interacted)
    elif interacted is BottleProp and not picked_up_bottle:
        picked_up_bottle = true
        %Anims.play(&"drinking_intro")
        interacted.queue_free()
        tutorial_component.bottle_enabled = true
        tutorial_component.base_bottle()
        print("bottle")


        #var bottle = temp_player.find_child("Bottle")
        #bottle.reparent(%Player)
        #%Player.add_child(bottle)
        #temp_player.free()
        #start_game()
