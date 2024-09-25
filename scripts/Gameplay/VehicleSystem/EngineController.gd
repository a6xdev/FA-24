extends Node
class_name EngineNode
#Controle do Motor e calculo do Torque baseado no RPM, Aceleração e conexão com o sistema de transmissão.

@export var Broadcast:BroadcastNode

var RPM_STATE:state = state.WHITE
enum state {
	WHITE,
	GREEN, # ponto ideal para performance.
	RED, # Atenção que o limite está perto
	BLUE # Fudeu
}

@export_group("RPM Settings")
@export var max_rpm: float = 14000.0  # RPM máximo do motor
var acceleration_rate: float  # A taxa de aumento de RPM ao acelerar
@export var deceleration_rate: float = 300.0  # A taxa de redução de RPM ao desacelerar
@export var idle_rpm = 3000
@export var acceleration_rates:Array[int] = [10000,5000,4000,3000,2000,1000, 500]

@export_group("DEBUG")
@export var COlOR_RECT:ColorRect

var R_RPM:int = 0

func _process(delta: float) -> void:
	EngineUpdate(delta)
	RPM_STATE_CONTROLLER()

func EngineUpdate(delta):
	#current_speed = Vehicle.linear_velocity.length() * 3.6
	var input = Input.get_axis("car_brake", "car_force")
	if input > 0:
		R_RPM += acceleration_rate * delta
	else:
		R_RPM -= deceleration_rate * delta
	R_RPM = clamp(R_RPM, idle_rpm, max_rpm)
	
	acceleration_rate = acceleration_rates[Broadcast.current_gear]
	
func GearChange(): # Mudança de marcha. Diminui o RPM em 1/3 e modifica a taxa de aceleração.
	R_RPM *= 2.0 / 3.0

func RPM_STATE_CONTROLLER() -> void: # <-- Controla o State do RPM -->
	if  R_RPM >= 14000:
		RPM_STATE = state.BLUE
		COlOR_RECT.modulate = Color('#003aff')
	elif R_RPM >= 12000:
		RPM_STATE = state.RED
		COlOR_RECT.modulate = Color('#ff0000')
	elif R_RPM >= 10000:
		RPM_STATE = state.GREEN
		COlOR_RECT.modulate = Color('#04ff00')
	else:
		RPM_STATE = state.WHITE
		COlOR_RECT.modulate = Color('#ffffff')
