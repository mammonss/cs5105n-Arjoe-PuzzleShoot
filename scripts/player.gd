extends CharacterBody2D

signal score_requested(points: int)
signal damaged

@export var speed: float = 230.0
@export var projectile_scene: PackedScene = preload("res://scenes/projectile.tscn")
var shoot_cooldown := 0.0
var invulnerable := 0.0
var last_direction := Vector2.RIGHT
var audio_player: AudioStreamPlayer
var shoot_sound: AudioStream

func _ready() -> void:
	add_to_group("player")
	shoot_sound = load("res://assets/shoot.wav")
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "SFX"
	add_child(audio_player)
	_setup_animations()

func _physics_process(delta: float) -> void:
	shoot_cooldown = maxf(0.0, shoot_cooldown - delta)
	invulnerable = maxf(0.0, invulnerable - delta)
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length() > 0.05:
		last_direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()
	var animation_player: AnimationPlayer = get_node("AnimationPlayer")
	var anim := "move" if direction.length() > 0.05 else "idle"
	if animation_player.has_animation(anim) and animation_player.current_animation != anim:
		animation_player.play(anim)
	if Input.is_action_pressed("shoot") and shoot_cooldown <= 0.0:
		_shoot()
	if invulnerable <= 0.0:
		for i in get_slide_collision_count():
			var collision := get_slide_collision(i)
			if collision.get_collider().is_in_group("enemy"):
				damaged.emit()
				invulnerable = 1.0
				break

func _shoot() -> void:
	shoot_cooldown = 0.24
	var projectile := projectile_scene.instantiate()
	projectile.direction = last_direction
	projectile.global_position = global_position + last_direction * 22.0
	get_parent().add_child(projectile)
	if audio_player:
		audio_player.stream = shoot_sound
		audio_player.play()
	get_node("Particles").restart()
	get_node("Particles").emitting = true

func _setup_animations() -> void:
	var ap: AnimationPlayer = get_node("AnimationPlayer")
	var idle := Animation.new()
	var library := AnimationLibrary.new()
	idle.length = 0.8
	var track := idle.add_track(Animation.TYPE_VALUE)
	idle.track_set_path(track, NodePath("Body:scale"))
	idle.track_insert_key(track, 0.0, Vector2.ONE)
	idle.track_insert_key(track, 0.4, Vector2(1.04, 0.96))
	idle.track_insert_key(track, 0.8, Vector2.ONE)
	idle.loop_mode = Animation.LOOP_LINEAR
	library.add_animation("idle", idle)
	var move := Animation.new()
	move.length = 0.24
	var mt := move.add_track(Animation.TYPE_VALUE)
	move.track_set_path(mt, NodePath("Body:scale"))
	move.track_insert_key(mt, 0.0, Vector2(1.0, 1.0))
	move.track_insert_key(mt, 0.12, Vector2(1.12, 0.9))
	move.track_insert_key(mt, 0.24, Vector2(1.0, 1.0))
	move.loop_mode = Animation.LOOP_LINEAR
	library.add_animation("move", move)
	ap.add_animation_library("", library)
	ap.play("idle")
