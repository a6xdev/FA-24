extends VehicleBody3D

var vehicle_rpm:int 

#func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event.is_action("test_key"):
		linear_velocity.y =+ 5.0
		
func _physics_process(delta):
	$Debug/VBoxContainer/Rpm.text = "RPM: " + str(vehicle_rpm)
