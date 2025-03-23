class_name SettingsMenu extends Control
	
@export var start_menu : Control
@export var button_sound_player : AudioStreamPlayer
@export var fullscreen_button : Button

@onready var dim_rect = $"../PanelContainer"

var is_fullscreen := false

func _on_settings_pressed():
	toggle_menu()
	button_sound_player.play()
	
func toggle_menu():
	self.visible = true
	dim_rect.visible = true
	start_menu.hide()

func _on_go_back_button_up() -> void:
	dim_rect.visible = false
	self.visible = false
	start_menu.show()
	button_sound_player.play()

func dismiss_menu():
	dim_rect.visible = false
	self.visible = false
	start_menu.show()

func _on_fullscreen_toggle_button_up() -> void:
	is_fullscreen = !is_fullscreen
	
	if is_fullscreen:
		fullscreen_button.text = "Windowed"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		fullscreen_button.text = "Fullscreen"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	button_sound_player.play()
