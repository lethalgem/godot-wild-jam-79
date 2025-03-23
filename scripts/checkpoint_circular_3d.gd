@tool
class_name CheckpointCircular3D extends Area3D

signal player_entered

@onready var debug_mesh = $MeshInstance3D
@onready var collision_shape = $CollisionShape3D
@export var height := 10.0
@export var radius := 5.0

func _ready():
	if not Engine.is_editor_hint():
		debug_mesh.visible = false

func _process(_delta):
	if collision_shape.shape.radius != radius:
		collision_shape.shape.radius = radius
		debug_mesh.mesh.top_radius = radius
		debug_mesh.mesh.bottom_radius = radius
	
	if collision_shape.shape.height != height:
		collision_shape.shape.height = height
		debug_mesh.mesh.height = height

func _on_body_entered(body):
	if body is Player3D:
		player_entered.emit()
