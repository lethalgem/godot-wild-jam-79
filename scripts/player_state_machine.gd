class_name PlayerStateMachine extends RefCounted

enum Events {
	NONE,
	FINISHED,
	PLAYER_STARTED_MOVING,
	PLAYER_STOPPED_MOVING,
	PLAYER_JUMPED,
	PLAYER_LANDED,
	PLAYER_DASHED,
	PLAYER_FELL,
	PLAYER_STARTED_HANGING,
}

class Blackboard extends RefCounted:
	# shared static vars go here
	static var player : Player3D


class State extends RefCounted:

	## Emitted when the state completes and the state machine should transition to the next state.
	## Use this for time-based states or moves that have a fixed duration.
	signal finished

	## Display name of the state, for debugging purposes.
	var name := "State"
	## Reference to the player that the state controls.
	var player: Player3D = null


	func _init(init_name: String, init_player: Player3D) -> void:
		name = init_name
		player = init_player
		Blackboard.player = init_player


	## Called by the state machine on the engine's physics update tick.
	## Returns an event that the state machine can use to transition to the next state.
	## If there is no event, return [constant AI.Events.None]
	func update(_delta: float) -> Events:
		return Events.NONE


	## Called by the state machine upon changing the active state. The `data` parameter
	## is a dictionary with arbitrary data the state can use to initialize itself.
	func enter() -> void:
		pass


	## Called by the state machine before changing the active state. Use this function
	## to clean up the state.
	func exit() -> void:
		pass


class StateMachine extends Node:

	var transitions := {}: set = set_transitions
	var current_state: State
	var is_debugging := false: set = set_is_debugging

	func _init() -> void:
		set_physics_process(false)

	func set_transitions(new_transitions: Dictionary) -> void:
		transitions = new_transitions
		if OS.is_debug_build():
			for state: State in transitions:
				assert(
					state is State,
					"Invalid state in the transitions dictionary. " +
					"Expected a State object, but got " + str(state)
				)
				for event: Events in transitions[state]:
					assert(
						event is Events,
						"Invalid event in the transitions dictionary. " +
						"Expected an Events object, but got " + str(event)
					)
					assert(
						transitions[state][event] is State,
						"Invalid state in the transitions dictionary. " +
						"Expected a State object, but got " +
						str(transitions[state][event])
					)

	func set_is_debugging(new_value: bool) -> void:
		is_debugging = new_value
		if (
			current_state != null and
			current_state.player != null and
			current_state.player.debug_state_label != null
		):
			current_state.player.debug_state_label.text = current_state.name
			current_state.player.debug_state_label.visible = is_debugging

	func activate(initial_state: State = null) -> void:
		if initial_state != null:
			current_state = initial_state
		assert(
			current_state != null,
			"Activated the state machine but the state variable is null. " +
			"Please assign a starting state to the state machine."
		)
		current_state.finished.connect(_on_state_finished.bind(current_state))
		current_state.enter()
		set_physics_process(true)

	func _physics_process(delta: float) -> void:
		var event := current_state.update(delta)
		if event == Events.NONE:
			return
		trigger_event(event)

	func trigger_event(event: Events) -> void:
		assert(
			transitions[current_state],
			"Current state doesn't exist in the transitions dictionary."
		)
		if not transitions[current_state].has(event):
			print_debug(
				"Trying to trigger event " + Events.keys()[event] +
				" from state " + current_state.name +
				" but the transition does not exist."
			)
			return
		if event == Events.PLAYER_LANDED:
			Blackboard.player._jump_count = 0
			Blackboard.player._dash_count = 0
			
		if event == Events.PLAYER_STARTED_MOVING and Blackboard.player.velocity.y >= 0 :
			Blackboard.player._dash_count = 0
			
		var next_state =  transitions[current_state][event]
		_transition(next_state)

	func _transition(new_state: State) -> void:
		if Blackboard.player._jump_count >= 2 and new_state is StateJump:
			return
			
		# TODO: If you single jump into dash then you cannot double jump. However, you can double jump and then dash. (Fix Double Jump to work after Jump + Dash)
		if (Blackboard.player._dash_count >= 1 and current_state is StateFall) or ( Blackboard.player._dash_count >= 2 and current_state is StateIdle) and new_state is StateDash:
			return
		
		current_state.exit()
		current_state.finished.disconnect(_on_state_finished)
		current_state = new_state
		current_state.finished.connect(_on_state_finished.bind(current_state))
		current_state.enter()
	
		if is_debugging and current_state.player.debug_state_label != null:
			current_state.player.debug_state_label.text = current_state.name

	func _on_state_finished(finished_state: State) -> void:
		assert(
			Events.FINISHED in transitions[current_state],
			"Received a state that does not have a transition for the FINISHED event, " + current_state.name + ". " +
			"Add a transition for this event in the transitions dictionary."
		)
		_transition(transitions[finished_state][Events.FINISHED])


