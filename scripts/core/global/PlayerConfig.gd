extends Node
class_name PlayerConfig

@export var save_path = "res://data/"
@export var paused:bool = false

# Configurações do jogador local
@export var steer_sensitivity:float = 1.0
@export var accelerometer_sensitivity:float = 1.0
@export var volume:float = 1.0
@export var screen_resolution:Vector2 = Vector2(1920, 1080)
@export var audio_settings = {
	"music_volume": 1.0,
	"engine_volume": 1.0,
	"tire_volume": 1.0
}

# Configurações do carro
@export var ABS:bool = false
@export var TractionControl:bool = false
@export var automatic_gear:bool = false

# <------------------------------------------------------------------------->
# Data
# <------------------------------------------------------------------------->

func save_config():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var({
		"steer_sensitivity": steer_sensitivity,
		"accelerometer_sensitivity": accelerometer_sensitivity,
		"volume": volume,
		"screen_resolution": screen_resolution,
		"audio_settings": audio_settings
	})

func load_config():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var data = file.get_var()
		
		steer_sensitivity = data.get("steer_sensitivity", 1.0)
		accelerometer_sensitivity = data.get("accelerometer_sensitivity", 1.0)
		volume = data.get("volume", 1.0)
		screen_resolution = data.get("screen_resolution", Vector2(1920, 1080))
		audio_settings = data.get("audio_settings", {
			"music_volume": 1.0,
			"engine_volume": 1.0,
			"tire_volume": 1.0
		})
	else:
		print("No data saved. Sorry litle driver :<")
		steer_sensitivity = 0
		accelerometer_sensitivity = 0
		volume = 0
		screen_resolution = Vector2(0,0)
		audio_settings = 0
