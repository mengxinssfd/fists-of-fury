class_name OptionsScreen extends Control

signal exit

var active_index := 0

@onready var music_volume: RangePicker = $Background/MarginContainer/VBoxContainer/MusicVolume
@onready var sound_volume: RangePicker = $Background/MarginContainer/VBoxContainer/SoundVolume
@onready var shake_toggle: TogglePicker = $Background/MarginContainer/VBoxContainer/ShakeToggle
@onready var return_button: LabelPicker = $Background/MarginContainer/VBoxContainer/ReturnButton

@onready var list: Array[ActivableControl] = [
	music_volume,
	sound_volume,
	shake_toggle,
	return_button,
]


func _ready() -> void:
	music_volume.set_value(OptionsManager.music_volume)
	sound_volume.set_value(OptionsManager.sfx_volume)
	shake_toggle.set_value(OptionsManager.is_shakescreen_enabled)
	music_volume.value_change.connect(OptionsManager.set_music_volume)
	sound_volume.value_change.connect(OptionsManager.set_sfx_volume)
	shake_toggle.value_change.connect(OptionsManager.set_shakescreen_enabled)
	return_button.press.connect(on_exit.bind())
	refresh()


func _process(_delta: float) -> void:
	handle_input()


func on_exit() -> void:
	exit.emit()


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
