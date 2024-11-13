extends Node

@export var Tire:VehicleWheel3D
@export var caliper_node: Node3D
@export var bars: Node3D

func _physics_process(delta: float) -> void:
	caliper_node.rotation.z = -Tire.steering
	
