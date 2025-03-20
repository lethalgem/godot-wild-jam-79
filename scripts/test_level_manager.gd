class_name TestLevelMananger extends Node3D

@onready var player := $Player3D
@onready var growing_platform := $GrowingPlatform3D
@onready var growing_platform_2 := $GrowingPlatform3D2
@onready var growing_platform_3 := $GrowingPlatform3D3

func reset_and_respawn():
	growing_platform.reset_position()
	growing_platform_2.reset_position()
	growing_platform_3.reset_position()


func _on_timer_trigger_3d_player_entered() -> void:
	growing_platform.start_timer()
	growing_platform_2.start_timer()
	growing_platform_3.start_timer()
	
	
func _input(event):
	if event.is_action_pressed("respawn"):
		reset_and_respawn()


func _on_death_plane_3d_player_entered():
	reset_and_respawn()
