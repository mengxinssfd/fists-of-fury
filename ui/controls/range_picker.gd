class_name RangePicker extends ActivableControl

const TICK_ON = preload("uid://cdk6e6ttjq1j1")
const TICK_OFF = preload("uid://b7h8ubhk6mqb8")

@onready var ticks_container: HBoxContainer = $TicksContainer

func _process(_delta: float) -> void:
	if is_active:
		if Input.is_action_just_pressed("ui_right"):
			set_value(current_value + 1)
		if Input.is_action_just_pressed("ui_left"):
			set_value(current_value - 1)

func refresh() -> void:
	var ticks = ticks_container.get_children() as Array[TextureRect]
	for i in range(0, current_value):
		ticks[i].texture = TICK_ON
	for i in range(current_value, ticks.size()):
		ticks[i].texture = TICK_OFF
