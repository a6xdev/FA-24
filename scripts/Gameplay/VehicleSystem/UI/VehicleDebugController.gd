extends Node
class_name DebugNode

@export var Broadcast:BroadcastNode
@export var VehicleEngine:EngineNode
@export var SpeedRef:SpeedNode
@export var SteeringNode:VehicleSteering

@export_group("Debug Label")
@export var CurrentGear:Label
@export var RPM:Label
@export var Speed:Label
@export var Gyro:Label
@export var FPSNode:Label

func _process(delta: float) -> void:
	CurrentGear.text = "Gear: " + str(Broadcast.current_gear)
	RPM.text = "RPM: " + str(VehicleEngine.R_RPM)
	Speed.text = "Speed: " + str(SpeedRef.current_speed)
	#Gyro.text = "GYRO: " + str(SteeringNode.gyro.z)
	FPSNode.text = "FPS: " + str(Engine.get_frames_per_second())
