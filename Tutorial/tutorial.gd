class_name Tutorial
extends Node3D

@export var start_area_scene: PackedScene
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

var last_checkpoint: Checkpoint

func _ready() -> void:
    tutorial_component.bottle_state = current_state
    connect_all_checkpoints()

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
                %Anims.play(&"swing_intro")


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


func _on_exit_trigger_body_entered(_body: Node3D) -> void:
    $ExitOverlay.show()
    #await get_tree().create_timer(2.0).timeout
    var transition = Transition
    transition.transition_data = { "from": "tutorial" }
    transition.set_color(Color.WHITE)
    transition.transition_to(start_area_scene)
    transition.transition_started.connect(queue_free)

func _on_kill_trigger_body_entered(body: Node3D) -> void:
    prints("kill", body)
    last_checkpoint.show_labels()
    %Player.global_position = last_checkpoint.global_position
    %Player.linear_velocity = Vector3.ZERO

func connect_all_checkpoints():
    for check: Area3D in get_tree().get_nodes_in_group(&"Checkpoint"):
        check.body_entered.connect(_on_checkpoint_entered.bind(check))

func _on_checkpoint_entered(_body: PhysicsEntity, check: Area3D):
    last_checkpoint = check
    #prints(body, check)
