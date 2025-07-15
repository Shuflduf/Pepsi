class_name Map
extends NavigationRegion3D

const OFFSET = -10
const MULT = 2

func set_wave(wave: Wave):
    for x in wave.heights.size():
        var col = wave.heights[x]
        for y in col.size():
            var value = col[y]
            %Parts.get_child(x).get_child(y).position.y = (value * MULT) + OFFSET

func get_wave() -> Wave:
    var new_wave = Wave.new()
    for x in %Parts.get_child_count():
        var col = %Parts.get_child(x)
        for y in col.get_child_count():
            var part = col.get_child(y)
            new_wave.heights[x][y] = (part.position.y - OFFSET) / MULT

    return new_wave
