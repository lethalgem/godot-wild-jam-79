class_name SelectLevelMenu extends Control

signal checkpoint_selected

@onready var dim_rect = $"../PanelContainer"
@export var start_menu : Control
@export var button_sound_player : AudioStreamPlayer
	
func toggle_menu():
	self.visible = true
	dim_rect.visible = true
	start_menu.hide()


func _on_go_back_pressed():
	dim_rect.visible = false
	self.visible = false
	start_menu.show()
	button_sound_player.play()


func _on_select_checkpoint_pressed():
	toggle_menu()
	button_sound_player.play()


func dismiss_menu():
	dim_rect.visible = false
	self.visible = false
	start_menu.show()


func _on_checkpoint_one_button_up() -> void:
	checkpoint_selected.emit(1)
	button_sound_player.play()


func _on_checkpoint_two_button_up() -> void:
	checkpoint_selected.emit(2)
	button_sound_player.play()


func _on_checkpoint_three_button_up() -> void:
	checkpoint_selected.emit(3)
	button_sound_player.play()


func _on_checkpoint_four_button_up() -> void:
	checkpoint_selected.emit(4)
	button_sound_player.play()


func _on_checkpoint_five_button_up() -> void:
	checkpoint_selected.emit(5)
	button_sound_player.play()
	
	
func _on_checkpoint_six_button_up() -> void:
	checkpoint_selected.emit(6)
	button_sound_player.play()
	
	
func _on_checkpoint_seven_button_up() -> void:
	checkpoint_selected.emit(7)
	button_sound_player.play()

func _on_checkpoint_eight_button_up() -> void:
	checkpoint_selected.emit(8)
	button_sound_player.play()
