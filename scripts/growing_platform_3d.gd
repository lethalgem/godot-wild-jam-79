@tool
class_name GrowingPlatform3D extends CSGBox3D

## seconds
@export var move_time := 10.0
## seconds
@export var movement_delay := 5.0 
## relative position the platform will move to in meters
@export var final_relative_pos := Vector3(0,5,3)
## size the platform starts at and finishes at in meters
@export var initial_size := Vector3(0.5, 0.5, 0.5)
## largest size the platform will grow to in meters
@export var grow_to_size := Vector3(1, 1, 1)
## the percentage of the animation that will have finished when the platform grows to it's largest size
@export_range(0.01, 1.0, 0.01) var done_growing_percentage := 0.3
## the percentage of the animation that will have finished when the platform begins to shrink
@export_range(0.01, 1.0, 0.01) var begin_shrinking_percentage := 0.6
## gap between each sphere in the branch in meters
@export var branch_gap := -0.5

@onready var timer := $Timer
@onready var raycast3D := $RayCast3D
@onready var start_pos := global_position
@onready var tween: Tween

@onready var branch_dimension = min(size.x, size.y, size.z)
@onready var initial_branch_dimension = branch_dimension
@onready var last_branch_position = global_position
@onready var original_branch_position = global_position


var shrink_factor

func _ready():
	if not Engine.is_editor_hint():
		raycast3D.top_level = true
	else:
		raycast3D.top_level = false
	
	assert(done_growing_percentage >= 0.1 and done_growing_percentage <= 1.0, "done_growing_percentage must be a percentage between 0.1 and 1.0")
	assert(done_growing_percentage <= begin_shrinking_percentage, "done_growing_percentage must be a greather than begin_shrinking_percentage")
	
	size = initial_size

func _process(_delta):
	if not raycast3D.target_position == final_relative_pos:
		raycast3D.target_position = final_relative_pos
	
	if not Engine.is_editor_hint():
		if global_position.distance_to(last_branch_position) > branch_dimension + branch_gap:
			var branch_sphere := MeshInstance3D.new()
			var sphere_mesh := SphereMesh.new()
			sphere_mesh.radius = branch_dimension / 2
			sphere_mesh.height = branch_dimension
			sphere_mesh.material = StandardMaterial3D.new()
			branch_sphere.mesh = sphere_mesh
			add_child(branch_sphere)
			branch_sphere.global_position = global_position
			branch_sphere.top_level = true
			last_branch_position = branch_sphere.global_position
	else:
		if not size == initial_size:
			size = initial_size
		remove_branches()


func _on_timer_timeout():
	tween = create_tween()
	tween.parallel().tween_property(self,"global_position", Vector3(1, 1, 1) * raycast3D.target_position + global_position, move_time)
	tween.parallel().tween_property(self, "size", grow_to_size, move_time * done_growing_percentage)
	tween.parallel().tween_property(self, "size", initial_size, move_time * begin_shrinking_percentage).set_delay(begin_shrinking_percentage)

func start_timer():
	if movement_delay > 0:
		timer.wait_time = movement_delay
		timer.start()

func reset_position():
	if tween != null:
		tween.kill()
	timer.stop()
		
	global_position = start_pos
	last_branch_position = global_position
	size = initial_size
	remove_branches()

func remove_branches():
	for node in get_children():
		if node is MeshInstance3D:
			remove_child(node)
			node.queue_free()
