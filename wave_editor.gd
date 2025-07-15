extends Control

func _ready() -> void:
    for col in %Height.get_children():
        for item: Button in col.get_children():
            item.pressed.connect(item_pressed.bind(item))

func get_map_state() -> MapState:
    var new_state = MapState.new()
    for x in %Height.get_child_count():
        var col = %Height.get_child(x)
        for y in col.get_child_count():
            var item: Button = col.get_child(y)
            new_state.heights[x][y] = int(item.text)

    return new_state

func item_pressed(item: Button):
    item.text = str((int(item.text) + 1) % 10)
    %Map.set_state(get_map_state())
