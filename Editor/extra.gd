extends MarginContainer

signal switched_wave(wave: int)

func _on_waves_item_selected(index: int) -> void:
    switched_wave.emit(index)

func _on_button_pressed() -> void:
    %Waves.add_item("Wave " + str(%Waves.item_count + 1))
    var new_index = %Waves.item_count - 1
    %Waves.select(new_index)
    switched_wave.emit(new_index)
