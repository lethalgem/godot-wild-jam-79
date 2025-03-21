@tool
class_name GrowingPlatform3D extends CSGBox3D

@export var move_time := 50.0
@export var movement_delay := 5.0 
@export var final_relative_pos := Vector3(0,5,0)
@export var minimum_branch_size := 0.25
@export var branch_gap := -0.5

@onready var timer := $Timer
@onready var raycast3D := $RayCast3D
@onready var start_pos := global_position
@onready var tween: Tween

@onready var last_branch_dimension = min(size.x, size.y, size.z)
@onready var initial_branch_dimension = last_branch_dimension
@onready var last_branch_position = global_position
@onready var original_branch_position = global_position


var shrink_factor

func _ready():
	if not Engine.is_editor_hint():
		raycast3D.top_level = true
	else:
		raycast3D.top_level = false
	
	var initial_size = last_branch_dimension / 2
	var final_size = minimum_branch_size
	var steps = int(start_pos.distance_to(final_relative_pos))
	shrink_factor = exp(log(final_size / initial_size) / steps)


func _process(_delta):
	if not raycast3D.target_position == final_relative_pos:
		raycast3D.target_position = final_relative_pos
	
	if not Engine.is_editor_hint():
		if global_position.distance_to(last_branch_position) > last_branch_dimension + branch_gap:
			print("making branch")
			var branch_sphere := MeshInstance3D.new()
			var sphere_mesh := SphereMesh.new()
			sphere_mesh.radius = last_branch_dimension / 2
			sphere_mesh.height = last_branch_dimension
			sphere_mesh.material = StandardMaterial3D.new()
			branch_sphere.mesh = sphere_mesh
			add_child(branch_sphere)
			branch_sphere.global_position = global_position
			branch_sphere.top_level = true
			last_branch_position = branch_sphere.global_position
			last_branch_dimension = shrink_factor * last_branch_dimension
	else:
		remove_branches()


func _on_timer_timeout():
	tween = create_tween()
	tween.tween_property(self,"global_position", Vector3(1, 1, 1) * raycast3D.target_position + global_position,move_time)

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
	last_branch_dimension = initial_branch_dimension
	remove_branches()

func remove_branches():
	for node in get_children():
		if node is MeshInstance3D:
			remove_child(node)
			node.queue_free()
