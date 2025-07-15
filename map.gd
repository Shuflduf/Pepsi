class_name Map
extends NavigationRegion3D

const OFFSET = -10
const MULT = 2

func set_state(state: MapState):
    for x in state.heights.size():
        var col = state.heights[x]
        for y in col.size():
            var value = col[y]
            prints(Vector2i(x, y), value)
            %Parts.get_child(x).get_child(y).position.y = (value * MULT) + OFFSET
