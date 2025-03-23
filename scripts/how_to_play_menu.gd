class_name HowToPlayMenu extends Control

@export var start_menu : Control
@export var button_sound_player : AudioStreamPlayer
	
func toggle_menu():
	self.visible = true
	start_menu.hide()

func _on_how_to_play_pressed():
	toggle_menu()
	button_sound_player.play()

func _on_back_button_pressed():
	self.visible = false
	start_menu.show()
	button_sound_player.play()
	
func dismiss_menu():
	self.visible = false
	start_menu.show()
