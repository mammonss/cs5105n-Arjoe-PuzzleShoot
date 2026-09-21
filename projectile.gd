extends Area2D

@export var speed := 520.0
var lifetime := 2.0

func _process(delta):
    position.x += speed * delta
    lifetime -= delta
    if lifetime <= 0.0:
        queue_free()

func _on_body_entered(body):
    if body.is_in_group("targets"):
        body.queue_free()
        queue_free()
