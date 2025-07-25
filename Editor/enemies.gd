extends HBoxContainer

signal updated_enemies(x: int, y: int, new_val: int)

@export var enemies: AllEnemyData

func create_buttons(map_size: int):
    for col in %EnemyButtons.get_children():
        col.free()

    for col in map_size:
        var new_col = %EnemyTemplate.duplicate()
        %EnemyButtons.add_child(new_col)
        new_col.show()
        for button in map_size - 1:
            var new_button: Button = new_col.get_child(0).duplicate()
            new_col.add_child(new_button)

            #new_button.text = str(Vector2(col, button))

    bind_buttons()

func bind_buttons():
    for x in %EnemyButtons.get_child_count():
        var col = %EnemyButtons.get_child(x)
        for y in col.get_child_count():
            var item: Button = col.get_child(y)
            item.tooltip_text = "%d, %d" % [x, y]
            item.pressed.connect(item_pressed.bind(item, x, y))


func _ready() -> void:
    create_buttons(6)

#func _ready() -> void:
    #for x in get_child_count():
        #var col = get_child(x)
        #for y in col.get_child_count():
            #var item: Button = col.get_child(y)
#
            #item.pressed.connect(item_pressed.bind(item, x, y))


func item_pressed(item: Button, x: int, y: int):
    if item.text.is_empty():
        item.text = "-1"
    var new_val = (int(item.text) + 2) % (enemies.enemies.size() + 1)
    new_val -= 1

    if new_val == -1:
        item.text = ""
        item.icon = null
    else:
        item.text = str(new_val)
        item.icon = enemies.enemies[new_val].icon

    updated_enemies.emit(x, y, new_val)

#func update_buttons(new_enemies: Array):
    #for x in %HeightButtons.get_child_count():
        #var col = %HeightButtons.get_child(x)
        #for y in col.get_child_count():
            #var item: Button = col.get_child(y)
#
            #item.text = str(heights[x][y])

func update_buttons(new_enemies: Array):
    for x in %EnemyButtons.get_child_count():
        var col = %EnemyButtons.get_child(x)
        for y in col.get_child_count():
            var item: Button = col.get_child(y)
            var val = new_enemies[x][y]

            if val != -1:
                item.text = str(val)
                item.icon = enemies.enemies[val].icon
            else:
                item.text = ""
                item.icon = null

            #item.text = str(heights[x][y])