class StateIdle extends State:
	
	var gravity_strength := 40.0
	
	func _init(init_player: Player3D) -> void:
		super("Idle", init_player)

	func enter() -> void:
		player.skin.idle()
		
	func update(delta: float) -> Events:
		var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		
		# Idle shouldn't preserve any horizontal velocity from previous states
		player.velocity = Vector3(0, gravity_strength * delta * -1 + player.velocity.y, 0)
		player.move_and_slide()

		# multiply by inverse x and y to account for skin's local axes.
		# Add position to make everything relative to where the player is
		var look_at_direction := (player.velocity * Vector3(-1, 0 , -1)).normalized() + player.global_position
		if not (look_at_direction - player.global_position).is_zero_approx():
			player.skin.look_at(look_at_direction)

		if not input_vector.is_zero_approx():
			return Events.PLAYER_STARTED_MOVING
		elif Input.is_action_just_pressed("jump"):
			return Events.PLAYER_JUMPED
		elif Input.is_action_just_pressed("dash"):
			return Events.PLAYER_DASHED
		elif player.velocity.y < 0:
			return Events.PLAYER_FELL
		return Events.NONE


class StateWalk extends State:

	var max_speed = 10.0
	var steering_factor = 20.0
	var gravity_strength := 40.0

	func _init(init_player: Player3D) -> void:
		super("Walk", init_player)

	func enter() -> void:
		player.skin.move()

	func update(delta: float) -> Events:
		var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		# inverse to account for positive player axes and rotate relative to camera forward
		var direction := Vector3(-input_vector.x, 0.0, -input_vector.y).rotated(Vector3(0, 1, 0), player.camera_anchor.rotation.y)
		var desired_ground_velocity: Vector3 = max_speed * direction
		var steering_vector := desired_ground_velocity - player.velocity
		steering_vector.y = 0.0
		# We limit the steering amount to ensure the velocity can never overshoots the desired velocity.
		var steering_amount: float = min(steering_factor * delta, 1.0)
		player.velocity += steering_vector * steering_amount

		player.velocity += gravity_strength * delta * Vector3.DOWN
		player.move_and_slide()

		# multiply by inverse x and y to account for skin's local axes.
		# Add position to make everything relative to where the player is
		var look_at_direction := (player.velocity * Vector3(-1, 1 , -1)).normalized() + player.global_position
		if not (look_at_direction - player.global_position).is_zero_approx():
			player.skin.look_at(look_at_direction)

		if direction.is_zero_approx():
			return Events.PLAYER_STOPPED_MOVING
		elif Input.is_action_just_pressed("jump"):
			return Events.PLAYER_JUMPED
		elif Input.is_action_just_pressed("dash"):
			return Events.PLAYER_DASHED
		elif player.velocity.y < 0:
			return Events.PLAYER_FELL
		return Events.NONE


