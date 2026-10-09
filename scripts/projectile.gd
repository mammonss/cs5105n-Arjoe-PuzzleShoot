extends Area2D

@export var speed: float = 500.0
var direction: Vector2 = Vector2.RIGHT
var life := 2.0

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
    global_position += direction.normalized() * speed * delta
    life -= delta
    if life <= 0.0:
        queue_free()

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("target") or body.is_in_group("enemy"):
        if body.is_in_group("enemy"):
            body.take_hit()
        else:
            get_tree().call_group("game_manager", "add_score", 10)
            body.queue_free()
        queue_free()

func _on_area_entered(area: Area2D) -> void:
    if area.is_in_group("target"):
        area.queue_free()
        queue_free()
