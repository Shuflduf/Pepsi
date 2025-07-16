extends HBoxContainer

signal updated_height(x: int, y: int, new_val: int)

enum Mode {
    Increase,
    Decrease,
    Set,
}

var current_mode: Mode = Mode.Increase
var set_value = 0

func _ready() -> void:
    for x in %Buttons.get_child_count():
        var col = %Buttons.get_child(x)
        for y in col.get_child_count():
            var item: Button = col.get_child(y)

            item.pressed.connect(item_pressed.bind(item, x, y))

func item_pressed(item: Button, x: int, y: int):
    var old_val = int(item.text)
    var new_val = 0

    match current_mode:
        Mode.Increase:
            new_val = (old_val + 1) % 10
        Mode.Decrease:
            # i love modulus
            new_val = (old_val + 9) % 10
        Mode.Set:
            new_val = set_value

    item.text = str(new_val)
    updated_height.emit(x, y, new_val)

func update_buttons(heights: Array):
    for x in %Buttons.get_child_count():
        var col = %Buttons.get_child(x)
        for y in col.get_child_count():
            var item: Button = col.get_child(y)

            item.text = str(heights[x][y])

# Tools
func _on_set_value_pressed() -> void:
    var old_value = int(%SetValue.text)
    set_value = (old_value + 1) % 10
    %SetValue.text = str(set_value)
    %ModeLabel.text = "Set (%d)" % set_value


func _on_increase_pressed() -> void:
    current_mode = Mode.Increase
    %ModeLabel.text = "Increase"

func _on_decrease_pressed() -> void:
    current_mode = Mode.Decrease
    %ModeLabel.text = "Decrease"


func _on_set_pressed() -> void:
    current_mode = Mode.Set
    %ModeLabel.text = "Set (%d)" % set_value
