class_name StartArea
extends Node3D

# cant do recursize packedscene exports
@export_file("*.tscn") var tutorial_scene
@export_file("*.tscn") var enemy_tutorial_scene
@export_file("*.tscn") var world_scene
@export var player_cam: Camera3D
@export var tutorial_component: PlayerComponent

var moving_liquid = false
var started_already = false
var fading_away = false
var transitioning = false

enum States {
    NoNothing,
    DidTutorial,
    ReadyForActualGame
}
var current_state = States.NoNothing
var liquid_amount = 0.0:
    set(new):
        liquid_amount = new
        $Fade.material.set_shader_parameter(&"progress", new / 3.0)

func _ready() -> void:
    liquid_amount = 0.0
    tutorial_component.handicap()
    tutorial_component.drinkable.drank.connect(_on_drank)
    tutorial_component.bottle_state = Tutorial.TutorialState.NoBottle
    var effect: AudioEffectFilter = AudioServer.get_bus_effect(1, 0)
    effect.cutoff_hz = 50

    var transition_data = Transition.transition_data
    if transition_data.has("from"):
        $Anim.play(&"fade_in")
        match transition_data["from"]:
            "tutorial":
                 current_state = States.DidTutorial
            "enemy_tutorial":
                current_state = States.ReadyForActualGame
            "world":
                current_state = States.ReadyForActualGame
                demo_popup()

func demo_popup():
    $DemoText.show()

func _physics_process(delta: float) -> void:
    if moving_liquid:
        $Liquid.position.y += delta / 5

    var liquid_pos = $Liquid.global_position.y + 0.3
    var above_player = liquid_pos > player_cam.global_position.y
    if above_player:
        fading_away = true

    if fading_away:
        liquid_amount += delta
    if liquid_amount >= 3.0:
    #%Fade.value += delta * 30
    #if %Fade.value >= 100:
        if !transitioning:
            transitioning = true
            start_transition()
            #transition_started.emit()

func start_game() -> void:
    if started_already:
        return
    started_already = true

    MusicPlayer.playing = false

    $WorldEnvironment.environment.sky.sky_material.energy_multiplier = 0.1
    moving_liquid = true
    $Props/Lamp.turn_purple()
    $Props/Lamp2.turn_purple()
    await get_tree().create_timer(3.0).timeout
    $WorldEnvironment.environment.sky.sky_material.energy_multiplier = 0.3
    var tween = get_tree().create_tween()
    tween.tween_property($Noise, ^"volume", 0.1, 10.0)


func start_transition() -> void:
    await get_tree().create_timer(1.0).timeout
    var transition: SceneTransition = Transition
    transition.set_color(Color("060207"))
    transition.transition_started.connect(func():
        queue_free()
    )

    var target_scene: PackedScene
    match current_state:
        States.NoNothing:
            target_scene = load(tutorial_scene)
        States.DidTutorial:
            target_scene = load(enemy_tutorial_scene)
        States.ReadyForActualGame:
            target_scene = load(world_scene)

    transition.transition_to(target_scene)


func _on_interations_pressed(interacted: CollisionObject3D) -> void:
    if interacted is Area3D:
        print("button")
        %VendingMachine.button_pressed(interacted)
    elif interacted is BottleProp:
        print("bottle")
        #start_game()
        if current_state in [States.DidTutorial, States.ReadyForActualGame]:
            tutorial_component.bottle_state = Tutorial.TutorialState.ShootOnly
            interacted.queue_free()
        else:
            start_game()

func _on_drank(amount: float):
    liquid_amount += amount
    print(amount)


func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
    OS.shell_open(str(meta))
