extends CharacterBody2D

@export var speed := 220.0
@export var projectile_scene: PackedScene

func _physics_process(_delta):
    var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = direction * speed
    move_and_slide()
    global_position.x = clamp(global_position.x, 24.0, 936.0)
    global_position.y = clamp(global_position.y, 24.0, 516.0)
    if Input.is_action_just_pressed("shoot") and projectile_scene:
        shoot()

func shoot():
    var projectile = projectile_scene.instantiate()
    projectile.global_position = global_position + Vector2(28, 0)
    get_tree().current_scene.add_child(projectile)
