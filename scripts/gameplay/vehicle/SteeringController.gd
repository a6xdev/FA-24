extends Node
class_name SteeringController

@export var VehicleBody:BodyController
@export var Config:PlayerConfig
@export var steeringModel:Node3D

@export_group("Direction Settings")
@export var speed_threshold:int = 120
@export_subgroup("Steering Angle")
@export var max_steering_angle:float = 300
@export var max_tire_angle:float = 0.6
@export var min_tire_angle:float = 0.05
@export_subgroup("Steering Speed")
@export var steering_speed:int = 2
@export var min_steering_speed:int = 1

@export_group("Set Tires")
@export var FrontLeftTire:VehicleWheel3D
@export var FrontRightTire:VehicleWheel3D
@export var BackLeftTire:VehicleWheel3D
@export var BackRightTire:VehicleWheel3D

var steering_input
var current_steering:float
var current_tire_angle:float

# accelerometer
var smoothing_factor: float = 0.1  # Fator de suavização
var previous_steering_angle: float = 0.0
var deadzone:float = 0.1

var max_rotation: float = 0.5

func _physics_process(delta: float) -> void:
	
	# Tire controller
	var interpolation_factor = min(1.0, VehicleBody.current_speed / (speed_threshold * 1.0))
	current_tire_angle = lerp(max_tire_angle, min_tire_angle, interpolation_factor)
	
	if Input.get_accelerometer():
		MobileController(delta)
	else:
		ComputerController(delta)
		
	steeringModel.rotation_degrees.z = -current_steering * max_steering_angle

func ComputerController(delta):
	current_steering = lerp(current_steering, Input.get_axis("car_right", "car_left"), Config.steer_sensitivity * delta)
	VehicleBody.steering = move_toward(VehicleBody.steering, Input.get_axis("car_right", "car_left") * current_tire_angle, delta * steering_speed)

func MobileController(delta):
	var accelerometer_data = Input.get_accelerometer()
	var smoothed_steering_angle = lerp(previous_steering_angle, accelerometer_data.x, smoothing_factor)
	smoothed_steering_angle *= Config.steer_sensitivity
	smoothed_steering_angle = clamp(smoothed_steering_angle, -max_rotation, max_rotation)
	
	if abs(smoothed_steering_angle) < deadzone:
		smoothed_steering_angle = 0.0
	else:
		var sign = sign(smoothed_steering_angle)
		var adjusted_value = abs(smoothed_steering_angle) - deadzone
		var scaled_value = adjusted_value / (1.0 - deadzone) # Normalizar o valor fora da deadzone
		smoothed_steering_angle = sign * scaled_value
		
	current_steering = - smoothed_steering_angle
	
	VehicleBody.steering = move_toward(VehicleBody.steering, -smoothed_steering_angle, delta * steering_speed)
	
	