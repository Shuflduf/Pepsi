extends BottleComponent

signal drank(amount: float)

@export var visuals: BottleVisuals
@export var mode: BottleComponent
@export var throw: BottleComponent
@export var speed_increase: BottleComponent
@export var health: Health

var ammo := 100.0:
    set(new):
        ammo = new
        visuals.value = new

func _physics_process(delta: float) -> void:
    #visuals.offset = lerp(visuals.offset, Vector2.ZERO, delta * 20)
    #if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and is_pepsi_ready and current_state == PepsiState.Ranged:

    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        drink(delta)

func check_ammo():
    if ammo < 0:
        #if mode.current_state == mode.PepsiMode.Firing:
            #unaim()
        #else:
        throw.throw_strength = 20.0
        throw.throw()
        #throw(true)

func drink(delta: float):
    if mode.current_mode != mode.BottleMode.Ranged:
        #$Drink.stop()
        #$DrinkPour.stop()
        return
    if !mode.is_ready:
        #$Drink.stop()
        #$DrinkPour.stop()
        return

    #if !$Drink.playing:
        #$Drink.play()
        #$DrinkPour.play()

    ammo -= delta * 60.0
    check_ammo()
    health.health += delta * 10.0
    speed_increase.factor += delta
    drank.emit(delta)
