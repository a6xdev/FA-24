extends Control

func _input(event: InputEvent) -> void:
	if event.is_action_released("settings"):
		$VBoxContainer2.visible = !$VBoxContainer2.visible

func _process(delta: float) -> void:
	$VBoxContainer2/VBoxContainer/label.text = "Steering Sensitivity: " + str($VBoxContainer2/VBoxContainer/SteerSensi.value)
	$VBoxContainer2/VBoxContainer2/label.text = "Deadzone: " + str($VBoxContainer2/VBoxContainer2/HSlider.value)
	$VBoxContainer2/VBoxContainer3/label.text = "Sensitivity Accel: " + str($VBoxContainer2/VBoxContainer3/AccelSensi.value)
