extends HBoxContainer

signal updated_height(x: int, y: int, new_val: int)

func _ready() -> void:
    for x in $Buttons.get_child_count():
        var col = $Buttons.get_child(x)
        for y in col.get_child_count():
            var item: Button = col.get_child(y)

            item.pressed.connect(item_pressed.bind(item, x, y))

func item_pressed(item: Button, x: int, y: int):
    var new_val = (int(item.text) + 1) % 10
    item.text = str(new_val)
    updated_height.emit(x, y, new_val)

func update_buttons(heights: Array[Array]):
    for x in $Buttons.get_child_count():
        var col = $Buttons.get_child(x)
        for y in col.get_child_count():
            var item: Button = col.get_child(y)

            item.text = str(heights[x][y])
