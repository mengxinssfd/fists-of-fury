class_name ComboIndicator extends Label

## 连击数停止攻击超过一定时间后重置，单位ms
@export var duration_combo_timeout: float

var current_combo := 0

@onready var time_hit := DurationTool.new(duration_combo_timeout)


func _init() -> void:
	ComboManager.register_hit.connect(on_register_hit.bind())
	refresh()


func _process(_delta: float) -> void:
	if time_hit.is_over_duration():
		current_combo = 0
		refresh()


func on_register_hit() -> void:
	time_hit.refresh()
	current_combo += 1
	refresh()


func refresh() -> void:
	text = 'x' + str(current_combo)
	visible = current_combo > 0
