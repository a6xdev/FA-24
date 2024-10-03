extends Node

@export var Vehicle: VehicleBody3D
@export var steering_wheel: Node3D  # Referência ao nó do volante
@export var max_steering_angle: float = 120.0  # Ângulo máximo do volante em graus

@export_group("Direction Settings")
@export var speed_threshold = 100.0 # Limite de velocidade
@export_subgroup("Steering Angle")
@export var max_steer_angle = 0.6
@export var min_steer_angle = 0.2
@export_subgroup("Steering Speed")
@export var steering_speed: float = 5.0  ## Speed ​​at which the vehicle reaches the maximum angle
@export var min_steering_speed:float = 1.0

@export_group("Wheel Settings")
@export var FrontLeftWheel: VehicleWheel3D
@export var FrontRightWheel: VehicleWheel3D
@export var BackLeftWheel: VehicleWheel3D
@export var BackRightWheel: VehicleWheel3D
@export_subgroup("Settings")
@export var tire_grip:float = 3  ## Sets the tire's grip on the surface. Lower values ​​provide greater traction, improving cornering stability, while higher values ​​result in more slippage and reduced cornering control.

var gyro
var current_steering

var steering_sensitivity: float = 0.02
var accel_sensitivity:float = 0.05
var smoothing_factor: float = 0.1  # Fator de suavização
var previous_steering_angle: float = 0.0
var deadzone:float = 0.05

var max_rotation_at_low_speed:float = 30.0
var max_rotation_at_high_speed:float = 10.0
var max_rotation: float = 0.5

var speed

var current_steering_speed

func _physics_process(delta: float) -> void:
	SteerVehicle(delta)
	
func SteerVehicle(delta):
	set_tire_grip()
	speed = Vehicle.linear_velocity.length() * 3.6  # Velocidade em km/h
	max_steer_angle = lerp(0.6, min_steer_angle, min(1.0, speed / (speed_threshold * 2)))

	
	if Input.get_accelerometer():
		steering_speed = 1.0
		min_steering_speed = 0.3
		MobileController(delta)
	else:
		ComputerController(delta)
		
	steering_wheel.rotation_degrees.z = Vehicle.steering * -max_steering_angle
	
func set_tire_grip():
	# Applies the value of 'tire_grip' to all wheels
	FrontLeftWheel.wheel_friction_slip = tire_grip
	FrontRightWheel.wheel_friction_slip = tire_grip
	BackLeftWheel.wheel_friction_slip = tire_grip
	BackRightWheel.wheel_friction_slip = tire_grip

# <------------------------------------------------------------------------->
# Todos os tipos de controles.
# <------------------------------------------------------------------------->

# Computer Controller
func ComputerController(delta):
	current_steering_speed = clamp(steering_speed - (speed / speed_threshold), min_steering_speed, steering_speed)
	Vehicle.steering = move_toward(Vehicle.steering, Input.get_axis("car_right", "car_left") * max_steer_angle, delta * current_steering_speed)

# Mobile
func MobileController(delta):
	var accelerometer_data = Input.get_accelerometer()
	var raw_steering_angle  = accelerometer_data.x * accel_sensitivity
	
	if abs(raw_steering_angle) < deadzone:
		raw_steering_angle = 0.0
		
	var smoothed_steering_angle = lerp(previous_steering_angle, raw_steering_angle, smoothing_factor)
	previous_steering_angle = smoothed_steering_angle
	var dynamic_max_rotation = lerp(max_rotation_at_low_speed, max_rotation_at_high_speed, min(1.0, speed / speed_threshold))
	smoothed_steering_angle *= steering_sensitivity
	smoothed_steering_angle = clamp(smoothed_steering_angle, -max_rotation, max_rotation)
	
	current_steering_speed = clamp(steering_speed - (speed / speed_threshold), min_steering_speed, steering_speed)
	Vehicle.steering = move_toward(Vehicle.steering, -smoothed_steering_angle, delta * current_steering_speed)
