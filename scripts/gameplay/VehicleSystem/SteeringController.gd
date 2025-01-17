extends Node
class_name SteeringController

@export var VehicleBody:BodyController
@export var Config:PlayerConfig
@export var steeringModel:Node3D

@export_group("Direction Settings")
@export_range(0, 350) var speed_threshold:int = 120

@export_subgroup("Steering Angle")
@export var max_steering_angle:float = 300
@export var max_tire_angle:float = 0.6
@export var min_tire_angle:float = 0.05

@export_subgroup("Steering Speed")
@export var max_steering_speed:float = 2
@export var min_steering_speed:float = 1

var current_steering_speed

@export_group("Set Tires")
@export var FrontLeftTyre:VehicleWheel3D
@export var FrontRightTyre:VehicleWheel3D
@export var BackLeftTyre:VehicleWheel3D
@export var BackRightTyre:VehicleWheel3D

var steering_input
var current_steering:float
var current_tire_angle:float

var max_rotation: float = 1.0
var smoothing_factor = 0.2
var previous_steering_angle: float = 0.0
var deadzone:float = 0.1
var filtered_accel_value = 0.1

var ackermann_factor: float = 0.7

func _physics_process(delta: float) -> void:
	var interpolation_factor = min(1.0, VehicleBody.current_speed / (speed_threshold * 1.0))
	var tire_angle = lerp(max_tire_angle, min_tire_angle, interpolation_factor)
	current_tire_angle = lerp(max_tire_angle, min_tire_angle, interpolation_factor)
	current_steering_speed = lerp(min_steering_speed, max_steering_speed, interpolation_factor)
	
	if not VehicleBody.debug:
		if Input.get_accelerometer():
			MobileController(delta)
		else:
			ComputerController(delta)
	else:
		VehicleBody.steering = 0.0
	
	steeringModel.rotation_degrees.z = -current_steering * max_steering_angle

func ComputerController(delta):
	var input = Input.get_axis("car_right", "car_left")
	current_steering = lerp(current_steering, input, 1.0 * (delta * 5))
	#current_steering_speed = clamp(min_steering_speed - (VehicleBody.current_speed / speed_threshold), min_steering_speed, max_steering_speed)
	
	if input == 0.0:
		VehicleBody.steering = move_toward(VehicleBody.steering, 0 * current_tire_angle, delta * current_steering_speed)
	else:
		VehicleBody.steering = move_toward(VehicleBody.steering, input * current_tire_angle, delta * current_steering_speed)

func MobileController(delta):
	max_steering_speed = 1
	var accelerometer_data = Input.get_accelerometer().x
	filtered_accel_value = lerp(filtered_accel_value, accelerometer_data, smoothing_factor)
	var smoothed_steering_angle = lerp(previous_steering_angle, filtered_accel_value, Config.accelerometer_sensitivity)
	
	smoothed_steering_angle = clamp(smoothed_steering_angle, -max_rotation, max_rotation)
	
	# Zona morta (deadzone)
	if abs(smoothed_steering_angle) < deadzone:
		smoothed_steering_angle = 0.0
	else:
		var sign = sign(smoothed_steering_angle)
		var adjusted_value = abs(smoothed_steering_angle) - deadzone
		var scaled_value = adjusted_value / (1.0 - deadzone)
		smoothed_steering_angle = sign * scaled_value
	
	current_steering = -smoothed_steering_angle
	
	VehicleBody.steering = move_toward(VehicleBody.steering, -smoothed_steering_angle * current_tire_angle, delta * current_steering_speed)
