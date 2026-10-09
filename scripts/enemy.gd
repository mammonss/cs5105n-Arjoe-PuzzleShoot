extends CharacterBody2D

enum State { PATROL, CHASE, ATTACK }
@export var patrol_speed := 65.0
@export var chase_speed := 90.0
@export var detection_range := 230.0
@export var attack_range := 30.0
var state: State = State.PATROL
var player: Node2D
var home_position := Vector2.ZERO
var patrol_direction := 1.0
var health := 2
var attack_cooldown := 0.0

func _ready() -> void:
	add_to_group("enemy")
	home_position = global_position
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return
	var distance := global_position.distance_to(player.global_position)
	if distance <= attack_range:
		state = State.ATTACK
	elif distance <= detection_range:
		state = State.CHASE
	else:
		state = State.PATROL
	match state:
		State.PATROL:
			if absf(global_position.x - home_position.x) > 75.0:
				patrol_direction *= -1.0
			velocity = Vector2(patrol_direction * patrol_speed, 0)
		State.CHASE:
			velocity = global_position.direction_to(player.global_position) * chase_speed
		State.ATTACK:
			velocity = Vector2.ZERO
			if attack_cooldown <= 0.0:
				attack_cooldown = 1.0
				player.damaged.emit()
	move_and_slide()

func take_hit() -> void:
	health -= 1
	modulate = Color(1.0, 0.7, 0.7)
	if health <= 0:
		get_tree().call_group("game_manager", "add_score", 25)
		queue_free()
	else:
		await get_tree().create_timer(0.12).timeout
		if is_instance_valid(self):
			modulate = Color.WHITE
