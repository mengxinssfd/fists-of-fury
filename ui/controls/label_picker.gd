extends ActivableControl

signal press


func _process(_delta: float) -> void:
	if is_active and has_input_toggle():
		press.emit()


func has_input_toggle() -> bool:
	var actions := ['attack', 'jump']
	for action in actions:
		if Input.is_action_just_pressed(action):
			return true
	return false
