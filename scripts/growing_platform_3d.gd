@tool
class_name GrowingPlatform3D extends StaticBody3D

## how long the platform should animate growing in seconds
@export var move_time := 10.0
## seconds after the checkpoint is touched that the platform should start growing
@export var movement_delay := 5.0
## seconds before the platform starts growing that it should hover in place
@export var hover_buffer := 0.1
## seconds before the platform starts growing that it should begin moving into view
@export var move_buffer := 0.2
## how far down the platform should be before appearing in meters
@export var appear_from_height_offset := 50
## relative position the platform will move to in meters
@export var final_relative_pos := Vector3(0, 5, 3)
## size the platform starts at and finishes at in meters
@export var initial_size := Vector3(0.5, 0.5, 0.5)
## largest size the platform will grow to in meters
@export var grow_to_size := Vector3(1, 1, 1)
## the percentage of the animation that will have finished when the platform grows to it's largest size
@export_range(0.01, 1.0, 0.01) var done_growing_percentage := 0.3
## the percentage of the animation that will have finished when the platform begins to shrink
@export_range(0.01, 1.0, 0.01) var begin_shrinking_percentage := 0.6
## how aggressively the grass scales up with the platform
@export var grass_mesh_scale_factor := 0.2 / 0.5
## how tall the grass is
@export var grass_mesh_height := 0.5

@onready var grow_timer := $GrowTimer
@onready var start_move_timer := $StartMoveTimer
@onready var raycast3D := $RayCast3D
@onready var tween: Tween

@onready var start_pos := global_position

var platform_mesh_instance: MeshInstance3D
var platform_collision_shape: CollisionShape3D
var platform_grass_mesh: MultiMeshInstance3D

func _enter_tree() -> void:
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if visible:
		_ready()
	else:
		platform_mesh_instance.queue_free()
		platform_collision_shape.queue_free()
		platform_grass_mesh.queue_free()
		
		platform_mesh_instance = null
		platform_collision_shape = null
		platform_grass_mesh = null

func _ready():
	if not Engine.is_editor_hint():
		raycast3D.top_level = true
	else:
		raycast3D.top_level = false
	
	assert(done_growing_percentage >= 0.1 and done_growing_percentage <= 1.0, "done_growing_percentage must be a percentage between 0.1 and 1.0")
	assert(done_growing_percentage <= begin_shrinking_percentage, "done_growing_percentage must be a greather than begin_shrinking_percentage")

	if platform_mesh_instance == null:
		platform_mesh_instance = MeshInstance3D.new()
		add_child(platform_mesh_instance)
		platform_mesh_instance.mesh = BoxMesh.new()
		platform_mesh_instance.mesh.surface_set_material(0, preload("res://themes/growing_platform_3d.tres"))
		platform_mesh_instance.mesh.size = initial_size
	
	if platform_collision_shape == null:
		platform_collision_shape = CollisionShape3D.new()
		add_child(platform_collision_shape)
		platform_collision_shape.shape = BoxShape3D.new()
		platform_collision_shape.shape.size = initial_size
	
	if platform_grass_mesh == null:
		platform_grass_mesh = MultiMeshInstance3D.new()
		add_child(platform_grass_mesh)
		platform_grass_mesh.multimesh = preload("res://themes/growing_platform_3d_multi_mesh.tres")
		platform_grass_mesh.material_override = preload("res://themes/wind_grass.tres")
		platform_grass_mesh.scale = Vector3(initial_size.x * grass_mesh_scale_factor, grass_mesh_height, initial_size.x * grass_mesh_scale_factor)

func _process(_delta):
	if not raycast3D.target_position == final_relative_pos:
		raycast3D.target_position = final_relative_pos
	
	if Engine.is_editor_hint():
		if not platform_mesh_instance.mesh.size == initial_size:
			platform_mesh_instance.mesh.size = initial_size
			platform_collision_shape.shape.size = initial_size
			platform_grass_mesh.scale.x = initial_size.x * grass_mesh_scale_factor
			platform_grass_mesh.scale.z = initial_size.z * grass_mesh_scale_factor
			platform_grass_mesh.position.y = initial_size.y / 2
		
		if not platform_grass_mesh.scale.y == grass_mesh_height:
			platform_grass_mesh.scale = Vector3(initial_size.x * grass_mesh_scale_factor, grass_mesh_height, initial_size.x * grass_mesh_scale_factor)


func _on_grow_timer_timeout():
	# TODO: throw transition and ease on, it'll make everything feel betteer
	tween = create_tween()
	tween.parallel().tween_property(self,"position", Vector3(1, 1, 1) * raycast3D.target_position + position, move_time)
	tween.parallel().tween_property(platform_mesh_instance.mesh, "size", grow_to_size, move_time * done_growing_percentage)
	tween.parallel().tween_property(platform_mesh_instance.mesh, "size", initial_size, move_time * (1 - begin_shrinking_percentage)).set_delay(move_time * begin_shrinking_percentage)
	tween.parallel().tween_property(platform_collision_shape.shape, "size", grow_to_size, move_time * done_growing_percentage)
	tween.parallel().tween_property(platform_collision_shape.shape, "size", initial_size, move_time * (1 - begin_shrinking_percentage)).set_delay(move_time * begin_shrinking_percentage)
	tween.parallel().tween_property(platform_grass_mesh, "scale:x", grow_to_size.x * grass_mesh_scale_factor, move_time * done_growing_percentage)
	tween.parallel().tween_property(platform_grass_mesh, "scale:x", initial_size.x * grass_mesh_scale_factor, move_time * (1 - begin_shrinking_percentage)).set_delay(move_time * begin_shrinking_percentage)
	tween.parallel().tween_property(platform_grass_mesh, "scale:z", grow_to_size.z * grass_mesh_scale_factor, move_time * done_growing_percentage)
	tween.parallel().tween_property(platform_grass_mesh, "scale:z", initial_size.z * grass_mesh_scale_factor, move_time * (1 - begin_shrinking_percentage)).set_delay(move_time * begin_shrinking_percentage)
	tween.parallel().tween_property(platform_grass_mesh, "position:y", grow_to_size.y / 2, move_time * done_growing_percentage)
	tween.parallel().tween_property(platform_grass_mesh, "position:y", initial_size.y / 2, move_time * (1 - begin_shrinking_percentage)).set_delay(move_time * begin_shrinking_percentage)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.connect("finished", func(): 
		if movement_delay - hover_buffer > 0.05:
			tween = create_tween()
			tween.tween_property(self, "global_position:y", global_position.y - appear_from_height_offset, move_buffer).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
		)

func start_timers():
	if movement_delay > 0:
		grow_timer.wait_time = movement_delay
		grow_timer.start()
		
		if movement_delay - hover_buffer > 0.05:
			start_move_timer.wait_time = movement_delay - hover_buffer - move_buffer
			start_move_timer.start()
			global_position.y -= appear_from_height_offset
		else:
			print_debug("hover_buffer and move_buffer would have the platform appear before 0 seconds from the checkpoint so it is not being used, ignore if this is intended")

func reset_position():
	if tween != null:
		tween.kill()
	grow_timer.stop()
	start_move_timer.stop()
	
	global_position = start_pos
	platform_mesh_instance.mesh.size = initial_size
	platform_collision_shape.shape.size = initial_size

func _on_start_move_timer_timeout() -> void:
	tween = create_tween()
	tween.tween_property(self, "global_position:y", global_position.y + appear_from_height_offset, move_buffer).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