class StateJump extends State:

	var jump_velocity := 15.0
	var max_speed := 10.0
	var steering_factor := 20.0
	var camera_fov := 45 # degrees
	var camera_zoom_time = 0.25 # seconds
	var gravity_strength := 40.0

	var _initial_camera_fov: float

	func _init(init_player: Player3D) -> void:
		super("Jump", init_player)

	func enter() -> void:
		player._jump_count += 1
		player.skin.jump()
		player.velocity.y = jump_velocity

		_initial_camera_fov = player.camera_3D.fov

		var tween = player.create_tween()
		tween.parallel().tween_property(player.camera_3D, "fov", camera_fov, camera_zoom_time).set_ease(Tween.EASE_IN_OUT)

	func exit() -> void:
		var tween = player.create_tween()
		tween.parallel().tween_property(player.camera_3D, "fov", _initial_camera_fov, camera_zoom_time).set_ease(Tween.EASE_IN_OUT)

	func update(delta: float) -> Events:
		var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		# inverse to account for positive player axes and rotate relative to camera forward
		var direction := Vector3(-input_vector.x, 0.0, -input_vector.y).rotated(Vector3(0, 1, 0), player.camera_anchor.rotation.y)
		var desired_ground_velocity: Vector3 = max_speed * direction
		var steering_vector := desired_ground_velocity - player.velocity
		steering_vector.y = 0.0
		# We limit the steering amount to ensure the velocity can never overshoots the desired velocity.
		var steering_amount: float = min(steering_factor * delta, 1.0)
		player.velocity += steering_vector * steering_amount

		player.velocity += gravity_strength * delta * Vector3.DOWN
		player.move_and_slide()

		# multiply by inverse x and y to account for skin's local axes. Ignore y velocity so the skin stays up right
		# Add position to make everything relative to where the player is
		var look_at_direction := (player.velocity * Vector3(-1, 0, -1)).normalized() + player.global_position
		if not (look_at_direction - player.global_position).is_zero_approx():
			player.skin.look_at(look_at_direction)
			
		if player.is_on_floor():
			return Events.PLAYER_LANDED
		elif Input.is_action_just_pressed("jump"):
			return Events.PLAYER_JUMPED
		elif Input.is_action_just_pressed("dash"):
			return Events.PLAYER_DASHED
		elif player.velocity.y < 0:
			return Events.PLAYER_FELL
		return Events.NONE


class StateDash extends State:
	
	var dash_distance := 10.0 # meters
	var dash_time := 0.15 # second
	var camera_fov := 45 # degrees
	var camera_zoom_time = 0.25 # seconds
	
	var _elapsed_time := 0.0
	var _initial_camera_fov: float
	
	func _init(init_player: Player3D) -> void:
		super("Dash", init_player)
		
	func enter():
		player._dash_count += 1
		player.skin.fall()
		
		# Ignore y velocity so the skin stays up right
		# Add position to make everything relative to where the player is
		var dash_endpoint := (player.velocity * Vector3(1, 0, 1)).normalized() * dash_distance + player.global_position

		# Dash in the skin's forward direction if the player is not moving horizontally
		# We use velocity to determine skin direction, so we shouldn't default to this method unless static
		if Vector2(player.velocity.x, player.velocity.z).is_zero_approx():
			dash_endpoint = player.skin.get_global_transform().basis.z * dash_distance + player.global_position
		
		# Smoothly move to the dashed position
		var tween = player.create_tween()
		tween.tween_property(player, "global_position", dash_endpoint, dash_time).set_ease(Tween.EASE_IN_OUT)
	
		_initial_camera_fov = player.camera_3D.fov
		tween.parallel().tween_property(player.camera_3D, "fov", camera_fov, camera_zoom_time).set_ease(Tween.EASE_IN_OUT)
	
	func exit():
		_elapsed_time = 0.0
		
		# Don't preserve any velocity from previous state
		player.velocity = Vector3.ZERO
		
		var tween = player.create_tween()
		tween.tween_property(player.camera_3D, "fov", _initial_camera_fov, camera_zoom_time).set_ease(Tween.EASE_IN_OUT)
	
	func update(delta: float) -> Events:
		_elapsed_time += delta
		
		if _elapsed_time >= dash_time:
			return Events.FINISHED
		return Events.NONE


