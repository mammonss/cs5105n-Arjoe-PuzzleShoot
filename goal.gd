extends Area2D

@export_file("*.tscn") var next_level := ""

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body):
    if body is CharacterBody2D and next_level != "":
        get_tree().change_scene_to_file(next_level)
