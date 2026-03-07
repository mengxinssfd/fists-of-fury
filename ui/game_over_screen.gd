class_name GameOverScreen extends Control

var total_score := 0

@onready var timer: Timer = $Timer
@onready var score_indicator: ScoreIndicator = $Background/MarginContainer/VBoxContainer/HBoxContainer/ScoreIndicator


func _ready() -> void:
	timer.timeout.connect(on_timeout.bind())


func set_score(score: int) -> void:
	total_score = score


func on_timeout() -> void:
	score_indicator.set_score(total_score)
