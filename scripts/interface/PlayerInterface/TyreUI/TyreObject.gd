# TyreObjectUI.gd
extends ProgressBar
class_name TyreObjectUI

# Variáveis para representar os dados
var psi: int
var temperature: int
var wear: float

@onready var psi_label: Label = $psi
@onready var temperature_label: Label = $temperature

func _physics_process(delta: float) -> void:
	self.max_value = 100
	self.value = wear
	psi_label.text = str(psi) + " psi"
	temperature_label.text = str(temperature) + "°C"
