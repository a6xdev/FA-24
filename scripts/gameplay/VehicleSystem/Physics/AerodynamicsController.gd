extends Node
class_name AerodynamicsController

@export var VehicleBody:BodyController

@export var current_wing_type:WingType
@export var max_downforce: float = 1000.0 # Limite máximo de downforce para evitar valores absurdos

@export_group("Drag")
@export var drag_coefficient: float = 0.3  # Coeficiente de arrasto
@export var frontal_area: float = 2.2  # Área frontal em m²
@export var air_density: float = 1.225  # Densidade do ar em kg/m³ ao nível do mar
@export var max_drag_force: float = 500.0  # Limite máximo de força de arrasto

enum WingType {
	HIGH_AERO_WING, # Maximizar o downforce. Circuitos que possuem muitas curvas de baixa e média velocidade.
	LOW_AERO_WING, # Minimzar o downforce. Circuitos de alta velocidade com longas retas: Monza, Spa...
	MEDIUM_AERO_WING, # Equilibrio entre downforce e velocidade. Para circuitos com retas longas e curva de média velocidade.
	WET_WING # Para corridas em condições de chuva.
}

# Coeficientes de downforce e arrasto para cada tipo de asa
var downforce_coefficients = {
	WingType.HIGH_AERO_WING: 1.5,  # Mais downforce, maior pressão nas rodas
	WingType.LOW_AERO_WING: 0.05,   # Menos downforce, menor pressão
	WingType.MEDIUM_AERO_WING: 0.5, # Balanceado
	WingType.WET_WING: 2.0 # Mais downforce para ajudar na chuva
}

var drag_coefficients = {
	WingType.HIGH_AERO_WING: 0.005,  # Mais arrasto, menor velocidade máxima
	WingType.LOW_AERO_WING: 0.002,   # Menos arrasto, maior velocidade
	WingType.MEDIUM_AERO_WING: 0.003, # Equilibrado
	WingType.WET_WING: 0.004 # Um pouco mais de arrasto
}

var downforce: float = 0.0
var drag_force: float = 0.0

func _process(delta: float):
	DownforceController(delta)
	DragController(delta)

func DownforceController(delta: float) -> void:
	var downforce_coefficient = downforce_coefficients[current_wing_type]

	var current_speed_squared = VehicleBody.current_speed * VehicleBody.current_speed
	var target_downforce = downforce_coefficient * current_speed_squared * 0.01  # Ajuste a constante para ajuste fino

	if VehicleBody.current_speed == 0:
		target_downforce = 0.0

	downforce = clamp(target_downforce, 0, max_downforce)
	VehicleBody.constant_force = Vector3(0, 0, 0)
	VehicleBody.add_constant_force(Vector3(0, -downforce, 0))

	#print("Constan Force: ", VehicleBody.constant_force )

func DragController(delta: float) -> void:
	var current_speed_squared = VehicleBody.current_speed * VehicleBody.current_speed
	drag_force = 0.5 * drag_coefficient * air_density * frontal_area * current_speed_squared
	drag_force = clamp(drag_force, 0, max_drag_force)
#
	VehicleBody.add_constant_force(Vector3(0, 0, drag_force))
