class_name DeathScreen extends MarginContainer

@export var countdown_start: int

var current_count := 0

@onready var timer: Timer = $Timer
@onready var countdown_label: Label = $Border/MarginContainer/Contents/VBoxContainer/CountdownLabel


func _ready() -> void:
	current_count = countdown_start
	timer.timeout.connect(on_timeout.bind())
	refresh()


func _process(_delta: float) -> void:
	if current_count < countdown_start and Input.is_action_just_pressed("attack"):
		DamageManager.player_revive.emit()
		queue_free()


func on_timeout() -> void:
	if current_count > 0:
		current_count -= 1
		refresh()
	else:
		queue_free()


func refresh() -> void:
	countdown_label.text = str(current_count)
