# TODO: add spring arm
# TODO: zoom out more when looking down, and zoom in when looking up
class_name CameraAnchor extends Node3D

@export var player: Player3D
## How fast the camera rotates when moved by the player.
## Lower value makes rotations faster.
@export_range (100,1000, 1) var camera_rotation_sensitivity := 100.0
## How fast the camera follows the player, lower values result in a higher amount of lag
@export var lag_factor := 5.0

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x / camera_rotation_sensitivity
		rotation.x += event.relative.y / camera_rotation_sensitivity
		rotation.x = clamp(rotation.x, deg_to_rad(-45), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Lag camera behind the player
	global_position = lerp(global_position, player.global_position, delta * lag_factor)
