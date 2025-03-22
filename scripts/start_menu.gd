class_name StartMenu extends CanvasLayer

signal start_button_pressed

@export var start_button: Button

@onready var original_start_button_text := start_button.text

func show_menu(is_player_pause: bool):
	show()
	
	if is_player_pause:
		start_button.text = "Resume Game"
	else:
		start_button.text = original_start_button_text

func _on_start_game_pressed():
	start_button_pressed.emit()
