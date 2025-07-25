extends HBoxContainer

signal switched_wave(wave: int)
signal deleted_wave(wave: int)
signal name_changed(new_name: String)

var waves_created = 0

func reset(config: MapConfig):
    waves_created = 0
    for item in %Waves.item_count:
        %Waves.remove_item(0)
    #update_options(["Wave 1"])
    _on_new_pressed()
    %TileSizeBox.value = config.tile_size
    %MapSizeBox.value = config.map_size
    %HeightScaleBox.value = config.height_scale


func _ready() -> void:
    _on_new_pressed()

func _on_waves_item_selected(index: int) -> void:
    update_name_edit()
    switched_wave.emit(index)

func _on_new_pressed() -> void:
    waves_created += 1
    var item_text = "Wave " + str(waves_created)
    %Waves.add_item(item_text)
    var new_index = %Waves.item_count - 1
    %Waves.select(new_index)
    update_name_edit()
    switched_wave.emit(new_index)
    name_changed.emit(item_text)


func _on_name_edit_text_submitted(new_text: String) -> void:
    if new_text.is_empty():
        return

    %Waves.set_item_text(%Waves.selected, new_text)
    %NameEdit.release_focus()
    name_changed.emit(new_text)

func _on_delete_pressed() -> void:
    if %Waves.item_count == 1:
        return
    deleted_wave.emit(%Waves.selected)
    %Waves.remove_item(%Waves.selected)
    %Waves.select(0)
    update_name_edit()
    switched_wave.emit(0)


func _on_save_pressed() -> void:
    %SaveDialog.show()


func _on_load_pressed() -> void:
    %LoadDialog.show()


func update_name_edit():
    %NameEdit.text = %Waves.get_item_text(%Waves.selected)


func update_options(waves: Array):
    for i in %Waves.item_count:
        %Waves.remove_item(0)

    for wave in waves:
        %Waves.add_item(wave)

    %NameEdit.text = %Waves.get_item_text(%Waves.selected)


func _on_map_config_pressed() -> void:
    %MapConfigPanel.show()
