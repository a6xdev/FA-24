extends Node
class_name TransmissionSystem

@export var BodyNode: BodyController

@export_group("Engine Settings")
@export var is_engine_on: bool = true
@export var HP: int = 200

@export_group("Transmission System")
@export var automatic_gear: bool = false
@export var Gears: Array[int] = [-1, 0, 1, 2, 3, 4, 5, 6]

var current_gear = 0
var is_reversing: bool = false
var in_neutral: bool = false

var speed_limit: Array[int] = [50, 0, 120, 160, 200, 240, 290, 350]
var engine_force: float = 0.0 
var torque: float = 0.0
var rpm: float = 0.0
var downforce: float = 0.0
var weight: float = 1000.0
var ERS: float = 0.0

var velocity: float = 0.0
var acceleration: float = 0.0

@export_group("RPM")
@export var max_rpm: float = 14000
@export var min_rpm: float = 1000
@export var idle_rpm: float = 500

func _process(delta: float) -> void:
	UpdateTorque()
	TransmissionController()
	UpdateDynamic(delta)
	UpdateRPM(delta)
	
#	Onde passa as informações desse Node para o Node principal
	BodyNode.current_gear = current_gear
	BodyNode.current_rpm = rpm

# <--------------------------------------------->

func get_gear_ratio() -> float:
	return 1.0 + (current_gear * 0.1)

# <--------------------------------------------->

func UpdateTorque() -> void:
	var power: float = HP * 745.7

	if rpm > 0:
		torque = (power * 9.5488) / rpm
	else:
		torque = 0.0

func TransmissionController():
	var current_gear_index: int = Gears.find(current_gear)

	if not automatic_gear:
		if Input.is_action_just_released("upshift"):
			if current_gear_index < Gears.size() - 1:
				current_gear_index += 1
				current_gear = Gears[current_gear_index]
		elif Input.is_action_just_released("downshift"):
			if current_gear_index > 0:
				current_gear_index -= 1
				current_gear = Gears[current_gear_index]

	if current_gear == 1:
		in_neutral = true
		is_reversing = false
	elif current_gear == 0:
		is_reversing = true
		in_neutral = false
	else:
		is_reversing = false
		in_neutral = false

func UpdateDynamic(delta) -> void:
	# Verifica se torque e gear_ratio não são Nil antes de calcular force_tires
	var gear_ratio: float = get_gear_ratio()
	if torque != null and gear_ratio != null:
		var force_tires: float = torque * gear_ratio / 1000.0
		var total_force: float = force_tires + downforce + ERS

		acceleration = total_force / weight
		engine_force += acceleration * delta
	else:
		print("Erro: torque ou gear_ratio é Nil.")

func UpdateRPM(delta) -> void:
	if is_engine_on:
		if torque != 0:
			var rpm_change = torque * delta * 100.0
			rpm += rpm_change

			if rpm > max_rpm:
				rpm = max_rpm
			elif rpm < min_rpm:
				rpm = min_rpm
		else:
			rpm = idle_rpm
	else:
		rpm = 0.0
