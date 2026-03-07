class_name ScoreIndicator extends Label

@export var duration_score_update: int
@export var points_per_life: int

var real_score: int = 0
var displayed_score: int = 0
var prior_score: int = 0

@onready var time_score := DurationTool.new(duration_score_update)


func _ready() -> void:
	real_score = 0
	DamageManager.player_revive.connect(on_player_revive.bind())
	refresh()


func _process(_delta: float) -> void:
	if displayed_score != real_score:
		var progress := time_score.get_progress()
		displayed_score = lerp(prior_score, real_score, progress) if progress < 1 else real_score
		refresh()


func on_player_revive() -> void:
	real_score = max(0, real_score - points_per_life)
	start_update()


# 5 => 5 + 4 + 3 + 2 + 1 = 15
# 4 => 4 + 3 + 2 + 1 = 10
func add_combo(points: int) -> void:
	real_score += int((points * (points + 1)) / 2.0)
	start_update()


func start_update() -> void:
	prior_score = displayed_score
	time_score.refresh()
	refresh()


func refresh() -> void:
	text = str(displayed_score)
