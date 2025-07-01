extends RigidBody3D

@onready var ui: Control = $UI
@export var mouse_sens: float = 0.01

@export var ranged_textures: Array[Texture2D]
@export var melee_textures: Array[Texture2D]

enum PepsiState {
    Melee,
    Ranged
}

var is_pepsi_ready = false
var ammo = 100
var current_state = PepsiState.Ranged

func _ready() -> void:
    switch_texture_set(PepsiState.Ranged)
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    %PepsiAnim.play(&"reload")

func _process(delta: float) -> void:
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and is_pepsi_ready:
        ammo -= delta * 50
        check_ammo()
    refresh_pepsi_bar()

func switch_texture_set(state: PepsiState):
    var texture_set = ranged_textures if state == PepsiState.Ranged else melee_textures
    %PepsiBar.texture_under = texture_set[0]
    %PepsiBar.texture_over = texture_set[1]
    %PepsiBar.texture_progress = texture_set[2]

func check_ammo():
    if ammo < 0:
        is_pepsi_ready = false
        ammo = 100
        %PepsiBar.hide()
        %PepsiAnim.show()
        %PepsiAnim.play(&"throw")

func refresh_pepsi_bar():
    %PepsiBar.value = ammo * 0.6

func is_on_floor() -> bool:
    if test_move(transform, Vector3.DOWN*0.1 * get_physics_process_delta_time() ):
        return true
    else:
        return false

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_pressed():
        if event.is_action_pressed("switch"):
            switch_state()
        if event.is_action_pressed("jump") and is_on_floor():
            apply_central_impulse(Vector3.UP * 5)
        if event.is_action_pressed("ui_cancel"):
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

func switch_state():
    is_pepsi_ready = false
    print("switching")
    match current_state:
        PepsiState.Ranged:
            %PepsiAnim.play(&"switch_melee")
            current_state = PepsiState.Melee
        PepsiState.Melee:
            %PepsiAnim.play(&"switch_ranged")
            current_state = PepsiState.Ranged

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        rotate_y(-event.relative.x * mouse_sens)

        $CamPivot.rotate_x(-event.relative.y * mouse_sens)
        $CamPivot.rotation.x = clamp($CamPivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))


func _on_pepsi_anim_animation_finished() -> void:
    match %PepsiAnim.animation:
        &"reload":
            is_pepsi_ready = true
            %PepsiBar.show()
            %PepsiAnim.hide()
        &"throw":
            %PepsiAnim.play(&"reload")
        &"switch_melee":
            is_pepsi_ready = true
            %PepsiBar.show()
            %PepsiAnim.hide()
        &"switch_ranged":
            is_pepsi_ready = true
            %PepsiBar.show()
            %PepsiAnim.hide()
