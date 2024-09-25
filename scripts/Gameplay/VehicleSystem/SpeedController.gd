extends Node
class_name SpeedNode

@export var Vehicle:VehicleBody3D
@export var Broadcast:BroadcastNode
@export var VehicleEngine:EngineNode
@export var Steering:VehicleSteering

@export_group("Engine Settings")
@export var torque:int = 50
@export var gear_ratio = 4.0  # Relação de transmissão

@export_group("Braking Settings")
@export var max_brake_force: float = 1000.0  # Força máxima de frenagem
@export var handbrake_force = 0  # Força do freio de mão.
@export_subgroup("ABS")
@export var abs_threshold: float = 0.3  # Limite de velocidade para ativação do ABS
@export var abs_release_time: float = 0.1  # Tempo de liberação do freio
@export var abs_pulse_rate: float = 0.05  # Taxa de pulsação do ABS
var brake_force: float = 0.0
var is_abs_active: bool = false
var last_brake_time: float = 0.0

@export_group("Wheel Settings")
@export var wheelbase = 2.5
@export var track_width = 1.5
@export_subgroup("Set Wheel")
@export var BackLeftWheel: VehicleWheel3D
@export var BackRightWheel: VehicleWheel3D

var engine_power = 100
var current_speed:int
var engine_force

var throttle_input
var brake_input

func _process(delta: float) -> void:
	SpeedUpdate(delta)
	throttle_input = Input.get_action_strength("car_force")
	brake_input = Input.get_action_strength("car_brake")
	
func SpeedUpdate(delta):
	EngineForceController()
	calculate_torque(VehicleEngine.R_RPM)
	apply_differential()
	
	if Vehicle:
		engine_power = (torque * VehicleEngine.R_RPM / 5252) * 2
		current_speed = Vehicle.linear_velocity.length() * 3.6
		BackLeftWheel.engine_force = engine_force
		BackRightWheel.engine_force = engine_force
		
		if current_speed > Broadcast.Gears[Broadcast.current_gear]:
			var target_speed = Broadcast.Gears[Broadcast.current_gear] / 3.6
			var current_velocity = Vehicle.linear_velocity.length()
			var lerped_speed = lerp(current_velocity, target_speed, delta * 5)

			var new_velocity = Vehicle.linear_velocity.normalized() * lerped_speed
			Vehicle.linear_velocity = new_velocity
			if abs(Vehicle.steering) > 0.1:
				var brake_force = 0.1 * (current_velocity - target_speed)
				Vehicle.linear_velocity -= Vehicle.linear_velocity.normalized() * brake_force * delta 

func EngineForceController():
	if throttle_input:
		engine_force = throttle_input * engine_power
	else:
		engine_force = 0
		
	if brake_input:
		brake_force = -max_brake_force * brake_input

func calculate_torque(rpm: float) -> float:
	if rpm < 3000:
		return 200  # Torque em baixas rotações
	elif rpm < 6000:
		return 400  # Torque máximo na faixa intermediária
	else:
		return 250  # Torque reduzido em rotações altas

func apply_differential():
	if throttle_input:
		var steer_ratio = abs(Steering.max_steer_angle) / Steering.max_steer_angle
		var left_wheel_force = throttle_input * engine_power * (1.0 - steer_ratio / 2.0)
		var right_wheel_force = throttle_input * engine_power * (1.0 + steer_ratio / 2.0)
		BackLeftWheel.engine_force = left_wheel_force
		BackRightWheel.engine_force = right_wheel_force
