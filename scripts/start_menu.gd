class_name StartMenu extends CanvasLayer

signal start_button_pressed

func _on_start_game_pressed():
	start_button_pressed.emit()
