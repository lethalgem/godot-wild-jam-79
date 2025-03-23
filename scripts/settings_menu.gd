class_name SettingsMenu extends Control
	
@onready var dim_rect = $"../PanelContainer"
@export var start_menu : Control
	
func _on_settings_pressed():
	toggle_menu()
	$MarginContainer/GridContainer/HBoxContainer/ButtonSound.play()
	
func toggle_menu():
	self.visible = true
	dim_rect.visible = true
	start_menu.hide()

func _on_go_back_pressed():
	dim_rect.visible = false
	self.visible = false
	start_menu.show()
	$MarginContainer/GridContainer/HBoxContainer/ButtonSound.play()

func dismiss_menu():
	dim_rect.visible = false
	self.visible = false
	start_menu.show()
