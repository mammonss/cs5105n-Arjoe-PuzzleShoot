extends Node2D

const PLAYER_SCENE = preload("res://scenes/player.tscn")
const ENEMY_SCENE = preload("res://scenes/enemy.tscn")
const TILE_SIZE := 32
const SAVE_PATH := "user://puzzle_shoot_save.json"

var player: CharacterBody2D
var current_level := 1
var score := 0
var health := 3
var menu_layer: CanvasLayer
var hud_layer: CanvasLayer
var status_label: Label
var score_label: Label
var health_label: Label
var level_label: Label
var message_label: Label
var camera: Camera2D
var hit_sound: AudioStreamPlayer
var game_started := false
var big_text := false
var playtest_note := "Playtest pending: ask a classmate to play for five minutes and record one change."

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("game_manager")
	_setup_audio()
	_show_main_menu()

func _setup_audio() -> void:
	hit_sound = AudioStreamPlayer.new()
	hit_sound.bus = "SFX"
	hit_sound.stream = load("res://assets/hit.wav")
	add_child(hit_sound)

func _show_main_menu() -> void:
	game_started = false
	if is_instance_valid(menu_layer):
		menu_layer.queue_free()
	menu_layer = CanvasLayer.new()
	menu_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(menu_layer)
	var panel := ColorRect.new()
	panel.color = Color(0.035, 0.065, 0.11, 0.96)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_layer.add_child(panel)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.position = Vector2(-190, -170)
	box.size = Vector2(380, 340)
	box.add_theme_constant_override("separation", 14)
	menu_layer.add_child(box)
	var title := Label.new()
	title.text = "PUZZLESHOOT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36 if big_text else 30)
	title.add_theme_color_override("font_color", Color(0.35, 0.9, 0.82))
	box.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Aim, solve, and reach the goal"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(subtitle)
	_add_menu_button(box, "Start Game", _start_new_game)
	_add_menu_button(box, "Continue", _continue_game)
	_add_menu_button(box, "Text Size: " + ("Large" if big_text else "Normal"), _toggle_text_size)
	_add_menu_button(box, "Quit", _quit_game)
	var tip := Label.new()
	tip.text = "WASD: Move   Space: Shoot   P: Pause"
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.add_theme_font_size_override("font_size", 16 if big_text else 12)
	box.add_child(tip)

func _add_menu_button(parent: VBoxContainer, text_value: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(300, 42)
	button.add_theme_font_size_override("font_size", 20 if big_text else 16)
	button.pressed.connect(action)
	parent.add_child(button)

func _toggle_text_size() -> void:
	big_text = not big_text
	_show_main_menu()

func _quit_game() -> void:
	get_tree().quit()

func _start_new_game() -> void:
	score = 0
	health = 3
	current_level = 1
	_begin_game()

func _continue_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_show_main_menu()
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if data is Dictionary:
		score = int(data.get("score", 0))
		health = int(data.get("health", 3))
		current_level = clampi(int(data.get("level", 1)), 1, 2)
	_begin_game()

func _begin_game() -> void:
	if is_instance_valid(menu_layer):
		menu_layer.queue_free()
	if is_instance_valid(hud_layer):
		hud_layer.queue_free()
	for child in get_children():
		if child != hit_sound:
			child.queue_free()
	await get_tree().process_frame
	game_started = true
	_build_level(current_level)
	_build_hud()
	_update_hud()

func _build_level(level_num: int) -> void:
	var world := Node2D.new()
	world.name = "World"
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world)
	_build_tilemap(world, level_num)
	player = PLAYER_SCENE.instantiate()
	player.position = Vector2(90, 300)
	player.score_requested.connect(add_score)
	player.damaged.connect(_on_player_damaged)
	world.add_child(player)
	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	player.add_child(camera)
	camera.position = Vector2.ZERO
	_create_target(world, Vector2(330, 220))
	_create_target(world, Vector2(500, 390))
	if level_num == 2:
		_create_target(world, Vector2(650, 230))
	_create_hazard(world, Vector2(270, 340))
	_create_hazard(world, Vector2(430, 270))
	if level_num == 2:
		_create_hazard(world, Vector2(580, 350))
		_create_enemy(world, Vector2(600, 420))
		_create_enemy(world, Vector2(740, 200))
	else:
		_create_enemy(world, Vector2(640, 420))
	_create_goal(world, Vector2(850, 300))

