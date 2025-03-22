class_name SelectLevelMenu extends Control

@onready var dim_rect = $"../PanelContainer"
@export var start_menu : Control
	
func toggle_menu():
	self.visible = true
	dim_rect.visible = true
	start_menu.hide()

func _on_go_back_pressed():
	dim_rect.visible = false
	self.visible = false
	start_menu.show()


func _on_select_checkpoint_pressed():
	toggle_menu()
