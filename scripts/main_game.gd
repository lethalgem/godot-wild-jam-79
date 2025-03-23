class_name MainGame extends Node3D

@export var start_menu: StartMenu
@export var player: Player3D
@export var world_environment: WorldEnvironment

@onready var return_to_camera_anchor_rotation := player.camera_anchor.rotation
@onready var return_to_camera_3D_fov := player.camera_3D.fov

@export var in_menu_camera_anchor_rotation := Vector3(-0.4,-3.02,0.0)
@export var in_menu_camera_3D_fov := 35
@export var menu_animation_time := 0.5
@export var start_at_section := 1
@export var color_1: Color
@export var color_2: Color
@onready var all_sections : Array[PlatformingSection] = []

var player_paused_game := false
var death_count := 0
var blend_to_color_1 = false
var time_between_beats = 0.375 # seconds
var time_to_first_beat = 1.25 # seconds

func _ready() -> void:
	# Listen to all sections to know when the player has entered
	for possible_child_section in get_children():
		if possible_child_section is PlatformingSection:
			all_sections.append(possible_child_section)
			possible_child_section.connect("player_entered_section", func(section):
				# Reset all death planes to go to this checkpoint
				for possible_death_plane_child in get_children():
					if possible_death_plane_child is DeathPlane3D:
						if possible_death_plane_child.is_connected("player_entered", respawn):
							possible_death_plane_child.disconnect("player_entered", respawn)
						possible_death_plane_child.connect("player_entered", respawn.bind(section))
				)

	#show_start_menu()
	hide_start_menu()
	
	jump_to_section(start_at_section)
	
	get_tree().create_timer(time_to_first_beat).connect("timeout", tween_to_color_2)

func tween_to_color_1():
	var tween = create_tween()
	tween.tween_property(world_environment, "environment:ambient_light_color", color_2, time_between_beats)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.finished.connect(tween_to_color_2)

func tween_to_color_2():
	var tween = create_tween()
	tween.tween_property(world_environment, "environment:ambient_light_color", color_1, time_between_beats)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.finished.connect(tween_to_color_1)

## sections start from 1, not 0
func jump_to_section(num: int):
	assert(len(all_sections) >= num - 1, "num exceeds the length of section collection")
	assert(num >= 1, "num starts from 1 not 0, please make any correction needed")
	respawn(all_sections[num - 1])

## Ensures that the music is only interrupted when we respawn and not before
func respawn(section: PlatformingSection):
	section.reset_and_respawn()
	$AudioStreamPlayer.play(section.song_start)
	death_count += 1
	start_menu.update_death_count(death_count)

func show_start_menu():
	player.camera_anchor.pause_fov_change = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	start_menu.show_menu(player_paused_game)
	
	if player_paused_game:
		var tween = create_tween()
		tween.parallel().tween_property(player.camera_anchor, "rotation", in_menu_camera_anchor_rotation, menu_animation_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(player.camera_3D, "fov", in_menu_camera_3D_fov, menu_animation_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		player.camera_anchor.rotation = in_menu_camera_anchor_rotation
		player.camera_3D.fov = in_menu_camera_3D_fov
	
func hide_start_menu(): 
	start_menu.dismiss_menu()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var tween = create_tween()
	tween.parallel().tween_property(player.camera_anchor, "rotation", return_to_camera_anchor_rotation, menu_animation_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(player.camera_3D, "fov", return_to_camera_3D_fov, menu_animation_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

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

func _on_start_menu_canvas_checkpoint_selected(num: int) -> void:
	jump_to_section(num)
