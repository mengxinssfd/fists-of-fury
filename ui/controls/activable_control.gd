class_name ActivableControl extends HBoxContainer

@export var text: String
@export var color_default: Color
@export var color_active: Color
@export var current_value: int
@export var min_value: int
@export var max_value: int

var is_active := false

@onready var label: Label = $Label


func _ready() -> void:
	label.text = text
	refresh()


func set_value(value: int) -> void:
	current_value = clampi(value, min_value, max_value)
	refresh()


func refresh() -> void:
	print(current_value)


func set_active(active: bool) -> void:
	is_active = active
	for control: Control in get_children():
		control.modulate = color_active if is_active else color_default
