extends Node3D

@export var capture_mouse_mode := true: set = set_capture_mouse_mode

func set_capture_mouse_mode(new_mode: bool):
	if new_mode:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	capture_mouse_mode = new_mode

func _ready() -> void:
	set_capture_mouse_mode(capture_mouse_mode)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("change_mouse_mode"):
		set_capture_mouse_mode(!capture_mouse_mode)
