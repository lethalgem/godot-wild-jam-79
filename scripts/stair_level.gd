class_name StairLevel extends PlatformingSection

signal end_game_reached

# TODO: Add Colision box (Area for End Game) 
# CheckPiont3D will work here

@export var end_game_screen : EndGameScreen

func _on_checkpoint_circular_3d_player_entered():
	end_game_screen.show_end_game_screen()
	end_game_reached.emit()
