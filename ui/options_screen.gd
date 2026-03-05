class_name OptionsScreen extends Control

var active_index := 0

@onready var list: Array[ActivableControl] = [
	$Background/MarginContainer/VBoxContainer/MusicVolume,
	$Background/MarginContainer/VBoxContainer/SoundVolume,
	$Background/MarginContainer/VBoxContainer/ShakeToggle,
	$Background/MarginContainer/VBoxContainer/ReturnButton,
]


func _ready() -> void:
	refresh()


func _process(_delta: float) -> void:
	handle_input()


func handle_input() -> void:
	if Input.is_action_just_pressed("ui_down"):
		active_index = get_safe_index(active_index + 1)
		refresh()
	if Input.is_action_just_pressed("ui_up"):
		active_index = get_safe_index(active_index - 1)
		refresh()


func get_safe_index(index: int) -> int:
	return clampi(index, 0, list.size() - 1)


func refresh() -> void:
	for i in range(list.size()):
		list[i].set_active(i == active_index)
