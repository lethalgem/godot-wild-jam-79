@tool
class_name StaticPlatformRect3D extends StaticBody3D

## meters
@export var size := Vector3(10.0, 20.0, 10.0)

var mesh_instance: MeshInstance3D
var collision_shape: CollisionShape3D

func _ready() -> void:
	for child in get_children():
		child.queue_free()
	
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	mesh_instance.mesh = BoxMesh.new()
	mesh_instance.mesh.size = size
	mesh_instance.mesh.surface_set_material(0, preload("res://themes/static_platform_3D.tres"))
	
	collision_shape = CollisionShape3D.new()
	add_child(collision_shape)
	collision_shape.shape = BoxShape3D.new()
	collision_shape.shape.size = size

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		if mesh_instance.mesh.size != size:
			mesh_instance.mesh.size = size
			collision_shape.shape.size = size
