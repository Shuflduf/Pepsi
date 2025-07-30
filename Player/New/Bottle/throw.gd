extends BottleComponent

signal threw

@export var bottle_prop: PackedScene
@export var mode: BottleComponent
@export var drinkable: BottleComponent
@export var visuals: BottleVisuals
@export var player: PhysicsEntity
@export var player_info: BottleComponent
@export var fizz: BottleComponent
@export var bottle_prop_pos: Node3D

var starting_strength = 3.0
var throw_strength = starting_strength:
    set(new):
        throw_strength = new
        visuals.update_throw_strength(new - starting_strength)

func _physics_process(delta: float) -> void:
    if mode.current_mode == mode.BottleMode.Melee:
        if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):

            throw_strength += delta * 15
        elif throw_strength > starting_strength:
        #if current_state == PepsiState.Melee and throw_strength:
            throw()
            #throw_strength = 0.0

func _ready() -> void:
    visuals.animation_finished.connect(_on_visuals_animation_finished)

func throw():
        #if current_state == current_state.Firing && ammo < 0
        #if current_state != PepsiState.Melee:
            #return
    if !mode.is_ready:
        return

    mode.is_ready = false
    drinkable.ammo = 100
    fizz.value = 0

    var new_bottle: RigidBody3D = bottle_prop.instantiate()
    var throw_damage = ceil(throw_strength / 10)

    #new_bottle.damage = discard_damage if is_discard else throw_damage
    new_bottle.damage = throw_damage
    add_child(new_bottle)
    new_bottle.global_position = bottle_prop_pos.global_position
    #new_bottle.position = %MiddleStartPos.global_position
    #new_bottle.rotation = %MiddleStartPos.global_rotation

    #new_bottle.linear_velocity = player_info.get_look_vec() * 20
    new_bottle.linear_velocity = player.linear_velocity
    new_bottle.linear_velocity += player_info.get_look_vec() * throw_strength
    new_bottle.init_velocity = new_bottle.linear_velocity.normalized()
    new_bottle.angular_velocity = player_info.get_look_vec().rotated(Vector3.UP, PI/2) * throw_strength
    #match mode.current_mode:
        #mode.BottleMode.Melee:
            #new_bottle.position = %MeleeStartPos.global_position
            #new_bottle.rotation = %MeleeStartPos.global_rotation

            #bottle_spawned.emit(new_bottle, clamp(throw_strength, 5.0, INF))
        #mode.BottleMode.Ranged:
            #new_bottle.position = %RangedStartPos.global_position
            #new_bottle.rotation = %RangedStartPos.global_rotation
            #bottle_spawned.emit(new_bottle, 20)

    #visuals.update_throw_strength(0)
    threw.emit()
    throw_strength = starting_strength
    visuals.play_anim(&"reload_catch")

func _on_visuals_animation_finished(anim_name: StringName):
    if anim_name == &"reload_catch":
        mode.is_ready = true
        mode.current_mode = mode.BottleMode.Ranged
        visuals.play_anim(&"ranged")
