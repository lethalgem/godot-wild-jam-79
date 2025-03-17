@tool
class_name GrowingPlatform3D extends CSGBox3D

@export var move_time := 50.0
@export var movement_delay := 5.0 
@export var final_relative_pos := Vector3(0,5,0)

@onready var timer := $Timer
@onready var raycast3D := $RayCast3D
@onready var start_pos := global_position
@onready var tween: Tween

func _ready():
	if not Engine.is_editor_hint():
		raycast3D.top_level = true
	else:
		raycast3D.top_level = false
	
func _process(_delta):
	if not raycast3D.target_position == final_relative_pos:
		raycast3D.target_position = final_relative_pos

func _on_timer_timeout():
	tween = create_tween()
	tween.tween_property(self,"global_position", -raycast3D.target_position + global_position,move_time)

func start_timer():
	if movement_delay > 0:
		timer.wait_time = movement_delay
		timer.start()

func reset_position():
	if tween != null:
		tween.kill()
	timer.stop()
		
	global_position = start_pos
