extends Node
class_name HudController

@export var PlayerConfigNode:PlayerConfig
@export var BodyNode:BodyController

@export_group("HUD Controller")
@export var PlayerInterface:CanvasLayer
@export var GearLabel:Label
@export var rpmLabel:Label
@export var SpeedLabel:Label
@export var COLOR_RECT:ColorRect

@export_group("Steering Interface")
@export var SI_RPM:Label
@export var SI_GEAR:Label

@export_group("CarInputs Interface")
@export var throttle:ProgressBar
@export var brake:ProgressBar

var current_state:state = state.WHITE
enum state {
	WHITE,
	GREEN, # ponto ideal para performance.
	RED, # Atenção que o limite está perto
	BLUE # Fudeu
}

func _physics_process(delta: float) -> void:
	GearHUD()
	rpmHUD()
	SpeedHud()
	CarInputs()
	
func GearHUD():
	if BodyNode.current_gear == -1:
		GearLabel.text = "R"
		SI_GEAR.text = "R"
	elif BodyNode.current_gear == 0:
		GearLabel.text = "N"
		SI_GEAR.text = "N"
	else:
		GearLabel.text = str(BodyNode.current_gear)
		SI_GEAR.text = str(BodyNode.current_gear)
		
func rpmHUD():
	rpmLabel.text = str(BodyNode.current_rpm)
	SI_RPM.text = str(BodyNode.current_rpm)
	
	if  BodyNode.current_rpm >= 12000:
		current_state = state.BLUE
		COLOR_RECT.modulate = Color('#003aff')
	elif BodyNode.current_rpm >= 11000:
		current_state = state.RED
		COLOR_RECT.modulate = Color('#ff0000')
	elif BodyNode.current_rpm >= 10000:
		current_state = state.GREEN
		COLOR_RECT.modulate = Color('#04ff00')
	else:
		current_state = state.WHITE
		COLOR_RECT.modulate = Color('#ffffff')

func SpeedHud():
	SpeedLabel.text = str(BodyNode.current_speed)

func CarInputs():
	throttle.value = BodyNode.throttle_input
	brake.value = BodyNode.brake_input
