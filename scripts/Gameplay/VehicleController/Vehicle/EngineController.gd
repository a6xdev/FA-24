extends Node
class_name TransmissionSystem

@export var BodyNode:BodyController

@export_group("Vehicle Flags")
@export var is_engine_on:bool = true

@export_group("Transmission System")
@export var automatic_gear:bool = false
@export var Gears: Array[int] = [-1, 0, 1, 2, 3, 4, 5, 6]

var current_gear = 0
var is_reversing:bool = false
var in_neutral:bool = false

var speed_limit:Array[int] = [50, 0, 120, 160, 200, 240, 290, 350]
var engine_force

var engine_power
var torque
var rpm
var downforce
var weight
var ERS

var velocity: float = 0.0
var acceleration: float = 0.0

@export_group("RPM")
@export var max_rpm:float = 14000
@export var min_rpm:float = 1000
@export var idle_rpm:float = 0

func _process(delta: float) -> void:
	TransmissionController()
	BodyNode.current_gear = current_gear

func TransmissionController():
	var current_gear_index:int = Gears.find(current_gear)
	
	if not automatic_gear:
		if Input.is_action_just_released("upshift"):
			if current_gear_index < Gears.size() -1:
				current_gear_index += 1
				current_gear = Gears[current_gear_index]
		elif Input.is_action_just_released("downshift"):
			if current_gear_index > 0:
				current_gear_index -= 1
				current_gear = Gears[current_gear_index]
	
	if current_gear == 1:
		in_neutral = true
		is_reversing = false
	elif current_gear == 0:
		is_reversing = true
		in_neutral = false
	else:
		is_reversing = false
		in_neutral = false

func UpdateDynamic(delta) -> void:
	var force_tires:float = torque * get_gear_ratio() / 1000.0
	var total_force:float = force_tires + downforce + ERS
	
	acceleration = total_force / weight
	engine_force += acceleration * delta

func UpdateRPM(delta) -> void:
	if is_engine_on:
		var rpm_change:float = torque * delta * 100.0
		
		rpm += rpm_change
		
		if rpm > max_rpm:
			rpm = max_rpm
		elif rpm < min_rpm:
			rpm = min_rpm
	else:
		rpm = idle_rpm

func get_gear_ratio() -> float:
	return 1.0 + (current_gear * 0.1)
