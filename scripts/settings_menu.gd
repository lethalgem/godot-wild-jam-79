class_name SettingsMenu extends Control
	
@onready var dim_rect = $"../ColorRect"
	
func _on_settings_pressed():
	toggle_menu()
	
func toggle_menu():
	self.visible = true
	dim_rect.visible = true

func _on_back_pressed():
	dim_rect.visible = false
	self.visible = false
