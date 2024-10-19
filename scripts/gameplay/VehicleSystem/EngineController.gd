extends Node
class_name EngineController

@export var BodyNode: BodyController
@export var PlayerConfigNode:PlayerConfig

@export_group("Engine Settings")
@export var is_engine_on: bool = true
@export var HP: int = 790
@export var ERS_on:bool = false

@export_group("Transmission System")
@export var Gears: Array[int] = [-1, 0, 1, 2, 3, 4, 5, 6]

var current_gear = 0
var is_reversing: bool = false
var in_neutral: bool = false
var is_braking:bool = false

@export_group("Acceleration and Speed Limits")
@export var acceleration_rates: Array[int] = [1000,15000, 5000, 6000, 7000, 5000, 4000, 3000]
@export var speed_limit:Array[int] = [50, 0, 124, 152, 180, 208, 273, 302]
	#								  R,  N,  1°,  2°,  3°,  4°,  5°,  6°

@export_group("RPM")
@export var max_rpm: float = 14900
@export var min_rpm: float = 1000
@export var idle_rpm: float = 500
@export var deceleration_rate: float = 300.0
#@export var gear_ratios: Array = [3.5, 2.8, 2.0, 1.5, 1.2, 1.0]
@export var gear_ratios: Array = [2.0, 1.4, 1.2, 1.0, 1.1, 1.2, 1.3]
#								  1°,  2°,  3°,  4°,  5°,  6°

@export_group("Tires")
@export var BackTireLeft: VehicleWheel3D
@export var BackTireRight: VehicleWheel3D
@export var FrontTireLeft: VehicleWheel3D
@export var FrontTireRight: VehicleWheel3D

@export_group("Brake Settings")
@export var brake_force:float = 0
@export_subgroup("Brake Temperature")
@export var max_brake_temperature: float = 1000.0
@export var min_brake_temperature: float = 20.0
@export var brake_temperature_increase_rate: float = 50.0
@export var brake_temperature_cooldown_rate: float = 30.0
var brake_temperature:float = min_brake_temperature

@export_subgroup("Brake ABS")
@export var wheel_slip_threshold: float = 0.5 

@export_group("Aerodynamic")
@export var drag_coefficient:float = 0.25

var torque: float = 0.0
var rpm: float = 0.0
var downforce: float = 200.0
var weight: float = 798.0
var ERS: float = 150.0
var DRS: float = 100.0

var acceleration: float = 0.0
var engine_force: float = 0.0  # Inicializa a força do motor

var can_shift_gear:bool = true
var gear_change_timer:float = 0.0

# <--- Sistema de Tração do veiculo --->

@export_group("Traction Control")
var slip_threshold: float = 0.2

# <--------------------------------------------->

func _input(event: InputEvent) -> void:
	if event.is_action_released("test_key"):
		PlayerConfigNode.ERS = !PlayerConfigNode.ERS

func _physics_process(delta: float) -> void:
	if not BodyNode.debug:
		InputController(delta)
		UpdateTorque()
		TransmissionController()
		UpdateDynamic(delta)
		UpdateRPM(delta)
		
		BrakeController(delta)
	else:
		BackTireLeft.brake = 100
		BackTireRight.brake = 100

	# Passa as informações desse Node para o Node principal
	BodyNode.current_gear = current_gear
	BodyNode.current_rpm = rpm
	
	if not can_shift_gear:
		gear_change_timer += delta
		if gear_change_timer >= 1 :
			can_shift_gear = true
			gear_change_timer = 0.0
	
func InputController(delta:float):
	if PlayerConfigNode.automatic_gear:
		if Input.is_action_pressed("car_force"):
			if is_engine_on and rpm > 0 and not in_neutral and not is_reversing:
				BackTireLeft.engine_force = engine_force
				BackTireRight.engine_force = engine_force
			elif is_reversing and current_gear == -1:
				BackTireLeft.brake = brake_force
				BackTireRight.brake = brake_force
				
		elif Input.is_action_pressed("car_brake"):
			if is_reversing:
				BackTireLeft.engine_force = -engine_force / 5
				BackTireRight.engine_force = -engine_force / 5
			else:
				BackTireLeft.brake = brake_force
				BackTireRight.brake = brake_force
				FrontTireLeft.brake = brake_force
				FrontTireRight.brake = brake_force
				is_braking = true
		else:
			BackTireLeft.engine_force = 0.0
			BackTireRight.engine_force = 0.0
			BackTireLeft.brake = 0.0
			BackTireRight.brake = 0.0
			FrontTireLeft.brake = 0.0
			FrontTireRight.brake = 0.0
			is_braking = false
	else:
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
			if is_engine_on and rpm > 0 and not in_neutral and not is_reversing:
				BackTireLeft.engine_force = engine_force
				BackTireRight.engine_force = engine_force
			elif is_engine_on and is_reversing and rpm > 0:
				BackTireLeft.engine_force = -engine_force / 5
				BackTireRight.engine_force = -engine_force / 5
		else:
			BackTireLeft.engine_force = 0.0
			BackTireRight.engine_force = 0.0
		
		if current_gear <= 2 and current_gear > 0 and BodyNode.current_speed <= 100:
			if BodyNode.steering >= 0.4:
				if Input.is_action_pressed("car_force"):
					BackTireRight.engine_force *= 350
			elif BodyNode.steering <= -0.4:
				if Input.is_action_pressed("car_force"):
					BackTireLeft.engine_force *= 350

