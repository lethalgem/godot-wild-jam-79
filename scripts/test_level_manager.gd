class_name TestLevelMananger extends Node3D

@onready var player := $Player3D
@onready var checkpoint := $CheckpointRespawn3D
@onready var current_checkpoint := checkpoint


func _on_checkpoint_respawn_3d_player_entered(checkpoint:CheckpointRespawn3D):
	current_checkpoint = checkpoint
	
func _input(event):
	if event.is_action_pressed("respawn"):
		player.global_position = current_checkpoint.global_position
