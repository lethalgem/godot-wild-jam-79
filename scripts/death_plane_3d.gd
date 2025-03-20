@tool
class_name DeathPlane3D extends Area3D

signal player_entered

@export var size := Vector3(1,1,1)

var collision_shape: CollisionShape3D
var debug_mesh: MeshInstance3D

func _process(_delta):
	# @tool debugging stuff
	#for child in get_children():
		#child.queue_free()
	#collision_shape = null
	#debug_mesh = null
	
	if collision_shape == null:
		collision_shape = CollisionShape3D.new()
		add_child(collision_shape)
		
		collision_shape.shape = BoxShape3D.new()
		collision_shape.shape.size = size
	
		debug_mesh = MeshInstance3D.new()
		add_child(debug_mesh)
		
		debug_mesh.mesh = BoxMesh.new()
		debug_mesh.mesh.size = size
		debug_mesh.mesh.surface_set_material(0, preload("res://themes/death_plane_3d.tres"))
	else:
		if collision_shape.shape.size != size:
			collision_shape.shape.size = size
			debug_mesh.mesh.size = size

func _on_body_entered(body):
	if body is Player3D:
		player_entered.emit()