func UpdateTorque() -> void:
	var power: float = HP * 745.7

	if rpm > 0:
		var gear_multipier = clamp(1.5 - (current_gear * 0.2), 0.8, 1.5)
		torque = (power * 9550) / rpm
	else:
		torque = 0.0

	#if rpm >= max_rpm * 0.85:
		#var decrease_factor = (max_rpm - rpm) / (max_rpm * 0.1)
		#if current_gear >= 5:
			#decrease_factor = clamp(decrease_factor, 0.8, 1.0)
		#decrease_factor = clamp(decrease_factor, 0.3, 1.0)
		#torque *= decrease_factor
		
	torque = clamp(torque, 0, power / max_rpm * 9.5488)

func TransmissionController():
	var current_gear_index: int = Gears.find(current_gear)
	
	# <---- Troca de marcha manuel ---->
	if not PlayerConfigNode.automatic_gear:
		if Input.is_action_just_released("upshift"):
			if current_gear_index < Gears.size() - 1:
				current_gear_index += 1
				current_gear = Gears[current_gear_index]
				rpm *= 0.66
		elif Input.is_action_just_released("downshift"):
			if current_gear_index > 0:
				current_gear_index -= 1
				current_gear = Gears[current_gear_index]
				rpm *= 1.5
				engine_force -= (rpm / max_rpm) * 0.2 * weight
	else:
		# <---- Troca de marcha automatica (Gay?) --->
		if can_shift_gear:
			if rpm > 14000:
				current_gear_index += 1
				current_gear = Gears[current_gear_index]
				rpm *= 0.66
				can_shift_gear = false
			elif current_gear_index > 1 and BodyNode.current_speed < speed_limit[current_gear_index - 1]:
				current_gear_index -= 1
				current_gear = Gears[current_gear_index]
				rpm *= 1.5
				engine_force -= (rpm / max_rpm) * 0.2 * weight
				can_shift_gear = false
		
		# Se a velocidade for 0km/h e estiver na marcha 1, ela vai para a marcha 0.
		if BodyNode.current_speed == 0.0 and current_gear == 1 :
			current_gear_index -= 1
			current_gear = Gears[current_gear_index]
		
		if current_gear == 0:
			if Input.is_action_pressed("car_force"):
				current_gear_index += 1
				current_gear = Gears[current_gear_index]
			if Input.is_action_pressed("car_brake"):
				current_gear_index -= 1
				current_gear = Gears[current_gear_index]
		if current_gear == -1:
			if Input.is_action_pressed("car_force") and BodyNode.current_speed == 0.0:
				current_gear_index += 1
				current_gear = Gears[current_gear_index]
				
	if current_gear == -1:
		is_reversing = true
		in_neutral = false
	elif current_gear == 0:
		in_neutral = true
		is_reversing = false
	else:
		is_reversing = false
		in_neutral = false

func UpdateDynamic(delta) -> void:
	var gear_ratio: float = get_gear_ratio()
	
	if torque != null and gear_ratio != null:
		var force_tires: float = torque * gear_ratio
		var drag_force: float = 0.01 * drag_coefficient * (BodyNode.current_speed * BodyNode.current_speed)  # Menor arrasto
		var total_force: float = force_tires + downforce - drag_force
		
		if ERS_on:
			total_force += ERS
		
		acceleration = total_force / weight
		engine_force = acceleration * weight
		
		if BodyNode.current_speed >= speed_limit[current_gear + 1]:
			engine_force = 0.0
		
		if BodyNode.current_speed > 300:
			engine_force *= 0.90
		elif BodyNode.current_speed > 340:
			engine_force *= 0.85
		
		# Dimini a força do motor em curvas, para dar um aspecto mais realista
		var steering_angle = abs(BodyNode.steering)
		if steering_angle > 0.5:
			engine_force *= (1.0 - steering_angle / 150) # 150: max_steering_angle
		
		# Limita o RPM quando o carro está perdendo tração
		var tire_grip = (BackTireLeft.get_skidinfo() + BackTireRight.get_skidinfo()) / 2
		if tire_grip <= 0.1:
			rpm -= deceleration_rate * delta

func UpdateRPM(delta) -> void:
	var gear_index: int = max(current_gear + 1, 0)
	var acceleration_rate = acceleration_rates[gear_index]
	
	if is_engine_on:
		if Input.is_action_pressed("car_force"):
			var rpm_change = acceleration_rate * delta
			rpm += rpm_change
			if rpm > max_rpm:
				rpm = max_rpm
		elif Input.is_action_pressed("car_brake") and is_reversing:
			var rpm_change = (acceleration_rate * 2) * delta
			rpm += rpm_change
			if rpm > 4000:
				rpm = 4000
		else:
			rpm -= deceleration_rate * delta
			if rpm < min_rpm:
				rpm = min_rpm
	else:
		rpm -= (deceleration_rate * 2) * delta
		if rpm < 0.0:
			rpm = 0.0
	
	var random_fluctuation = randf_range(-5, 5)
	rpm += random_fluctuation
	rpm = clamp(rpm, min_rpm, max_rpm)

# <---------------------------------------------->
# 	<-----------------BRAKE----------------->
# <---------------------------------------------->

func BrakeController(delta:float) -> void:
	if is_braking and rpm > min_rpm:
		rpm -= deceleration_rate * delta * 2
		if rpm < min_rpm:
			rpm = min_rpm

# <---------------------------------------------->
# 	<-----------------Traction----------------->
# <---------------------------------------------->

func get_gear_ratio() -> float:
	if current_gear == 0:
		return 0.0
	
	if current_gear == 7:
		return 1.3
	
	if current_gear > 0 and current_gear < gear_ratios.size():
		return gear_ratios[current_gear - 1]
	return 1.
