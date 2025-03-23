class_name StartMenu extends CanvasLayer

signal start_button_pressed
signal checkpoint_selected

@export var start_button: Button
@export var death_count_label: Label
@export var setting_menu: SettingsMenu
@export var select_level_menu: SelectLevelMenu
@export var how_to_play_menu: HowToPlayMenu
@export var button_sound_player: AudioStreamPlayer

@onready var original_start_button_text := start_button.text

func show_menu(is_player_pause: bool):
	show()
	
	if is_player_pause:
		start_button.text = "Resume Game"
	else:
		start_button.text = original_start_button_text

func _on_start_game_pressed():
	button_sound_player.play()
	start_button_pressed.emit()

func _ready():
	death_count_label.text = "Death Count: 0"

func update_death_count(count:int):
	death_count_label.text = "Death Count: "  + str(count)
	
func dismiss_menu():
	hide()
	setting_menu.dismiss_menu()
	select_level_menu.dismiss_menu()
	how_to_play_menu.dismiss_menu()
	

func _on_select_level_menu_checkpoint_selected(num: int) -> void:
	checkpoint_selected.emit(num)
