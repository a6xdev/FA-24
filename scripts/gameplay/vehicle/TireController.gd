extends VehicleWheel3D

@export var PlayerConfigNode:PlayerConfig

@export_group("Grip")
@export var max_grip: float = 3.0  # Aderência máxima do pneu
@export var min_grip: float = 0.5  # Aderência mínima devido ao desgaste ou temperatura
@export_group("Tire")
@export var wear_rate: float = 0.01  # Taxa de desgaste do pneu
@export var temperature: float = 70.0  # Temperatura inicial do pneu
@export var max_temperature: float = 120.0  # Temperatura máxima que o pneu pode alcançar

var current_grip: float = max_grip  # Aderência atual do pneu
var wear: float = 0.0  # Nível de desgaste do pneu

var TractionControl:bool = false

func _physics_process(delta: float) -> void:
	wheel_friction_slip = max_grip
