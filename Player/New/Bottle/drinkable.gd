extends BottleComponent

@export var visuals: BottleVisuals
@export var mode: BottleComponent
@export var throw: BottleComponent

var ammo := 100.0:
    set(new):
        ammo = new
        visuals.value = new

func _process(delta: float) -> void:
    #visuals.offset = lerp(visuals.offset, Vector2.ZERO, delta * 20)
    #if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and is_pepsi_ready and current_state == PepsiState.Ranged:

    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        drink(delta)

func check_ammo():
    if ammo < 0:
        #if mode.current_state == mode.PepsiMode.Firing:
            #unaim()
        #else:
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

    ammo -= delta * 30
    check_ammo()
    #drank.emit(delta * 0.75)
