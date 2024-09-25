extends Node
class_name HudController

@export var BodyNode:BodyController

@export_group("HUD Controller")
@export var GearLabel:Label
@export var rpmLabel:Label
@export var SpeedLabel:Label

func _physics_process(delta: float) -> void:
	GearHUD()
	rpmHUD()
	SpeedHud()
	
func GearHUD():
	if BodyNode.current_gear == -1:
		GearLabel.text = "R"
	elif BodyNode.current_gear == 0:
		GearLabel.text = "N"
	else:
		GearLabel.text = str(BodyNode.current_gear)
		
func rpmHUD():
	rpmLabel.text = str(BodyNode.current_rpm)

func SpeedHud():
	SpeedLabel.text = str(BodyNode.current_speed)
