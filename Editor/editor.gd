extends Control

var wave = 0
var current_state: Array[Wave] = []

func _ready() -> void:
    for x in %Height.get_child_count():
        var col = %Height.get_child(x)
        for y in col.get_child_count():
            var item: Button = col.get_child(y)

            item.pressed.connect(item_pressed.bind(item, x, y))

func current_wave() -> Wave:
    if current_state.size() < wave + 1:
        current_state.push_back(Wave.new())
        #current_state.resize(wave + 1)
        #current_state.fill(Wave.new())

    return current_state[wave]

func item_pressed(item: Button, x: int, y: int):
    var new_val = (int(item.text) + 1) % 10
    item.text = str(new_val)
    current_wave().heights[x][y] = new_val
    update_map()
    #get_map_state().json()

func update_map():
    %Map.set_wave(current_wave())

func update_height_buttons():
    for x in %Height.get_child_count():
        var col = %Height.get_child(x)
        for y in col.get_child_count():
            var item: Button = col.get_child(y)

            item.text = str(current_wave().heights[x][y])

func _on_extra_switched_wave(new_wave: int) -> void:
    wave = new_wave
    update_map()
    update_height_buttons()
