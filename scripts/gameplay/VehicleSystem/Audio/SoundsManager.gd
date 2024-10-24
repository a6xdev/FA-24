extends Node
class_name SoundsController

@export var BodyNode:BodyController

@export_category("SOUND CONTROLLER")
@export var sound_low_rpm: AudioStreamPlayer
@export var sound_mid_rpm: AudioStreamPlayer
@export var sound_high_rpm: AudioStreamPlayer
@export var sound_transition_low_mid: AudioStreamPlayer
@export var sound_transition_mid_high: AudioStreamPlayer

var low_rpm_limit = 2000.0
var mid_rpm_limit = 7000.0
var high_rpm_limit = 11000.0

var min_pitch = 0.6
var max_pitch = 1.1

var target_volume_low: float = -15.0
var target_volume_mid: float = -15.0
var target_volume_high: float = -10.0
var transition_speed: float = 1.0

func _ready() -> void:
	initialize_audio_volumes()

func _physics_process(delta: float):
	update_engine_sound(BodyNode.current_rpm,delta)

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

	target_pitch = lerp(min_pitch, max_pitch, current_rpm / high_rpm_limit)
	sound_low_rpm.pitch_scale = target_pitch
	sound_mid_rpm.pitch_scale = target_pitch
	sound_high_rpm.pitch_scale = target_pitch

func initialize_audio_volumes():
	sound_low_rpm.volume_db = target_volume_low
	sound_mid_rpm.volume_db = -20.0
	sound_high_rpm.volume_db = -20.0 
