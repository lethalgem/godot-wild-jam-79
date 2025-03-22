class_name CameraAnchor extends Node3D

@export var player: Player3D
## How fast the camera rotates when moved by the player.
## Lower value makes rotations faster.
@export_range (100,1000, 1) var camera_rotation_sensitivity := 100.0
## How fast the camera follows the player, lower values result in a higher amount of lag
@export var lag_factor := 5.0
## How aggressively the camera's fov changes when looking down or up on the player
@export var fov_factor := 30.0

@onready var camera_3D: Camera3D = %Camera3D
@onready var last_rotation_x := rotation.x

var pause_fov_change := false

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		# Rotate anchor to follow mouse
		rotation.y -= event.relative.x / camera_rotation_sensitivity
		rotation.x += event.relative.y / camera_rotation_sensitivity
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	# Lag camera behind the player
	global_position = lerp(global_position, player.global_position, delta * lag_factor)
	
	
	if last_rotation_x != rotation.x and not pause_fov_change:
		# zoom out when looking down on the player, zoom in when looking up
		var rotation_delta = rotation.x - last_rotation_x
		camera_3D.fov += rotation_delta * fov_factor
		last_rotation_x = rotation.x