func _build_tilemap(world: Node2D, level_num: int) -> void:
	var layer := TileMapLayer.new()
	layer.name = "LevelTileMap"
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = load("res://assets/tiles.png")
	atlas.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	atlas.create_tile(Vector2i(0, 0))
	atlas.create_tile(Vector2i(1, 0))
	tile_set.add_source(atlas, 0)
	layer.tile_set = tile_set
	for x in range(30):
		for y in range(19):
			var border := x == 0 or y == 0 or x == 29 or y == 18
			var blocked := false
			if level_num == 1:
				blocked = (x == 11 and y > 4 and y < 14) or (x == 17 and y > 1 and y < 9)
			else:
				blocked = (x == 9 and y > 2 and y < 15) or (x == 15 and y > 4 and y < 17) or (x == 22 and y > 1 and y < 10)
			if border or blocked:
				layer.set_cell(Vector2i(x, y), 0, Vector2i(1, 0))
				if blocked and not border:
					_create_wall(world, Vector2(x * TILE_SIZE + 16, y * TILE_SIZE + 16), Vector2(TILE_SIZE, TILE_SIZE))
			else:
				layer.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	world.add_child(layer)
	# Static collision walls are built separately so the TileMap remains a visual grid.
	for x in range(30):
		_create_wall(world, Vector2(x * TILE_SIZE + 16, 16), Vector2(32, 32))
		_create_wall(world, Vector2(x * TILE_SIZE + 16, 18 * TILE_SIZE + 16), Vector2(32, 32))
	for y in range(1, 18):
		_create_wall(world, Vector2(16, y * TILE_SIZE + 16), Vector2(32, 32))
		_create_wall(world, Vector2(29 * TILE_SIZE + 16, y * TILE_SIZE + 16), Vector2(32, 32))

func _create_wall(parent: Node2D, pos: Vector2, size_value: Vector2) -> void:
	var wall := StaticBody2D.new()
	wall.position = pos
	wall.collision_layer = 2
	wall.collision_mask = 1
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size_value
	shape.shape = rect
	wall.add_child(shape)
	parent.add_child(wall)

func _create_target(parent: Node2D, pos: Vector2) -> void:
	var target := StaticBody2D.new()
	target.name = "Target"
	target.position = pos
	target.collision_layer = 2
	target.collision_mask = 4
	target.add_to_group("target")
	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([
	Vector2(-13, -13),
	Vector2(13, -13),
	Vector2(13, 13),
	Vector2(-13, 13)
])
	visual.color = Color(0.98, 0.68, 0.25)
	target.add_child(visual)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(26,26)
	shape.shape = rect
	target.add_child(shape)
	parent.add_child(target)

func _create_hazard(parent: Node2D, pos: Vector2) -> void:
	var hazard := Area2D.new()
	hazard.position = pos
	hazard.collision_layer = 0
	hazard.collision_mask = 1
	hazard.add_to_group("hazard")
	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([
	Vector2(-18, 12),
	Vector2(-9, -12),
	Vector2(0, 12),
	Vector2(9, -12),
	Vector2(18, 12)
])
	visual.color = Color(1.0, 0.25, 0.32)
	hazard.add_child(visual)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(36,24)
	shape.shape = rect
	hazard.add_child(shape)
	hazard.body_entered.connect(_on_hazard_body_entered)
	parent.add_child(hazard)

func _create_enemy(parent: Node2D, pos: Vector2) -> void:
	var enemy := ENEMY_SCENE.instantiate()
	enemy.position = pos
	parent.add_child(enemy)

func _create_goal(parent: Node2D, pos: Vector2) -> void:
	var goal := Area2D.new()
	goal.position = pos
	goal.collision_layer = 0
	goal.collision_mask = 1
	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([
	Vector2(-18, -18),
	Vector2(18, -18),
	Vector2(18, 18),
	Vector2(-18, 18)
])
	visual.color = Color(0.32, 0.95, 0.55)
	goal.add_child(visual)
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 22
	shape.shape = circle
	goal.add_child(shape)
	goal.body_entered.connect(_on_goal_body_entered)
	parent.add_child(goal)

