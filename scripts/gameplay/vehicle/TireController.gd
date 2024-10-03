extends VehicleWheel3D

@export var PlayerConfigNode:PlayerConfig
# Script para controlar um único pneu

@export var max_grip: float = 1.0  # Aderência máxima do pneu
@export var wear_rate: float = 0.01  # Taxa de desgaste do pneu
@export var temperature: float = 20.0  # Temperatura inicial do pneu
@export var max_temperature: float = 100.0  # Temperatura máxima que o pneu pode alcançar
@export var min_grip: float = 0.5  # Aderência mínima devido ao desgaste ou temperatura

var current_grip: float = max_grip  # Aderência atual do pneu
var wear: float = 0.0  # Nível de desgaste do pneu

func _physics_process(delta: float) -> void:
	wheel_friction_slip = max_grip
	update_tire(delta, self.engine_force * 3.6, self.wheel_friction_slip)
	
func update_tire(delta: float, current_speed: float, wheel_slip: float):
	var acceleration_input = Input.is_action_pressed("car_force")
	
	if PlayerConfigNode.TractionControl:
		apply_traction_control(acceleration_input, self.get_rpm(), current_speed)

func apply_traction_control(acceleration_input: float, wheel_rpm: float, current_speed: float) -> float:
	var slip_ratio = wheel_rpm / (current_speed + 1e-6)  # Calcular o deslizamento da roda
	if slip_ratio > current_grip:  # Se o deslizamento for maior que a aderência
		return acceleration_input * current_grip  # Limita o input de aceleração com base na aderência
	return acceleration_input  # Caso contrário, permite o input total
