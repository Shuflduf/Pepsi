extends BottleComponent

signal fizz_changed(new_fizz: float)

@export var visuals: BottleVisuals
@export var fizz_bar: Range

var value = 0.0:
    set(new):
        new = max(0.0, new)
        value = new
        visuals.fizz = new
        #%FizzBar.value = new
        fizz_bar.value = new
        fizz_changed.emit(new)
        #fizz_set()

func _physics_process(delta: float) -> void:
    DebugDraw2D.set_text("fizz", value)
    value -= delta / 10

#func fizz_set():
    #var lifetime = clampf(fizz / 2, 0.2, 1.0)
    #%Particles.lifetime = lifetime
    #%Particles.process_material.spread = remap(lifetime, 0.2, 1.0, 5.0, 1.0)
    #var box_size = remap(lifetime, 0.2, 1.0, 2.0, 0.5)
    #var box_length = remap(lifetime, 0.2, 1.0, 10.0, 40.0)
    #(%RangedBox.shape as BoxShape3D).size = Vector3(
        #box_size,
        #box_size,
        #box_length,
    #)
    #%RangedBox.position.z = -box_length / 2
