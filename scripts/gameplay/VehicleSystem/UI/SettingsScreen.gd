extends Control

@export var PlayerConfigNode:PlayerConfig

var is_game_paused:bool = false

@export_group("Interface Adicionais")
@export var CarUI:Control

# Controls
@onready var steer_slider: HSlider = $TabContainer/Controls/MarginContainer/VBoxContainer/SteerSensititivy/SteerSlider
@onready var steer_value: Label = $TabContainer/Controls/MarginContainer/VBoxContainer/SteerSensititivy/Value
@onready var accel_slider: HSlider = $TabContainer/Controls/MarginContainer/VBoxContainer/AccelSensititivy/AccelSlider
@onready var accel_value: Label = $TabContainer/Controls/MarginContainer/VBoxContainer/AccelSensititivy/Value

# Difficulty
@onready var ABS: CheckBox = $TabContainer/Difficulty/MarginContainer/VBoxContainer/ABS/CheckBox
@onready var traction_control: CheckBox = $TabContainer/Difficulty/MarginContainer/VBoxContainer/TractionControl/CheckBox2
@onready var automatic_gear: CheckBox = $TabContainer/Difficulty/MarginContainer/VBoxContainer/AutomaticGear/CheckBox2

func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		is_game_paused = !is_game_paused
		
#func _ready() -> void:
	#self.visible = false

# <---------------------------------------------------->
# <---------------------------------------------------->
# <---------------------------------------------------->
func _process(delta: float) -> void:
	if is_game_paused:
		get_tree().paused = true
		self.visible = true
		CarUI.visible = false
	else:
		get_tree().paused = false
		self.visible = false
		CarUI.visible = true
		
	# Controls
	PlayerConfigNode.steer_sensitivity = steer_slider.value
	steer_value.text = str(steer_slider.value)
	PlayerConfigNode.accelerometer_sensitivity = accel_slider.value
	accel_value.text = str(accel_slider.value)

	
	# Difficulty
func ABS_toggled(toggled_on: bool) -> void:
	PlayerConfigNode.ABS = !PlayerConfigNode.ABS
func TractionControl_toggled(toggled_on: bool) -> void:
	PlayerConfigNode.TractionControl = !PlayerConfigNode.TractionControl
func automaticGear_toggled(toggled_on: bool) -> void:
	PlayerConfigNode.automatic_gear = !PlayerConfigNode.automatic_gear

func _on_back_toggled(toggled_on: bool) -> void:
	is_game_paused = false
	get_tree().paused = false
	self.visible = false
	CarUI.visible = true
