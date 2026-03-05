class_name FlickeringTextureRect extends TextureRect

@export var duration_flicker: int
@export var total_flickers: int

var is_flickering := false
var flickers_left := 0

@onready var time_last_flicker := DurationTool.new(duration_flicker)


func _ready() -> void:
	visible = false


func _process(_delta: float) -> void:
	if is_flickering and time_last_flicker.is_over_duration():
		if not visible:
			if flickers_left == 0:
				is_flickering = false
			else:
				flickers_left -= 1
				visible = true
		else:
			visible = false
		time_last_flicker.refresh()


func start_flickering() -> void:
	flickers_left = total_flickers
	is_flickering = true
	time_last_flicker.refresh()
	SoundPlayer.play(SoundManager.Sound.GOGOGO, false)
