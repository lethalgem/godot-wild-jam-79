@tool
class_name StaticPlatform3D extends StaticBody3D

## meters
@export var height := 27.0
## meters
@export var radius := 5.0

var mesh_instance: MeshInstance3D
var collision_shape: CollisionShape3D
var bottom_mesh_instance: MeshInstance3D

func _ready() -> void:
	for child in get_children():
		child.queue_free()
	
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	mesh_instance.mesh = CylinderMesh.new()
	mesh_instance.mesh.height = height
	mesh_instance.mesh.top_radius = radius
	mesh_instance.mesh.bottom_radius = radius
	mesh_instance.mesh.surface_set_material(0, preload("res://themes/static_platform_3D.tres"))
	
	collision_shape = CollisionShape3D.new()
	add_child(collision_shape)
	collision_shape.shape = CylinderShape3D.new()
	collision_shape.shape.height = height
	collision_shape.shape.radius = radius
	
	bottom_mesh_instance = MeshInstance3D.new()
	add_child(bottom_mesh_instance)
	bottom_mesh_instance.mesh = TorusMesh.new()
	bottom_mesh_instance.mesh

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		if mesh_instance.mesh.height != height:
			mesh_instance.mesh.height = height
			collision_shape.shape.height = height
		
		if mesh_instance.mesh.top_radius != radius:
			mesh_instance.mesh.top_radius = radius
			mesh_instance.mesh.bottom_radius = radius
			collision_shape.shape.radius = radius
