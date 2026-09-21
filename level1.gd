extends Node2D

func _ready():
    setup_inputs()
    build_tiles()

func setup_inputs():
    var keys = {"move_left": KEY_A, "move_right": KEY_D, "move_up": KEY_W, "move_down": KEY_S, "shoot": KEY_SPACE}
    for action in keys:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
            var event := InputEventKey.new()
            event.physical_keycode = keys[action]
            InputMap.action_add_event(action, event)

func build_tiles():
    for y in range(17):
        for x in range(30):
            $TileMap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
    for x in range(30):
        $TileMap.set_cell(0, Vector2i(x, 0), 0, Vector2i(1, 0))
        $TileMap.set_cell(0, Vector2i(x, 16), 0, Vector2i(1, 0))
    for y in range(17):
        $TileMap.set_cell(0, Vector2i(0, y), 0, Vector2i(1, 0))
        $TileMap.set_cell(0, Vector2i(29, y), 0, Vector2i(1, 0))
