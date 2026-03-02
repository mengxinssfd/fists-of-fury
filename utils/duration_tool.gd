class_name DurationTool

## 判断时间是否到达期限的封装工具
##
## new时如果duration是@export修饰的变量，那new时要加上@onready修饰

var _time: float
var _duration: float

func _init(duration: float = 0.0) -> void:
	set_duration(duration)
	refresh()

func set_duration(duration: float) -> void:
	_duration = duration

func refresh() -> void:
	_time = Time.get_ticks_msec()
	
func is_over_duration() -> bool:
	return Time.get_ticks_msec() - _time > _duration

func get_progress() -> float:
	return (Time.get_ticks_msec() - _time) / _duration
