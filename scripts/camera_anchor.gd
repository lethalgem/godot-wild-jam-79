extends Node3D

# TODO: Lower (actually increase this number) sensitivity when aiming
@export var camera_sensitivity := 100.0

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x / camera_sensitivity
		rotation.x += event.relative.y / camera_sensitivity
		rotation.x = clamp(rotation.x, deg_to_rad(-45), deg_to_rad(90))
