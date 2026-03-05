class_name Camera extends Camera2D

@export var duration_shake: int
@export var shake_intensity: int

var is_shaking := false

@onready var time_shaking := DurationTool.new(duration_shake)


func _init() -> void:
	DamageManager.heavy_blow_received.connect(on_heavy_blow_received.bind())


func _process(_delta: float) -> void:
	if is_shaking:
		if time_shaking.is_over_duration():
			is_shaking = false
			offset = Vector2.ZERO
		else:
			offset = Vector2(rand_intensity(), rand_intensity())


func rand_intensity() -> int:
	return randi_range(-shake_intensity, shake_intensity)


func on_heavy_blow_received() -> void:
	is_shaking = true
	time_shaking.refresh()
