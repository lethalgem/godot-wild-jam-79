class_name HowToPlayMenu extends Control

signal checkpoint_selected

@onready var dim_rect = $"../PanelContainer"
@export var start_menu : Control
	
func toggle_menu():
	self.visible = true
	start_menu.hide()

func _on_how_to_play_pressed():
	toggle_menu()

func _on_back_button_pressed():
	self.visible = false
	start_menu.show()
	$PanelContainer/ButtonSound.play()
	
func dismiss_menu():
	self.visible = false
	start_menu.show()
