extends VehicleBody3D
class_name BodyController

# <-- Transmission -->
var current_gear:int
var current_rpm:int
var current_speed:int

func _physics_process(delta: float) -> void:
	current_speed = linear_velocity.length() * 3.6
	
	$PlayerInterface/FPS.text = "FPS: " + str(Engine.get_frames_per_second())
