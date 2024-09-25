extends Node
class_name BroadcastNode
# Controle do RPM do motor, incluindo sistema de aceleração e desaceleração. Marcha ré e neutra.

@export var VehicleEngine:EngineNode

@export_group("Broadcast Settings")
@export var automatic_gear:bool = false
@export var Gears: Array[int] = [-1, 0, 80, 140, 200, 250, 300, 350]
var current_gear: int = 1

func _process(delta: float) -> void:
	handleGearShift()
	
func handleGearShift():
	if not automatic_gear:
		if Input.is_action_just_released("upshift") and current_gear < Gears.size() - 1:
			current_gear += 1
			VehicleEngine.GearChange()
		elif Input.is_action_just_released("downshift") and current_gear > 0:
			current_gear -= 1
			VehicleEngine.GearChange()
