extends Camera3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

enum CameraMode {
	COCKPIT,
	TV_POD,
}

@export var current_camera_mode = CameraMode.TV_POD
var is_looking_back = false  # Flag para saber se está olhando para trás

func _process(delta: float) -> void:
	# Se o jogador pressiona o botão "look back"
	if Input.is_action_just_pressed("look_back") and not is_looking_back:
		animation_player.play("LOOK_BACK")
		is_looking_back = true
	
	# Se o jogador solta o botão "look back"
	if Input.is_action_just_released("look_back") and is_looking_back:
		# Retorna para a câmera atual (pode ser cockpit ou TV pod)
		match current_camera_mode:
			CameraMode.COCKPIT:
				animation_player.play("COCKPIT")
			CameraMode.TV_POD:
				animation_player.play("TV_POD")
		is_looking_back = false

func _input(event: InputEvent) -> void:
	# Quando o botão para trocar a câmera é pressionado
	if event.is_action_released("SwitchCamera"):
		SwitchCamera()

func SwitchCamera():
	match current_camera_mode:
		CameraMode.COCKPIT:
			animation_player.play("TV_POD")
			current_camera_mode = CameraMode.TV_POD
		CameraMode.TV_POD:
			animation_player.play("COCKPIT")
			current_camera_mode = CameraMode.COCKPIT
