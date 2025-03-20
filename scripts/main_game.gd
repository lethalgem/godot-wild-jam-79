class_name MainGame extends Node3D

func _ready() -> void:
	# Listen to all sections to know when the player has entered
	for possible_child_section in get_children():
		if possible_child_section is PlatformingSection:
			possible_child_section.connect("player_entered_section", func(section):
				# Reset all death planes to go to this checkpoint
				for possible_death_plane_child in get_children():
					if possible_death_plane_child is DeathPlane3D:
						if possible_death_plane_child.is_connected("player_entered", respawn):
							possible_death_plane_child.disconnect("player_entered", respawn)
						possible_death_plane_child.connect("player_entered", respawn.bind(section))
				)

## Ensures that the music is only interrupted when we respawn and not before
func respawn(section: PlatformingSection):
	section.reset_and_respawn()
	$AudioStreamPlayer.play(section.song_start)
