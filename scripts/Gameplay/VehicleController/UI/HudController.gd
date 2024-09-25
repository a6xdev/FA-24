extends Node
class_name HudController

@export var BodyNode:BodyController

@export_group("HUD Controller")
@export var GearLabel:Label

func _physics_process(delta: float) -> void:
	GearHUD()
	
func GearHUD():
	if BodyNode.current_gear == -1:
		GearLabel.text = "R"
	elif BodyNode.current_gear == 0:
		GearLabel.text = "N"
	else:
		GearLabel.text = str(BodyNode.current_gear)