func _build_hud() -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(hud_layer)
	var panel := ColorRect.new()
	panel.color = Color(0.02,0.04,0.08,0.88)
	panel.size = Vector2(960, 48)
	hud_layer.add_child(panel)
	var row := HBoxContainer.new()
	row.position = Vector2(16, 8)
	row.size = Vector2(928, 32)
	row.add_theme_constant_override("separation", 22)
	hud_layer.add_child(row)
	score_label = _hud_label("Score: 0")
	health_label = _hud_label("Health: 3")
	level_label = _hud_label("Level: 1")
	row.add_child(score_label)
	row.add_child(health_label)
	row.add_child(level_label)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	var save_button := Button.new()
	save_button.text = "Save"
	save_button.pressed.connect(_save_game)
	row.add_child(save_button)
	var menu_button := Button.new()
	menu_button.text = "Menu"
	menu_button.pressed.connect(_return_to_menu)
	row.add_child(menu_button)
	message_label = Label.new()
	message_label.position = Vector2(18, 54)
	message_label.add_theme_font_size_override("font_size", 20 if big_text else 15)
	message_label.add_theme_color_override("font_color", Color(0.95,0.92,0.72))
	hud_layer.add_child(message_label)
	status_label = message_label
	message_label.text = "WASD move | Space shoot | P pause | Green goal advances"

func _hud_label(value: String) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", 22 if big_text else 17)
	label.add_theme_color_override("font_color", Color(0.9,0.95,1))
	return label

func _update_hud() -> void:
	if is_instance_valid(score_label):
		score_label.text = "Score: " + str(score)
		health_label.text = "Health: " + str(health)
		level_label.text = "Level: " + str(current_level)

func add_score(points: int) -> void:
	score += points
	_update_hud()

func _on_player_damaged() -> void:
	if not game_started:
		return
	health -= 1
	_update_hud()
	if is_instance_valid(camera):
		var original := camera.offset
		var tween := create_tween()
		for i in range(5):
			tween.tween_property(camera, "offset", Vector2(randf_range(-7,7), randf_range(-5,5)), 0.035)
		tween.tween_property(camera, "offset", original, 0.05)
	hit_sound.play()
	if health <= 0:
		_save_game()
		_show_end_message("Game Over — progress saved")
		get_tree().paused = true

func _on_hazard_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_on_player_damaged()

func _on_goal_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if not get_tree().get_nodes_in_group("target").is_empty():
		if is_instance_valid(status_label):
			status_label.text = "Destroy all yellow blocks before reaching the green goal!"
		return
	if current_level == 1:
		score += 50
		current_level = 2
		_save_game()
		_begin_game()
	else:
		score += 100
		_save_game()
		_show_end_message("You solved PuzzleShoot! Score: " + str(score))

func _show_end_message(text_value: String) -> void:
	if is_instance_valid(hud_layer):
		var overlay := ColorRect.new()
		overlay.color = Color(0.02,0.04,0.08,0.9)
		overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		hud_layer.add_child(overlay)
		var label := Label.new()
		label.text = text_value + "\nPress Menu to return or close the game."
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.add_theme_font_size_override("font_size", 28 if big_text else 22)
		overlay.add_child(label)

func _save_game() -> void:
	var data := {"score": score, "health": health, "level": current_level}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
	if is_instance_valid(status_label):
		status_label.text = "Progress saved. Continue is available from the main menu."

func _return_to_menu() -> void:
	get_tree().paused = false
	for child in get_children():
		if child != hit_sound:
			child.queue_free()
	player = null
	hud_layer = null
	menu_layer = null
	await get_tree().process_frame
	_show_main_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and game_started:
		get_tree().paused = not get_tree().paused
		if is_instance_valid(status_label):
			status_label.text = "Paused — press P to resume" if get_tree().paused else "Resumed"

func _process(_delta: float) -> void:
	# Small fixed-size scene and modest object count keep this prototype lightweight.
	pass
