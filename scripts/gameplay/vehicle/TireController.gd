extends VehicleWheel3D

@export var PlayerConfigNode:PlayerConfig
@export var DeslizePneu:float = 0.6

@export_group("Grip")
@export var max_grip: float = 3.0  # Aderência máxima do pneu
@export var min_grip: float = 0.5  # Aderência mínima devido ao desgaste ou temperatura
@export_group("Tire")
@export var wear_rate: float = 0.01  # Taxa de desgaste do pneu
@export var temperature: float = 70.0  # Temperatura inicial do pneu
@export var max_temperature: float = 120.0  # Temperatura máxima que o pneu pode alcançar

@export_category("Tire Audio Controller")
@export var TireScreechAudio:AudioStreamPlayer

var current_grip: float = max_grip  # Aderência atual do pneu
var wear: float = 0.0  # Nível de desgaste do pneu

var TractionControl:bool = false

func _physics_process(delta: float) -> void:
	if TireScreechAudio:
		if get_skidinfo() <= DeslizePneu:
			TireScreechAudio.play()
		else:
			TireScreechAudio.stop()
		
	wheel_friction_slip = max_grip
