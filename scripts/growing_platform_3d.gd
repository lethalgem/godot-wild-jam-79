@tool
class_name GrowingPlatform3D extends CSGBox3D

@export var move_time := 50.0
@export var movement_delay := 5.0 
@export var final_relative_pos := Vector3(0,5,0)

@onready var timer = $Timer
@onready var raycast3D = $RayCast3D

func _ready():
	raycast3D.top_level = true
	
func _process(delta):
	if not raycast3D.target_position == final_relative_pos:
		raycast3D.target_position = final_relative_pos
	

func _on_timer_timeout():
	var tween = create_tween()
	tween.tween_property(self,"global_position", raycast3D.target_position + global_position,move_time)

func start_timer():
	timer.wait_time = movement_delay
	timer.start()


func _on_timer_trigger_3d_player_entered():
	start_timer()
