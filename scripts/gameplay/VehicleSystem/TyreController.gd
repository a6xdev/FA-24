extends VehicleWheel3D

@export var BodyNode:BodyController
@export var EngineBody:EngineController
@export var AerodynamicsNode:AerodynamicsController
@export var PlayerConfigNode:PlayerConfig

@export_category("Tire Type")
@export var tire:TireType
enum TireType {
	SOFT,   # RED
	MEDIUM, # YELLOW
	HARD    # WHITE
}

@export_category("Tire Settings")
@export var max_grip: float = 3.0
@export var min_grip: float = 0.5

@export_group("Temperature")
@export var max_temperature: float = 120.0
@export var min_temperature: float = 70.0
@export var ideal_temperature_min: float = 85.0
@export var ideal_temperature_max: float = 100.0

var rear_rpm_heating_rate: float = 0.0005  # Taxa de aquecimento do RPM
var corner_heating_rate: float = 2.0  # Taxa de aquecimento em curvas
var brake_heating_rate: float = 0.9  # Taxa de aquecimento na frenagem
var throttle_heating_rate: float = 0.15  # Taxa de aquecimento na aceleração
var air_cooling_factor: float = 0.005  # Fator de resfriamento pelo ar

@export_group("GRIP")
@export var max_lateral_grip: float = 1.0  # Grip máximo lateral (para curvas)
@export var max_longitudinal_grip: float = 1.0  # Grip máximo longitudinal (aceleração/frenagem)
@export var grip_loss_rate: float = 0.1  # Quanto de grip é perdido em condições de baixa aderência (chuva, desgaste, etc.)

@export_group("Pressure")
@export var ideal_pressure: float = 32.0  # Pressão ideal do pneu (em PSI)
@export var min_pressure: float = 20.0
@export var max_pressure: float = 28.0

@export_group("Wear")
@export var wear_rate: float = 0.01  # Taxa de desgaste do pneu

@export_category("Tire Audio Controller")
@export var TireScreechAudio: AudioStreamPlayer

@export_category("Interface")
@export var TyreUI:TyreObjectUI

var current_grip: float = max_grip
var TractionControl: bool = false
var wear: float = 100.0
var temperature: float = 90.0
var tire_pressure: float = min_pressure

func _physics_process(delta: float) -> void:
	TireTypeController()
	GripUpdate()
	TemperatureController(delta)
	UpdateTireWear(delta)
	update_pressure_effect(delta)

	if TireScreechAudio:
		if get_skidinfo() <= 0.2:
			if not TireScreechAudio.playing:
				TireScreechAudio.play()
		else:
			TireScreechAudio.stop()

	wheel_friction_slip = current_grip
	
	TyreUI.psi = tire_pressure
	TyreUI.temperature = temperature
	TyreUI.wear = wear
	$"../PlayerInterface/FPS2".text = "GRIP: " + str(current_grip)
	print(self.name, ": ", self.steering)

func GripUpdate() -> void:
	#var pressure_factor: float = 1.0
	#if tire_pressure < ideal_pressure:
		#pressure_factor = lerp(0.8, 1.0, tire_pressure / ideal_pressure)
	#elif tire_pressure > ideal_pressure:
		#pressure_factor = lerp(1.0, 0.8, (tire_pressure - ideal_pressure) / (max_pressure - ideal_pressure))
	
	#var temperature_factor: float = 1.0
	#if temperature < ideal_temperature_min:
		#temperature_factor = lerp(0.7, 1.0, (temperature - min_temperature) / (ideal_temperature_min - min_temperature))
	#elif temperature > ideal_temperature_max:
		#temperature_factor = lerp(1.0, 0.7, (temperature - ideal_temperature_max) / (max_temperature - ideal_temperature_max))
#

	var wear_factor: float = (wear / 100)

	current_grip = max_grip * wear_factor
	current_grip = clamp(current_grip, min_grip, max_grip)

	
func TireTypeController() -> void:
	match tire:
		TireType.SOFT:
			wear_rate = 1.2
		TireType.MEDIUM:
			wear_rate = 0.002
		TireType.HARD:
			wear_rate = 0.0005

func TemperatureController(delta: float) -> void:
	temperature += rear_rpm_heating_rate * get_rpm() * delta
	
	var steering_angle = abs(self.steering)
	if steering_angle > 0.1:
		temperature += corner_heating_rate * steering_angle * delta
		
	if EngineBody.is_braking:
		temperature += brake_heating_rate * delta
	if EngineBody.is_accelerating:
		temperature += throttle_heating_rate * delta

	var air_cooling = air_cooling_factor * BodyNode.current_speed
	temperature -= air_cooling * delta
	temperature = clamp(temperature, min_temperature, max_temperature)

func UpdateTireWear(delta: float) -> void:
	var steering_factor = abs(self.steering) * 0.1
	var speed_factor = clamp(BodyNode.current_speed / 200, 0, 1)
	var temp_factor = (temperature / max_temperature)

	wear -= wear_rate * temp_factor * (1 + steering_factor + speed_factor) * delta * 0.05
	wear = clamp(wear, 0.0, 100.0)

func update_pressure_effect(delta: float) -> void:
	var air_pressure_effect = AerodynamicsNode.air_density * AerodynamicsNode.friction_loss * BodyNode.current_speed * 0.00005
	var rolling_resistance_effect = AerodynamicsNode.rolling_resistance * BodyNode.current_speed * 0.00002

	if temperature > ideal_temperature_max:
		tire_pressure -= (0.02 * (temperature - ideal_temperature_max) + air_pressure_effect + rolling_resistance_effect) * delta
	elif temperature < ideal_temperature_min:
		tire_pressure += (0.01 * (ideal_temperature_min - temperature)) * delta

	tire_pressure = clamp(tire_pressure, min_pressure, max_pressure)
