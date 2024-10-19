extends Camera3D

@export var BodyNode:BodyController

@onready var animation_player: AnimationPlayer = $AnimationPlayer

enum CameraMode {
	COCKPIT,
	TV_POD,
}

@export var current_camera_mode = CameraMode.TV_POD
var is_looking_back = false  # Flag para saber se está olhando para trás

# Variável para armazenar o estado anterior da câmera de depuração
var previous_debug_camera = false

# <------------------------------------>
# 				FREE CAMERA	
# <------------------------------------>

# Modifier keys' speed multiplier
const SHIFT_MULTIPLIER = 10
const ALT_MULTIPLIER = 1.0 / SHIFT_MULTIPLIER

@export_range(0.0, 1.0) var sensitivity: float = 0.25

# Mouse state
var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0

# Movement state
var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 30
var _deceleration = -10
var _vel_multiplier = 4

# Keyboard state
var _w = false
var _s = false
var _a = false
var _d = false
var _q = false
var _e = false
var _shift = false
var _alt = false

func _input(event: InputEvent) -> void:
	# Quando o botão para trocar a câmera é pressionado
	if event.is_action_released("SwitchCamera"):
		SwitchCamera()
		
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
	
	# Receives mouse button input
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT: # Only allows rotation if right click down
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
			MOUSE_BUTTON_WHEEL_UP: # Increases max velocity
				_vel_multiplier = clamp(_vel_multiplier * 1.1, 0.2, 20)
			MOUSE_BUTTON_WHEEL_DOWN: # Decereases max velocity
				_vel_multiplier = clamp(_vel_multiplier / 1.1, 0.2, 20)

	# Receives key input
	if event is InputEventKey:
		match event.keycode:
			KEY_W:
				_w = event.pressed
			KEY_S:
				_s = event.pressed
			KEY_A:
				_a = event.pressed
			KEY_D:
				_d = event.pressed
			KEY_Q:
				_q = event.pressed
			KEY_E:
				_e = event.pressed
			KEY_SHIFT:
				_shift = event.pressed
			KEY_ALT:
				_alt = event.pressed

func _process(delta: float) -> void:
	if BodyNode.debug:
		# Se a câmera de depuração acabou de ser ativada, captura o mouse
		if not previous_debug_camera:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_update_mouselook()
		_update_movement(delta)
	else:
		# Se a câmera de depuração foi desativada, restaura a animação da câmera
		if previous_debug_camera:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			_restore_camera_animation()
	
	# Atualiza o estado anterior da câmera de depuração
	previous_debug_camera = BodyNode.debug
	
	# Se o jogador pressiona o botão "look back"
	if Input.is_action_pressed("look_back") and not is_looking_back:
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

func SwitchCamera():
	match current_camera_mode:
		CameraMode.COCKPIT:
			animation_player.play("TV_POD")
			current_camera_mode = CameraMode.TV_POD
		CameraMode.TV_POD:
			animation_player.play("COCKPIT")
			current_camera_mode = CameraMode.COCKPIT

func _update_movement(delta):
	# Computes desired direction from key states
	_direction = Vector3(
		(_d as float) - (_a as float), 
		(_e as float) - (_q as float),
		(_s as float) - (_w as float)
	)
	
	# Computes the change in velocity due to desired direction and "drag"
	# The "drag" is a constant acceleration on the camera to bring it's velocity to 0
	var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta \
		+ _velocity.normalized() * _deceleration * _vel_multiplier * delta
	
	# Compute modifiers' speed multiplier
	var speed_multi = 1
	if _shift: speed_multi *= SHIFT_MULTIPLIER
	if _alt: speed_multi *= ALT_MULTIPLIER
	
	# Checks if we should bother translating the camera
	if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared():
		# Sets the velocity to 0 to prevent jittering due to imperfect deceleration
		_velocity = Vector3.ZERO
	else:
		# Clamps speed to stay within maximum value (_vel_multiplier)
		_velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier)
		_velocity.y = clamp(_velocity.y + offset.y, -_vel_multiplier, _vel_multiplier)
		_velocity.z = clamp(_velocity.z + offset.z, -_vel_multiplier, _vel_multiplier)
	
		translate(_velocity * delta * speed_multi)

# Updates mouse look 
func _update_mouselook():
	# Only rotates mouse if the mouse is captured
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sensitivity
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		_mouse_position = Vector2(0, 0)
		
		# Prevents looking up/down too far
		pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
		_total_pitch += pitch
	
		rotate_y(deg_to_rad(-yaw))
		rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))

# Restaura a câmera para a animação correta
func _restore_camera_animation():
	match current_camera_mode:
		CameraMode.COCKPIT:
			animation_player.play("COCKPIT")
		CameraMode.TV_POD:
			animation_player.play("TV_POD")
