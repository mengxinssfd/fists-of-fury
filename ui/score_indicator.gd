class_name ScoreIndicator extends Label

var current_score: int = 0


func _ready() -> void:
	current_score = 0
	refresh()


# 5 => 5 + 4 + 3 + 2 + 1 = 15
# 4 => 4 + 3 + 2 + 1 = 10
func add_combo(points: int) -> void:
	current_score += int((points * (points + 1)) / 2.0)
	refresh()


func refresh() -> void:
	text = str(current_score)
