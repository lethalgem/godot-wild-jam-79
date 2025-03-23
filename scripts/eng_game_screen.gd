class_name EndGameScreen extends Control


@export var button_sound: AudioStreamPlayer
@export var death_count_label: Label

func show_end_game_screen():
	self.show()
		
func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func set_death_count(count:int):
	death_count_label.text = "Fall Count: " + str(count)
