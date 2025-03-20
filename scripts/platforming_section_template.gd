## This script and scene serves as an _EXAMPLE_. Think env.example. 
## It strives to automate nearly everything about hooking up a new section to the main game.
## It should be duplicated, renamed, and then dropped into the main game scene with the MainGame.
## This script should not need to be edited, only the scene.
## To create a section, simply drag and drop GrowingPlatform3Ds into the scene and use their parameters in the Inspector.
## Then assign the player to MainGame and Hook up the player_entered_section signal

## The scene is also designed to be edited and tested on it's own without needing the MainGame for quicker testing.
## Simply run it as the main scene.
## DeathPlanes in this scene are for testing purposes only. All main game DeathPlanes should be placed in MainGame.
class_name PlatformingSection extends Node3D

signal player_entered_section

@export var player: Player3D

@onready var checkpoint := %CheckpointRespawn3D

func _ready() -> void:
	# Check if this is being used a section in the main game or if this is standalone and we're testing/debugging
	if not get_parent() == get_tree().root:
		assert(player != null, "Player was not assigned to section. If the section is part of the main game, it must have a reference to the player")
		%SectionWorldEnvironment.queue_free()
		for child in get_children():
			if child is DeathPlane3D:
				child.queue_free()
	else:
		# We're testing as a standalone, let's spawn a player
		var player_scene = preload("res://scenes/player_3d.tscn")
		var player_instance = player_scene.instantiate()
		add_child(player_instance)
		player = player_instance
		
		# Let's use the debug death planes to respawn
		for child in get_children():
			if child is DeathPlane3D:
				child.connect("player_entered", reset_and_respawn)

func reset_and_respawn():
	player.global_position = checkpoint.global_position
	for child in get_children():
		if child is GrowingPlatform3D:
			child.reset_position()


func _on_timer_trigger_3d_player_entered() -> void:
	for child in get_children():
		if child is GrowingPlatform3D:
			child.start_timer()


func _on_checkpoint_respawn_3d_player_entered():
	player_entered_section.emit(self)
