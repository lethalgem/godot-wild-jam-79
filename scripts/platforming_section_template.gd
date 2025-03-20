## This script and scene serves as an _EXAMPLE_. Think env.example. 
## It strives to automate nearly everything about hooking up a new section to the main game.
## It should be duplicated, renamed, and then dropped into the main game scene with the LevelManager.
## This script should not need to be edited, only the scene.
## To create a section, simply drag and drop GrowingPlatform3Ds into the scene and use their parameters in the Inspector.

## The scene is also designed to be edited and tested on it's own without needing the LevelManager for quicker testing.
## Simply run it as the main scene.
class_name PlatformingSectionTemplate extends Node3D

@export var player: Player3D

@onready var checkpoint := $CheckpointRespawn3D

var player_is_in_section := false

func _ready() -> void:
	# Check if this is being used a section in the main game or if this is standalone and we're testing/debugging
	if not get_parent() == get_tree().root:
		assert(player != null, "Player was not assigned to section. If the section is part of the main game, it must have a reference to the player")
		$Player3D.queue_free()
		$WorldEnvironment.queue_free()
		for child in get_children():
			if child is DeathPlane3D:
				child.queue_free()
	else:
		player = $Player3D
		for child in get_children():
			if child is DeathPlane3D:
				child.connect("player_entered", reset_and_respawn)

func reset_and_respawn():
	if player_is_in_section:
		player.global_position = checkpoint.global_position
		for child in get_children():
			if child is GrowingPlatform3D:
				child.reset_position()


func _on_timer_trigger_3d_player_entered() -> void:
	for child in get_children():
		if child is GrowingPlatform3D:
			child.start_timer()


func _on_checkpoint_respawn_3d_player_entered():
	player_is_in_section = true
	

func _input(event):
	if event.is_action_pressed("respawn"):
		reset_and_respawn()
