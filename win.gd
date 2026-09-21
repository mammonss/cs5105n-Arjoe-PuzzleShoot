extends CanvasLayer

func _ready():
    $Panel/VBox/Restart.pressed.connect(_on_restart_pressed)

func _on_restart_pressed():
    get_tree().change_scene_to_file("res://level1.tscn")
