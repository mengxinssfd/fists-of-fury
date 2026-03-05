class_name TogglePicker extends ActivableControl

@onready var value_label: Label = $ValueLabel


func _process(_delta: float) -> void:
	if is_active and has_input_toggle():
		set_value(0 if current_value == 1 else 1)


func has_input_toggle() -> bool:
	var actions := ['ui_left', 'ui_right', 'attack', 'jump']
	for action in actions:
		if Input.is_action_just_pressed(action):
			return true
	return false


func refresh() -> void:
	value_label.text = "ON" if current_value == 1 else "OFF"
