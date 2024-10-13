extends Control

@export var PlayerConfigNode:PlayerConfig

# Controls
@onready var steer_slider: HSlider = $TabContainer/Controls/MarginContainer/VBoxContainer/SteerSensititivy/SteerSlider
@onready var steer_value: Label = $TabContainer/Controls/MarginContainer/VBoxContainer/SteerSensititivy/Value
@onready var accel_slider: HSlider = $TabContainer/Controls/MarginContainer/VBoxContainer/AccelSensititivy/AccelSlider
@onready var accel_value: Label = $TabContainer/Controls/MarginContainer/VBoxContainer/AccelSensititivy/Value

# Difficulty
@onready var ABS: CheckBox = $TabContainer/Difficulty/MarginContainer/VBoxContainer/ABS/CheckBox
@onready var traction_control: CheckBox = $TabContainer/Difficulty/MarginContainer/VBoxContainer/TractionControl/CheckBox2
@onready var automatic_gear: CheckBox = $TabContainer/Difficulty/MarginContainer/VBoxContainer/AutomaticGear/CheckBox2

func _process(delta: float) -> void:
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
