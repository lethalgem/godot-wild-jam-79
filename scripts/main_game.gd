class_name MainGame extends Node3D

@export var start_menu: StartMenu
@export var player: Player3D

@onready var return_to_camera_anchor_rotation := player.camera_anchor.rotation
@onready var return_to_camera_3D_fov := player.camera_3D.fov

var player_paused_game := false

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
				
	show_start_menu()
	
## Ensures that the music is only interrupted when we respawn and not before
func respawn(section: PlatformingSection):
	section.reset_and_respawn()
	$AudioStreamPlayer.play(section.song_start)

func show_start_menu():
	player.camera_anchor.pause_fov_change = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	start_menu.show_menu(player_paused_game)
	
	if player_paused_game:
		var tween = create_tween()
		tween.parallel().tween_property(player.camera_anchor, "rotation", Vector3(-0.4,-3.02,0.0),0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(player.camera_3D, "fov", 35, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		player.camera_anchor.rotation = Vector3(-0.4,-3.02,0.0)
		player.camera_3D.fov = 35
	
func hide_start_menu(): 
	start_menu.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var tween = create_tween()
	tween.parallel().tween_property(player.camera_anchor, "rotation", return_to_camera_anchor_rotation,0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(player.camera_3D, "fov", return_to_camera_3D_fov, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	player.camera_anchor.pause_fov_change = false
	
func _on_start_menu_canvas_start_button_pressed():
	hide_start_menu()

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		player_paused_game = !player_paused_game
		if player_paused_game:
			show_start_menu()
		else:
			hide_start_menu()
	
	
