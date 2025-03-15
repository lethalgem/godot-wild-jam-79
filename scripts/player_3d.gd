class_name Player3D extends CharacterBody3D

## Controls how quickly the player accelerates and turns on the ground.
@export_range(1.0, 50.0, 0.1) var steering_factor := 20.0

@export_group("State WALKING")
## The maximum speed the player can move at in meters per second.
@export_range(3.0, 12.0, 0.1) var max_speed := 6.0

@export_group("State JUMPING")
@export_range(3.0, 12.0, 0.1) var max_air_control_speed := 6.0
@export_range(1.0, 30.0, 0.1) var jump_velocity := 20.0
@export_range(1, 179, 1) var camera_fov_jumping:= 40
@export_range(0.001, 1, 0.01) var camera_zoom_time_jumping := 0.25

@onready var skin: SophiaSkin3D = %SophiaSkin
@onready var camera_anchor: Node3D = %CameraAnchor
@onready var camera_3D: Camera3D = %Camera3D
@onready var debug_state_label = %DebugStateLabel3D

func _ready() -> void:
	var state_machine := PlayerStateMachine.StateMachine.new()
	add_child(state_machine)

	var idle := PlayerStateMachine.StateIdle.new(self)

	var walk := PlayerStateMachine.StateWalk.new(self)
	walk.max_speed = max_speed

	var jump := PlayerStateMachine.StateJump.new(self)
	jump.max_speed = max_air_control_speed
	jump.jump_velocity = jump_velocity
	jump.camera_fov = camera_fov_jumping
	jump.camera_zoom_time = camera_zoom_time_jumping

	state_machine.transitions = {
		idle: {
			PlayerStateMachine.Events.PLAYER_STARTED_MOVING: walk,
			PlayerStateMachine.Events.PLAYER_JUMPED: jump,
		},
		walk: {
			PlayerStateMachine.Events.PLAYER_STOPPED_MOVING: idle,
			PlayerStateMachine.Events.PLAYER_JUMPED: jump,
		},
		jump: {
			PlayerStateMachine.Events.PLAYER_LANDED: idle,
		},
	}

	state_machine.activate(idle)
	state_machine.is_debugging = true
