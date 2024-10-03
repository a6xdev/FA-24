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

var target_steering

# accelerometer
var smoothing_factor: float = 0.1  # Fator de suavização
var previous_steering_angle: float = 0.0
var deadzone:float = 0.05

var max_rotation_at_low_speed:float = 30.0
var max_rotation_at_high_speed:float = 10.0
var max_rotation: float = 0.5

func _physics_process(delta: float) -> void:
	
	# Tire controller
	var interpolation_factor = min(1.0, VehicleBody.current_speed / (speed_threshold * 1.0))
	current_tire_angle = lerp(max_tire_angle, min_tire_angle, interpolation_factor)
	
	if Input.get_accelerometer():
		MobileController(delta)
	else:
		ComputerController(delta)
		
	SteerController(delta)

func SteerController(delta):
	current_steering = lerp(current_steering, target_steering, Config.steer_sensitivity * delta)
	steeringModel.rotation_degrees.z = -current_steering
	var tire_angle = clamp(current_steering * current_tire_angle, -max_tire_angle, max_tire_angle)
	
	if abs(target_steering) < 0.1:
		tire_angle = move_toward(VehicleBody.steering, 0, delta * steering_speed * 2)
	
	VehicleBody.steering = move_toward(VehicleBody.steering, tire_angle, delta * steering_speed)


func ComputerController(delta):
	target_steering =  Input.get_axis("car_right", "car_left") * max_steering_angle

func MobileController(delta):
	var accelerometer_data = Input.get_accelerometer()
	var smoothed_steering_angle = lerp(previous_steering_angle, accelerometer_data.x, smoothing_factor)
	target_steering =  -smoothed_steering_angle * max_steering_angle
	
	
