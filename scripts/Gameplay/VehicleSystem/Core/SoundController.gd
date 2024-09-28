extends Node
class_name SoundNode

@export var VehicleEngine:EngineController
@export var min_pitch = 0.8
@export var max_pitch = 1.5

@export_group("Sounds")
@export var EngineAudio:AudioStreamPlayer
	
func _ready() -> void:
	EngineAudio.play()

func _physics_process(delta: float) -> void:
	EngineSound()
	
func EngineSound():
	var rpm_ratio = VehicleEngine.rpm / VehicleEngine.max_rpm
	EngineAudio.pitch_scale = lerp(min_pitch, max_pitch, rpm_ratio)
