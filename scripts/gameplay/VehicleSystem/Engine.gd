extends Node
class_name EngineController

@export var BodyControllerNode:BodyController
@export var Config:PlayerConfig
@export var SoundManager:SoundsController

@export_group("Engine Settings")
@export var ignition:bool = true
@export_subgroup("RPM")
@export var max_rpm:int = 15000.0
@export var min_rpm:int = 700
@export var idle_rpm:int = 1150.0
@export var rpm_increment_rate:int = 100.0
@export var acceleration_multipliers: Array = [5.0, 2.2, 1.8, 1.5, 1.2, 1.0, 0.8, 0.6]
@export var deceleration_rate: float = 500.0
@export var cut_rpm_factor: float = 0.6
@export var warning_rpm: float = 9500.0
@export_subgroup("Engine")
@export var torque_curve:Array = [0, 50, 100, 200, 300, 320, 300, 280, 260, 240]
@export var speed_limit:Array[int] = [50, 0, 124, 152, 180, 208, 273, 302]
@export var engine_inertia = 0.1
@export var engine_braking = 0.02

@export_group("Torque and Power")
@export var torque_multiplier:float = 1.0
@export var HP:int = 850

@export_group("Transmission")
@export var gear_ratios:Array = [3.5, 2.8, 2.2, 1.8, 1.4, 1.2, 1.0, 0.9]
@export var final_drive_ratio: float = 3.9
@export var differential_ratio: float = 4.0
@export var max_gear: int = 7
@export var min_gear: int = -1

@export_group("Speed and Conversion")
@export var velocity:float = 0.0
@export var wheel_radius:float = 0.331
@export var acceleration:float = 0.0

@export_group("Brake")
@export var brake_force = 10

@export_group("Wheels")
@export var BackTireLeft: VehicleWheel3D
@export var BackTireRight: VehicleWheel3D
@export var FrontTireLeft: VehicleWheel3D
@export var FrontTireRight: VehicleWheel3D

var weight: float = 798.0
var torque:float = 0.0
var rpm:int = 0.0
var speed_kmh:float = 0.0

var engine_force:float
var speed_limit_current = 0.0

var is_accelerating:bool = false
var is_reversing: bool = false
var in_neutral: bool = false
var is_braking:bool = false

# <----- INPUT ----->
var throttle_input:float = 0.0
var brake_input:float = 0.0
var gear:int = 0

signal gear_shifted(new_rpm: float)

func _physics_process(delta: float) -> void:
	if not BodyControllerNode.debug:
		CORE()
		EngineForceDynamic(delta)
		handle_inputs(delta)
		
		UpdateRPM(delta)
		TransmissionController(delta)
		UpdateTorque()
	else:
		BackTireLeft.brake = brake_force
		BackTireRight.brake = brake_force
		FrontTireLeft.brake = brake_force
		FrontTireRight.brake = brake_force

func CORE():
	if BodyControllerNode:
		BodyControllerNode.throttle_input = throttle_input
		BodyControllerNode.brake_input = brake_input
		BodyControllerNode.current_gear = gear
		BodyControllerNode.current_rpm = rpm
	
func handle_inputs(delta:float):
	if Input.is_action_pressed("car_force") && Input.is_action_pressed("car_brake"):
		brake_input = clamp(brake_input + delta * Config.brake_force, 0.5, 0.5)
		throttle_input = 0.0
	else:
		if Input.is_action_pressed("car_force"):
			throttle_input = clamp(throttle_input + delta * Config.throttle_force, 0.0, 1.0)
			is_accelerating = true
		else:
			throttle_input = clamp(throttle_input - delta * Config.throttle_force, 0.0, 1.0)
			is_accelerating = false

		if Input.is_action_pressed("car_brake"):
			brake_input = clamp(brake_input + delta * Config.brake_force, 0.0, 1.0)
		else:
			brake_input = clamp(brake_input - delta * Config.brake_force, 0.0, 1.0)
		
		
		if Input.is_action_pressed("car_brake"):
			BackTireLeft.brake = brake_force
			BackTireRight.brake = brake_force
			FrontTireLeft.brake = brake_force
			FrontTireRight.brake = brake_force
			is_braking = true
		else:
			BackTireLeft.brake = 0.0
			BackTireRight.brake = 0.0
			FrontTireLeft.brake = 0.0
			FrontTireRight.brake = 0.0
			is_braking = false
			
		if Input.is_action_pressed("car_force"):
			if ignition and rpm > 0 and not in_neutral and not is_reversing:
				BackTireLeft.engine_force = engine_force
				BackTireRight.engine_force = engine_force
			elif ignition and is_reversing and rpm > 0:
				BackTireLeft.engine_force = -engine_force / 3
				BackTireRight.engine_force = -engine_force / 3
		else:
			BackTireLeft.engine_force = 0.0
			BackTireRight.engine_force = 0.0

