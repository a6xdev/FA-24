# /// THIS SCRIPT IS SOO BAD. A TOTAL MESS
# /// Making by aislan.

extends Node
class_name SoundsController

@export var BodyNode:BodyController

@export_category("SOUND CONTROLLER")
@export var sound_low_rpm: AudioStreamPlayer
@export var sound_mid_rpm: AudioStreamPlayer
@export var sound_high_rpm: AudioStreamPlayer
@export var Turbo: AudioStreamPlayer

var low_rpm_limit = 2000.0
var mid_rpm_limit = 7000.0
var high_rpm_limit = 11000.0

var min_pitch = 0.6
var max_pitch = 1.3

var target_volume_low: float = -15.0
var target_volume_mid: float = -15.0
var target_volume_high: float = -5.0
var transition_speed: float = 1.0

var target_volume_turbo: float = -10.0
var min_volume_turbo: float = -30.0
var turbo_volume_transition_speed: float = 3.0

var current_rpm: float = 0.0
var target_rpm: float = 0.0
var rpm_transition_speed: float = 10  # Velocidade da transição do RPM

func _ready() -> void:
	initialize_audio_volumes()

func _physics_process(delta: float):
	current_rpm = BodyNode.current_rpm
	update_engine_sound(current_rpm, delta)
	update_turbo(BodyNode.current_rpm, delta)

func update_engine_sound(current_rpm: float, delta):
	var target_pitch: float
	var low_is_playing = sound_low_rpm.playing
	var mid_is_playing = sound_mid_rpm.playing
	var high_is_playing = sound_high_rpm.playing

	var transitioning_to_mid = current_rpm > low_rpm_limit and current_rpm <= mid_rpm_limit
	var transitioning_to_high = current_rpm > mid_rpm_limit

	# Se estiver abaixo do ponto de transição
	if current_rpm <= low_rpm_limit:
		if not low_is_playing:
			sound_low_rpm.play()
		sound_low_rpm.stream_paused = false
		sound_low_rpm.volume_db = lerp(sound_low_rpm.volume_db, target_volume_low, transition_speed * delta)

		if mid_is_playing:
			sound_mid_rpm.volume_db = lerp(sound_mid_rpm.volume_db, -10.0, transition_speed * delta)
		if high_is_playing:
			sound_high_rpm.volume_db = lerp(sound_high_rpm.volume_db, -20.0, transition_speed * delta)

	# Se estiver no intervalo entre low e mid
	elif transitioning_to_mid:
		if not mid_is_playing:
			sound_mid_rpm.play()
		sound_mid_rpm.stream_paused = false
		sound_mid_rpm.volume_db = lerp(sound_mid_rpm.volume_db, target_volume_mid, transition_speed * delta)

		# Diminuir o volume do som low durante a transição
		if low_is_playing:
			sound_low_rpm.volume_db = lerp(sound_low_rpm.volume_db, -30.0, transition_speed * delta)

		# Diminuir o volume do som high se estiver tocando
		if high_is_playing:
			sound_high_rpm.volume_db = lerp(sound_high_rpm.volume_db, -20.0, transition_speed * delta)

	# Se estiver acima do ponto de transição para high
	elif transitioning_to_high:
		if not high_is_playing:
			sound_high_rpm.play()
		sound_high_rpm.stream_paused = false
		sound_high_rpm.volume_db = lerp(sound_high_rpm.volume_db, target_volume_high, transition_speed * delta)

		# Diminuir o volume do som low e mid durante a transição
		if low_is_playing:
			sound_low_rpm.volume_db = lerp(sound_low_rpm.volume_db, -20.0, transition_speed * delta)
		if mid_is_playing:
			sound_mid_rpm.volume_db = lerp(sound_mid_rpm.volume_db, -20.0, transition_speed * delta)

	# Reiniciar os volumes se sair do ponto de transição
	if current_rpm < low_rpm_limit and mid_is_playing:
		sound_mid_rpm.volume_db = lerp(sound_low_rpm.volume_db, 0.0, transition_speed * delta)
	if current_rpm < mid_rpm_limit and high_is_playing:
		sound_high_rpm.volume_db = lerp(sound_high_rpm.volume_db, 0.0, transition_speed * delta)

	target_pitch = lerp(min_pitch, max_pitch, current_rpm / 12000)
	sound_low_rpm.pitch_scale = target_pitch
	sound_mid_rpm.pitch_scale = target_pitch
	sound_high_rpm.pitch_scale = target_pitch

	# Certifique-se de que o som está ativo
	if not sound_high_rpm.playing:
		sound_high_rpm.play()

func update_turbo(current_rpm:float, delta:float):
	var turbo_pitch = lerp(0.8, 1.5, current_rpm / high_rpm_limit)
	var target_turbo_volume = target_volume_turbo
	Turbo.pitch_scale = turbo_pitch
	
	if current_rpm < low_rpm_limit:
		target_turbo_volume = min_volume_turbo
		
	Turbo.volume_db = lerp(Turbo.volume_db, target_turbo_volume, turbo_volume_transition_speed * delta)
	if not Turbo.playing:
		Turbo.play()

func initialize_audio_volumes():
	sound_low_rpm.volume_db = target_volume_low
	sound_mid_rpm.volume_db = -20.0
	sound_high_rpm.volume_db = -20.0 
	Turbo.volume_db = -20

func _on_engine_controller_gear_shifted(new_rpm: float) -> void:
	target_rpm = new_rpm
