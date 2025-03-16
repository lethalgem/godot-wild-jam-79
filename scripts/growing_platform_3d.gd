extends CSGBox3D

# TODO: Direction, Signal (Start Moving), Timer, Speed (Velocity)
@export var move_time := 50.0
@export var move_distance := 100
@export var movement_delay := 5.0 
@onready var timer = $Timer

func _on_timer_timeout():
	var tween = create_tween()
	tween.tween_property(self,"global_position",Vector3.UP * move_distance + global_position,move_time)

func start_timer():
	timer.wait_time = movement_delay
	timer.start()


func _on_timer_trigger_3d_player_entered():
	start_timer()
