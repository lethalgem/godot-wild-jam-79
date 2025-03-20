@tool
class_name CheckpointRespawn3D extends Area3D

signal player_entered

@onready var debug_mesh = $MeshInstance3D
@onready var collision_shape = $CollisionShape3D
@export var size := Vector3(1,1,1)

func _ready():
	if not Engine.is_editor_hint():
		debug_mesh.visible = false

func _process(_delta):
	if collision_shape.shape.size != size:
		collision_shape.shape.size = size
		debug_mesh.mesh.size = size

func _on_body_entered(body):
	if body is Player3D:
		player_entered.emit(self)