class StateFall extends State:
	
	var gravity_strength := 40.0
	var max_speed := 10.0
	var steering_factor := 20.0
	
	func _init(init_player: Player3D) -> void:
		super("Fall", init_player)
		
	func enter():
		player.skin.fall()
	
	func update(delta: float) -> Events:
		player.velocity += gravity_strength * delta * Vector3.DOWN
		player.move_and_slide()
		
		var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		# inverse to account for positive player axes and rotate relative to camera forward
		var direction := Vector3(-input_vector.x, 0.0, -input_vector.y).rotated(Vector3(0, 1, 0), player.camera_anchor.rotation.y)
		var desired_ground_velocity: Vector3 = max_speed * direction
		var steering_vector := desired_ground_velocity - player.velocity
		steering_vector.y = 0.0
		# We limit the steering amount to ensure the velocity can never overshoots the desired velocity.
		var steering_amount: float = min(steering_factor * delta, 1.0)
		player.velocity += steering_vector * steering_amount
		
		# multiply by inverse x and y to account for skin's local axes. Ignore y velocity so the skin stays up right
		# Add position to make everything relative to where the player is
		var look_at_direction := (player.velocity * Vector3(-1, 0, -1)).normalized() + player.global_position
		if not (look_at_direction - player.global_position).is_zero_approx():
			player.skin.look_at(look_at_direction)
		
		if player.velocity.y >= 0:
			return Events.PLAYER_LANDED
		elif Input.is_action_just_pressed("jump"):
			return Events.PLAYER_JUMPED
		elif Input.is_action_just_pressed("dash"):
			return Events.PLAYER_DASHED
		return Events.NONE

class StateWallHang extends State:
	# TODO: make player static while hanging (how to do this while still being affected by outside physics?
	# TODO: try requiring the key that was being pressed at when contact with the wall was made be held to stay on the wall (alternatively, try holding in the direction of the wall?)
	# TODO: detect when a wall is hit, likely through the player's collision shape?
	
	var gravity_strength := 40.0
	var max_speed := 10.0
	var steering_factor := 20.0
	
	func _init(init_player: Player3D) -> void:
		super("Fall", init_player)
		
	func enter():
		player.skin.fall()
	
	func update(delta: float) -> Events:
		player.velocity += gravity_strength * delta * Vector3.DOWN
		player.move_and_slide()
		
		var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		# inverse to account for positive player axes and rotate relative to camera forward
		var direction := Vector3(-input_vector.x, 0.0, -input_vector.y).rotated(Vector3(0, 1, 0), player.camera_anchor.rotation.y)
		var desired_ground_velocity: Vector3 = max_speed * direction
		var steering_vector := desired_ground_velocity - player.velocity
		steering_vector.y = 0.0
		# We limit the steering amount to ensure the velocity can never overshoots the desired velocity.
		var steering_amount: float = min(steering_factor * delta, 1.0)
		player.velocity += steering_vector * steering_amount
		
		# multiply by inverse x and y to account for skin's local axes. Ignore y velocity so the skin stays up right
		# Add position to make everything relative to where the player is
		var look_at_direction := (player.velocity * Vector3(-1, 0, -1)).normalized() + player.global_position
		if not (look_at_direction - player.global_position).is_zero_approx():
			player.skin.look_at(look_at_direction)
		
		if player.velocity.y >= 0:
			return Events.PLAYER_LANDED
		elif Input.is_action_just_pressed("jump"):
			return Events.PLAYER_JUMPED
		elif Input.is_action_just_pressed("dash"):
			return Events.PLAYER_DASHED
		return Events.NONE