func EngineForceDynamic(delta: float) -> void:
	var threshold = speed_limit_current * 0.20
	
	engine_force = ((rpm * 2) * PI * wheel_radius) / (gear_ratios[gear] * 60)
	
	if BodyControllerNode.current_speed >= speed_limit_current:
		engine_force = 0
	elif BodyControllerNode.current_speed >= (speed_limit_current - threshold):
		var distance_to_limit = BodyControllerNode.current_speed - (speed_limit_current - threshold)
		engine_force *= (1 - (distance_to_limit / threshold))
	else:
		engine_force = engine_force
		
	if gear <= 2 and gear > 0 and BodyControllerNode.current_speed <= 100:
		if BodyControllerNode.steering >= 0.4:
			if Input.is_action_pressed("car_force"):
				BackTireLeft.engine_force *= 350
				BackTireRight.engine_force -= 700
		elif BodyControllerNode.steering <= -0.4:
			if Input.is_action_pressed("car_force"):
				BackTireRight.engine_force *= 350
				BackTireLeft.engine_force -= 700

func UpdateRPM(delta:float) -> void:
	if not ignition:
		rpm -= deceleration_rate * 2 * delta
		rpm = max(rpm, 0.0)
		return
		
	var gear_index = clamp(gear - 1, 0, acceleration_multipliers.size() - 1)
	var acceleration_rate = 1500.0 * acceleration_multipliers[gear_index]
	
	if rpm >= warning_rpm:
		rpm -= (acceleration_rate * 0.7 - 50) * delta
	
	if throttle_input > 0:
		var rpm_change = acceleration_rate * throttle_input * delta
		rpm += rpm_change
		rpm = min(rpm, max_rpm)
	elif brake_input > 0:
		rpm -= deceleration_rate * 4 * brake_input * delta
		rpm = max(rpm, min_rpm)
	else:
		rpm -= deceleration_rate * delta
		if rpm < min_rpm:
			rpm = min_rpm

	if throttle_input > 0 and is_reversing:
		rpm += acceleration_rate * 0.5 * throttle_input * delta
		rpm = min(rpm, 4000)

	var random_fluctuation = randf_range(-5, 5)
	rpm += random_fluctuation
	rpm = clamp(rpm, min_rpm, max_rpm)

func TransmissionController(delta:float) -> void:
	if Input.is_action_just_pressed("upshift") and gear < max_gear:
		gear = min(gear + 1, max_gear)
		rpm *= 0.66
		emit_signal("gear_shifted", rpm)
	elif Input.is_action_just_pressed("downshift") and gear < min_rpm:
		gear = max(gear - 1, min_gear)
		rpm *= 1.3
		emit_signal("gear_shifted", rpm)
		
	speed_limit_current = 0.0
	if gear == 0:
		engine_force = 0
		is_reversing = false
		in_neutral = true
	elif gear == -1:
		speed_limit_current = speed_limit[0]
		is_reversing = true
		in_neutral = false
	elif gear == 7:
		speed_limit_current = speed_limit[8]
		is_reversing = false
		in_neutral = false
	else:
		speed_limit_current = speed_limit[gear + 1]
		is_reversing = false
		in_neutral = false

func UpdateTorque() -> void:
	var power: float = HP * 1000
	var torque_wheel:float
	var torque_engine:float
	
	torque_engine = (power * 5252) / rpm if rpm > 0 else 0.0
	torque_wheel = torque_engine * gear_ratios[gear]
	torque = torque_wheel
	torque = clamp(torque, 0, power / max_rpm * 9.5488)
