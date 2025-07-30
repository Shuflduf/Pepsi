class_name Tutorial
extends Node3D

@export var base_player_scene: PackedScene
@export var tutorial_component: PlayerComponent
@export var first_vending_machine: VendingMachine
@export var second_vending_machine: VendingMachine

@export var current_state := TutorialState.ShootOnly

enum TutorialState {
    NoBottle,
    ShootOnly,
    FullBottle,
}



func _ready() -> void:
    tutorial_component.bottle_state = current_state

func _on_interations_pressed(interacted: CollisionObject3D) -> void:
    if interacted is Area3D and interacted.owner is VendingMachine:
        interacted.owner.button_pressed(interacted)

    elif interacted is BottleProp:
        interacted.queue_free()
        match interacted.get_parent():
            first_vending_machine:
                current_state = TutorialState.ShootOnly
                %Anims.play(&"drinking_intro")
            second_vending_machine:
                current_state = TutorialState.FullBottle


        tutorial_component.bottle_state = current_state
    elif interacted.owner is Plank:
        interacted.owner.attempt_break(tutorial_component)
        #print(interacted)
        #print(tutorial_component.mode.current_mode)


        #var bottle = temp_player.find_child("Bottle")
        #bottle.reparent(%Player)
        #%Player.add_child(bottle)
        #temp_player.free()
        #start_game()
