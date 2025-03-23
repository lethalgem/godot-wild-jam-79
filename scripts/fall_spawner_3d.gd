class_name FallSpawner3D extends Node3D

signal spawned_body

@export var mesh : MeshInstance3D
@export var spawn_timer : Timer

var fall_body_scene := preload("res://scenes/fall_body_3d.tscn")
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	mesh.visible = false

func _start_spawns():
	spawn_timer.start()

func _stop_spawns():
	spawn_timer.stop()

func _on_timer_timeout() -> void:
	var fall_body_instance: FallBody3D = fall_body_scene.instantiate()
	fall_body_instance.rotation = Vector3(rng.randf_range(-180.0, 180.0), rng.randf_range(-180.0, 180.0), rng.randf_range(-180.0, 180.0))
	fall_body_instance.position = Vector3(rng.randf_range(-mesh.mesh.top_radius, mesh.mesh.top_radius), 0, rng.randf_range(-mesh.mesh.top_radius, mesh.mesh.top_radius))
	add_child(fall_body_instance)
	spawned_body.emit()
