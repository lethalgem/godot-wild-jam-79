extends Control

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")
