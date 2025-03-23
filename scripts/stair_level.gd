class_name StairLevel extends PlatformingSection

signal end_game_reached

@export var end_game_screen: EndGameScreen

func _on_checkpoint_circular_3d_player_entered():
	end_game_screen.show_end_game_screen()
	end_game_reached.emit(end_game_screen)
