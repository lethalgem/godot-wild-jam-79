class_name Player3D extends CharacterBody3D

## Controls how quickly the player accelerates and turns on the ground.
@export_range(1.0, 50.0, 0.1) var steering_factor := 20.0

@export_group("State WALKING")
## The maximum speed the player can move at in meters per second.
@export_range(3.0, 30.0, 0.1) var max_speed := 6.0

@export_group("State DASHING")
@export_range(0, 30.0, 0.5) var dash_distance := 10.0
@export_range(0, 1.0, 0.01) var dash_time := 0.15
@export_range(1, 179, 1) var camera_fov_dashing:= 60
@export_range(0.001, 1, 0.01) var camera_zoom_time_dashing := 0.25

@export_group("State JUMPING & DOUBLE_JUMPING")
@export_range(3.0, 30.0, 0.1) var max_air_control_speed := 6.0
@export_range(1.0, 30.0, 0.1) var jump_velocity := 20.0
@export_range(1, 179, 1) var camera_fov_jumping:= 60
@export_range(0.001, 1, 0.01) var camera_zoom_time_jumping := 0.25

@export_group("State FALLING")
@export_range(0.0, 100.0, 0.1) var gravity_strength := 40.0

@onready var skin: SophiaSkin3D = %SophiaSkin
@onready var camera_anchor: Node3D = %CameraAnchor
@onready var camera_3D: Camera3D = %Camera3D
@onready var debug_state_label = %DebugStateLabel3D

var _jump_count := 0
var _dash_count := 0

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
	
	var double_jump := PlayerStateMachine.StateJump.new(self)
	double_jump.max_speed = max_air_control_speed
	double_jump.jump_velocity = jump_velocity
	double_jump.camera_fov = camera_fov_jumping
	double_jump.camera_zoom_time = camera_zoom_time_jumping
	
	var dash := PlayerStateMachine.StateDash.new(self)
	dash.dash_distance = dash_distance
	dash.dash_time = dash_time
	dash.camera_fov = camera_fov_dashing
	dash.camera_zoom_time = camera_zoom_time_dashing
	
	var fall := PlayerStateMachine.StateFall.new(self)
	fall.gravity_strength = gravity_strength
	fall.steering_factor = steering_factor
	fall.max_speed = max_air_control_speed

	# TODO: Only allow one dash within a set amount of time
	state_machine.transitions = {
		idle: {
			PlayerStateMachine.Events.PLAYER_STARTED_MOVING: walk,
			PlayerStateMachine.Events.PLAYER_JUMPED: jump,
			PlayerStateMachine.Events.PLAYER_DASHED: dash,
			PlayerStateMachine.Events.PLAYER_FELL: fall,
		},
		walk: {
			PlayerStateMachine.Events.PLAYER_STOPPED_MOVING: idle,
			PlayerStateMachine.Events.PLAYER_JUMPED: jump,
			PlayerStateMachine.Events.PLAYER_DASHED: dash,
			PlayerStateMachine.Events.PLAYER_FELL: fall,
		},
		jump: {
			PlayerStateMachine.Events.PLAYER_LANDED: idle,
			PlayerStateMachine.Events.PLAYER_DOUBLE_JUMPED : double_jump,
			PlayerStateMachine.Events.PLAYER_DASHED: dash,
			PlayerStateMachine.Events.PLAYER_FELL: fall,
		},
		double_jump: {
			PlayerStateMachine.Events.PLAYER_LANDED: idle,
			PlayerStateMachine.Events.PLAYER_FELL: fall,
			PlayerStateMachine.Events.PLAYER_DASHED: dash,
		},
		dash: {
			PlayerStateMachine.Events.FINISHED: idle,
		},
		fall: {
			PlayerStateMachine.Events.PLAYER_LANDED: idle,
			PlayerStateMachine.Events.PLAYER_DOUBLE_JUMPED: double_jump,
			PlayerStateMachine.Events.PLAYER_DASHED: dash,
		}
	}

	state_machine.activate(idle)
	state_machine.is_debugging = true
