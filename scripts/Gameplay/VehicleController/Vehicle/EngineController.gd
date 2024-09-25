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

@export_group("Acceleration and Speed Limits")
@export var acceleration_rates: Array[int] = [1000,10000, 5000, 4000, 3000, 2000, 1000, 500]

var torque: float = 0.0
var rpm: float = 0.0
var downforce: float = 0.0
var weight: float = 1000.0
var ERS: float = 0.0

var acceleration: float = 0.0
var engine_force: float = 0.0  # Inicializa a força do motor

@export_group("RPM")
@export var max_rpm: float = 14000
@export var min_rpm: float = 1000
@export var idle_rpm: float = 500
@export var deceleration_rate: float = 300.0

@export_group("Tires")
@export var BackTireLeft: VehicleWheel3D
@export var BackTireRight: VehicleWheel3D

func _physics_process(delta: float) -> void:
	UpdateTorque()
	TransmissionController()
	UpdateDynamic(delta)
	UpdateRPM(delta)

	# Passa as informações desse Node para o Node principal
	BodyNode.current_gear = current_gear
	BodyNode.current_rpm = rpm
	
	if Input.is_action_pressed("car_force"):
		if is_engine_on and rpm > 0 and not in_neutral and not is_reversing:
			BackTireLeft.engine_force = engine_force
			BackTireRight.engine_force = engine_force
	else:
		BackTireLeft.engine_force = 0.0
		BackTireRight.engine_force = 0.0
# <--------------------------------------------->

func get_gear_ratio() -> float:
	return 1.0 + (current_gear * 0.1)

# <--------------------------------------------->

func UpdateTorque() -> void:
	var power: float = HP * 745.7

	if rpm > 0:
		# Calcula o torque base
		torque = (power * 9.5488) / max_rpm
	else:
		torque = 0.0

	if rpm >= max_rpm * 0.9:
		var decrease_factor = (max_rpm - rpm) / (max_rpm * 0.1)
		if current_gear >= 5:
			decrease_factor = clamp(decrease_factor, 0.8, 1.0)
		decrease_factor = clamp(decrease_factor, 0.5, 1.0)
		torque *= decrease_factor
		
	torque = clamp(torque, 0, power / max_rpm * 9.5488)


func TransmissionController():
	var current_gear_index: int = Gears.find(current_gear)

	if not automatic_gear:
		if Input.is_action_just_released("upshift"):
			if current_gear_index < Gears.size() - 1:
				current_gear_index += 1
				current_gear = Gears[current_gear_index]
				rpm *= 2.0 / 3.0
		elif Input.is_action_just_released("downshift"):
			if current_gear_index > 0:
				current_gear_index -= 1
				current_gear = Gears[current_gear_index]
				rpm *= 2.0 / 3.0

	if current_gear == 0:
		in_neutral = true
		is_reversing = false
	elif current_gear == -1:
		is_reversing = true
		in_neutral = false
	else:
		is_reversing = false
		in_neutral = false

func UpdateDynamic(delta) -> void:
	var gear_ratio: float = get_gear_ratio()
	
	if torque != null and gear_ratio != null:
		var force_tires: float = torque * gear_ratio
		var total_force: float = force_tires + downforce + ERS
		
		acceleration = total_force / weight  # Calcula a aceleração com base na força total
		engine_force = acceleration * weight  # A força do motor é baseada na aceleração e peso
	else:
		acceleration = 0.0
		engine_force = 0.0 


func UpdateRPM(delta) -> void:
	var gear_index:int = max(current_gear + 1, 0)
	var acceleration_rate = acceleration_rates[gear_index]
	
	if is_engine_on:
		if Input.is_action_pressed("car_force") or Input.is_action_pressed("car_brake"):
			var rpm_change = acceleration_rate * delta
			rpm += rpm_change
			if rpm > max_rpm:
				rpm = max_rpm
		else:
			rpm -= deceleration_rate * delta
			if rpm < min_rpm:
				rpm = min_rpm
	else:
		rpm -= (deceleration_rate * 2) * delta
		if rpm < 0.0:
			rpm = 0.0
