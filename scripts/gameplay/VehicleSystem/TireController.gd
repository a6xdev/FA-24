extends VehicleWheel3D

@export var BodyNode:BodyController
@export var PlayerConfigNode:PlayerConfig

@export_category("Tire Type")
@export var tire:TireType
enum TireType {
	SOFT,   # RED
	MEDIUM, # YELLOW
	HARD    # WHITE
}

@export_category("Tire Settings")
@export var max_grip: float = 2.5
@export var min_grip: float = 0.5

@export_group("Temperature")
@export var max_temperature: float = 120.0
@export var min_temperature: float = 20.0
@export var tire_heating_rate: float = 0.3  ## Taxa de aumento de temperatura por aceleração/frenagem
@export var tire_cooling_rate: float = 0.4  ## Taxa de resfriamento dos pneus
@export var heating_from_steering: float = 0.5 ## Aumento de temperatura baseado nas curvas
@export var ideal_temperature_min: float = 70.0
@export var ideal_temperature_max: float = 100.0

@export_group("GRIP")
@export var max_lateral_grip: float = 1.0  # Grip máximo lateral (para curvas)
@export var max_longitudinal_grip: float = 1.0  # Grip máximo longitudinal (aceleração/frenagem)
@export var grip_loss_rate: float = 0.1  # Quanto de grip é perdido em condições de baixa aderência (chuva, desgaste, etc.)

@export_group("Wear")
@export var wear_rate: float = 0.01  # Taxa de desgaste do pneu

var wear: float = 0.0  # Estado de desgaste do pneu
var temperature: float = 90  # Temperatura inicial

@export_category("Tire Audio Controller")
@export var TireScreechAudio: AudioStreamPlayer

var current_grip: float = max_grip  # Aderência atual do pneu

var TractionControl: bool = false

func _physics_process(delta: float) -> void:
	#print(current_grip)
	
	current_grip = max_grip
	TireTypeController()
	TemperatureController(delta)
	UpdateTireWear(delta)

	if TireScreechAudio:
		if get_skidinfo() <= 0.2:
			if not TireScreechAudio.playing:
				TireScreechAudio.play()
		else:
			TireScreechAudio.stop()

	wheel_friction_slip = current_grip  # Aplicar o grip atual
	
func TireTypeController() -> void:
	match tire:
		TireType.SOFT:
			tire_heating_rate = 0.5
			tire_cooling_rate = 0.4
			heating_from_steering = 3.5
			wear_rate = 0.05
		TireType.MEDIUM:
			tire_heating_rate = 0.3
			tire_cooling_rate = 0.4
			heating_from_steering = 3.0
			wear_rate = 0.02
		TireType.HARD:
			tire_heating_rate = 0.1
			tire_cooling_rate = 0.2
			heating_from_steering = 2.0
			wear_rate = 0.005

func TemperatureController(delta: float) -> void:
	var speed_factor = BodyNode.current_speed / 150
	var accel_input = Input.is_action_pressed("car_force")
	var brake_input = Input.is_action_pressed("car_brake")

	if accel_input or brake_input:
		temperature += tire_heating_rate * speed_factor * delta

	if BodyNode.steering != 0:
		temperature += heating_from_steering * delta * speed_factor

	if get_skidinfo() <= 0.3:
		temperature += (tire_heating_rate * 2) * speed_factor * delta

	temperature -= tire_cooling_rate * (1.0 - speed_factor) * delta
	temperature = clamp(temperature, min_temperature, max_temperature)

func UpdateTireWear(delta: float) -> void:
	var wear_factor: float = abs(BodyNode.current_speed) * abs(BodyNode.steering)
	wear += wear_rate * (temperature / 100) * delta
	wear = clamp(wear, 0.0, 1.0)
