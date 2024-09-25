extends Node
#class_name VehicleEngine

@export var Vehicle: VehicleBody3D
@export var RPM: VehicleRPM

@export_group("Speed Settings")
@export var SPEED_REVERSE_GEAR = 10  # Define a velocidade máxima do veículo em ré.

var current_speed: int

@export_group("Engine Settings")
@export var engine_power = 100
@export var gear_ratio = 4.0  # Relação de transmissão

@export_group("Braking Settings")
@export var brake_force = 10  # Força aplicada nos freios.
@export var handbrake_force = 0  # Força do freio de mão.

@export_group("Broadcast Settings")
@export var Gears: Array[int] = [80, 140, 200, 250, 300, 350]
var current_gear: int = 0

var engine_force = 0.0
var throttle_input
var brake_input

func _process(delta: float) -> void:
	throttle_input = Input.get_action_strength("car_force") - Input.get_action_strength("car_break")
	brake_input = Input.get_action_strength("car_break")

func _physics_process(delta: float) -> void:
	if Vehicle:
		current_speed = Vehicle.linear_velocity.length() * 3.6
		Vehicle.engine_force = engine_force
		EngineController()
		
		# Limita a velocidade com base na marcha atual
		if current_speed > Gears[current_gear]:
			Vehicle.linear_velocity = Vehicle.linear_velocity.normalized() * (Gears[current_gear] / 3.6)  # Converte km/h para m/s

		
		$"../../Debug/VBoxContainer/Speed".text = "SPEED LINEAR: " + str(Vehicle.linear_velocity.length())
		$"../../Debug/VBoxContainer/SpeedKM".text = "SPEED KM/H: " + str(current_speed)

func EngineController():
	EngineForceController()
	handleGearShift()

func EngineForceController():
	if throttle_input:
		engine_force = throttle_input * engine_power
	else:
		engine_force = 0

func handleGearShift():
	if Input.is_action_just_released("upshift") and current_gear < Gears.size() - 1:
		current_gear += 1
		RPM.gear_change()
	elif Input.is_action_just_released("downshift") and current_gear > 0:
		current_gear -= 1
		RPM.gear_change()
