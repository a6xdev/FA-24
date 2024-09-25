extends Node
class_name VehicleSteering

@export var currentOs_export:CurrentOS = CurrentOS.PC
enum CurrentOS{
	MOBILE,
	PC
}

@export var Vehicle: VehicleBody3D
@export var Broadcast:BroadcastNode

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
@export var tire_grip:float = 3  ## Sets the tire's grip on the surface. Lower values ​​provide greater traction, improving cornering stability, while higher values ​​result in more slippage and reduced cornering control.
@export var FrontLeftWheel: VehicleWheel3D
@export var FrontRightWheel: VehicleWheel3D
@export var BackLeftWheel: VehicleWheel3D
@export var BackRightWheel: VehicleWheel3D

var gyro
var current_steering

var steering_sensitivity: float = 0.03
var max_rotation: float = 0.5

func _physics_process(delta: float) -> void:
	SteerVehicle(delta)
	
func SteerVehicle(delta):
	set_tire_grip()
	var speed = Vehicle.linear_velocity.length() * 3.6  # Velocidade em km/h
	
	# Steering Angle Dynamic
	max_steer_angle = clamp(0.6 - (speed / speed_threshold) * 0.4, min_steer_angle, 0.6) # 0.5 é o limite
	# Ajustar a velocide do steering // o 5.0 é o maximo...
	steering_speed = clamp(5.0 - (speed / speed_threshold), min_steering_speed, 5.0)
	
	# Gyro Mobile
	var accelerometer_data = Input.get_accelerometer()
	var steering_angle = -accelerometer_data.x * steering_sensitivity
	steering_angle = clamp(steering_angle, -max_rotation, max_rotation)
	
	match currentOs_export:
		CurrentOS.PC:
			Vehicle.steering = move_toward(Vehicle.steering, Input.get_axis("car_right", "car_left") * max_steer_angle, delta * steering_speed)
		CurrentOS.MOBILE:
			Vehicle.steering = move_toward(Vehicle.steering, steering_angle, delta * steering_speed)
			
	# Ajusta a rotação do volante (modelo)
	steering_wheel.rotation_degrees.z = Vehicle.steering * -max_steering_angle

func set_tire_grip():
	# Applies the value of 'tire_grip' to all wheels
	FrontLeftWheel.wheel_friction_slip = tire_grip
	FrontRightWheel.wheel_friction_slip = tire_grip
	BackLeftWheel.wheel_friction_slip = tire_grip
	BackRightWheel.wheel_friction_slip = tire_grip
