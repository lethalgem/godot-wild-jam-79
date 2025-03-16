extends Node3D

# TODO: Make the camera lag behind the player slightly, it'll make all the movement feel way juicier
# TODO: Have the camera not move up too much with the player when jumping, they want to be able to see where they're landing

@export var camera_sensitivity := 100.0

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x / camera_sensitivity
		rotation.x += event.relative.y / camera_sensitivity
		rotation.x = clamp(rotation.x, deg_to_rad(-45), deg_to_rad(90))
