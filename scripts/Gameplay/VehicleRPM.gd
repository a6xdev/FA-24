extends Node
class_name VehicleRPM

@export var Vehicle:VehicleBody3D
@export var VEngine = null

@export_group("RPM Settings")
@export var max_rpm: float = 14000.0  # RPM máximo do motor
@export var acceleration_rate: float = 500.0  # A taxa de aumento de RPM ao acelerar
@export var deceleration_rate: float = 300.0  # A taxa de redução de RPM ao desacelerar

var RPM_C:int = 0 
var acceleration_rates:Array[int] = [8000,6000,4000,3000,2000,1000]

@export_group("DEBUG")
@export var COlOR_RECT:ColorRect

var current_state:state = state.WHITE
enum state {
	WHITE,
	GREEN, # ponto ideal para performance.
	RED, # Atenção que o limite está perto
	BLUE # Fudeu
}

func _process(delta: float) -> void:
	state_Controller()
	DEBUG()
	Vehicle.vehicle_rpm = RPM_C

func _physics_process(delta: float) -> void:
	RPM(delta)
	
func RPM(delta): # Define o RPM
	var throttle_input = Input.get_action_strength("car_force")
	if throttle_input > 0:
		RPM_C += acceleration_rate * delta
	else:
		RPM_C -= deceleration_rate * delta
	RPM_C = clamp(RPM_C, 0, max_rpm)

func state_Controller() -> void: # <-- Controla o State do RPM -->
	if  Vehicle.vehicle_rpm >= 14000:
		current_state = state.BLUE
		COlOR_RECT.modulate = Color('#003aff')
	elif Vehicle.vehicle_rpm >= 12000:
		current_state = state.RED
		COlOR_RECT.modulate = Color('#ff0000')
	elif Vehicle.vehicle_rpm >= 10000:
		current_state = state.GREEN
		COlOR_RECT.modulate = Color('#04ff00')
	else:
		current_state = state.WHITE
		COlOR_RECT.modulate = Color('#ffffff')

func gear_change(): # Mudança de marcha. Diminui o RPM em 1/3 e modifica a taxa de aceleração.
	RPM_C *= 2.0 / 3.5
	acceleration_rate = acceleration_rates[VEngine.current_gear]

func DEBUG():
	match current_state:
		state.WHITE:
			$"../../Debug/VBoxContainer/CurrentRPMstate".text = "WHITE"
		state.GREEN:
			$"../../Debug/VBoxContainer/CurrentRPMstate".text = "GREEN"
		state.RED:
			$"../../Debug/VBoxContainer/CurrentRPMstate".text = "RED"
		state.BLUE:
			$"../../Debug/VBoxContainer/CurrentRPMstate".text = "BLUE"
