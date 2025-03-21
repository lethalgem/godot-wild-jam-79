class_name Player3D extends CharacterBody3D

## Controls how quickly the player accelerates and turns on the ground.
@export_range(1.0, 50.0, 0.1) var steering_factor := 20.0
## Constant for gravitational force in m/s^2.
@export_range(0.0, 200.0, 0.1) var gravity_strength := 40.0

@export_group("State WALKING")
## The maximum speed the player can move at in meters per second.
@export_range(3.0, 30.0, 0.1) var max_speed := 6.0

@export_group("State DASHING")
@export_range(0, 30.0, 0.5) var dash_distance := 10.0
@export_range(0, 1.0, 0.01) var dash_time := 0.15
@export_range(0.001, 1, 0.01) var camera_zoom_time_dashing := 0.25

@export_group("State JUMPING & DOUBLE_JUMPING")
@export_range(3.0, 30.0, 0.1) var max_air_control_speed := 6.0
@export_range(1.0, 30.0, 0.1) var jump_velocity := 20.0
@export_range(1, 179, 1) var camera_fov_increase_jumping := 2.0
@export_range(0.001, 1, 0.01) var camera_zoom_time_jumping := 0.25

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
	idle.gravity_strength = gravity_strength

	var walk := PlayerStateMachine.StateWalk.new(self)
	walk.max_speed = max_speed
	walk.gravity_strength = gravity_strength

	var jump := PlayerStateMachine.StateJump.new(self)
	jump.max_speed = max_air_control_speed
	jump.jump_velocity = jump_velocity
	jump.camera_fov_increase = camera_fov_increase_jumping
	jump.camera_zoom_time = camera_zoom_time_jumping
	jump.gravity_strength = gravity_strength
	
	var dash := PlayerStateMachine.StateDash.new(self)
	dash.dash_distance = dash_distance
	dash.dash_time = dash_time
	dash.camera_zoom_time = camera_zoom_time_dashing
	
	var fall := PlayerStateMachine.StateFall.new(self)
	fall.gravity_strength = gravity_strength
	fall.steering_factor = steering_factor
	fall.max_speed = max_air_control_speed

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
			PlayerStateMachine.Events.PLAYER_LANDED: walk,
			PlayerStateMachine.Events.PLAYER_JUMPED : jump,
			PlayerStateMachine.Events.PLAYER_DASHED: dash,
			PlayerStateMachine.Events.PLAYER_FELL: fall,
		},
		dash: {
			PlayerStateMachine.Events.FINISHED: idle,
		},
		fall: {
			PlayerStateMachine.Events.PLAYER_LANDED: walk,
			PlayerStateMachine.Events.PLAYER_JUMPED: jump,
			PlayerStateMachine.Events.PLAYER_DASHED: dash,
		}
	}

	state_machine.activate(idle)
	state_machine.is_debugging = true
