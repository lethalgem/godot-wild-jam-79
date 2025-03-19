class_name WallHangTest extends Node3D

@onready var player := $Player3D
@onready var current_checkpoint := $CheckpointRespawn3D

func reset_and_respawn():
	player.global_position = current_checkpoint.global_position
	
	
func _input(event):
	if event.is_action_pressed("respawn"):
		reset_and_respawn()


func _on_death_plane_3d_player_entered():
	reset_and_respawn()
