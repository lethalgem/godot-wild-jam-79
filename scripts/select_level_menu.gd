class_name SelectLevelMenu extends Control

signal checkpoint_selected

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
	$"../../StartMenu/MarginContainer/ButtonSound".play()


func _on_select_checkpoint_pressed():
	toggle_menu()
	$"../../StartMenu/MarginContainer/ButtonSound".play()
	
func dismiss_menu():
	dim_rect.visible = false
	self.visible = false
	start_menu.show()


func _on_checkpoint_one_button_up() -> void:
	checkpoint_selected.emit(1)


func _on_checkpoint_two_button_up() -> void:
	checkpoint_selected.emit(2)


func _on_checkpoint_three_button_up() -> void:
	checkpoint_selected.emit(3)


func _on_checkpoint_four_button_up() -> void:
	checkpoint_selected.emit(4)


func _on_checkpoint_five_button_up() -> void:
	checkpoint_selected.emit(5)
