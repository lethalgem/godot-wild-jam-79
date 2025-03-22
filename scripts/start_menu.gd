class_name StartMenu extends CanvasLayer

signal start_button_pressed

@export var start_button: Button
@export var death_count_label: Label
@export var setting_menu: Control
@export var select_level_menu: Control


@onready var original_start_button_text := start_button.text

func show_menu(is_player_pause: bool):
	show()
	
	if is_player_pause:
		start_button.text = "Resume Game"
	else:
		start_button.text = original_start_button_text

func _on_start_game_pressed():
	start_button_pressed.emit()

func _ready():
	death_count_label.text = "Death Counter: 0"

func update_death_count(count:int):
	death_count_label.text = "Death Counter: "  + str(count)
	
func dismiss_menu():
	hide()
	setting_menu._on_go_back_pressed()
	select_level_menu._on_go_back_pressed()
	
