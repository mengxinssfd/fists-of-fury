class_name FlickeringTextureRect extends TextureRect

@export var duration_flicker: int
@export var total_flickers: int

var is_flickering := false
var flickers_left := 0
var image: Texture2D = null

@onready var time_last_flicker := DurationTool.new(duration_flicker)


func _ready() -> void:
	image = texture
	texture = null


func _process(_delta: float) -> void:
	if is_flickering and time_last_flicker.is_over_duration():
		if texture == null:
			if flickers_left == 0:
				is_flickering = false
			else:
				flickers_left -= 1
				texture = image
		else:
			texture = null
		time_last_flicker.refresh()


func start_flickering() -> void:
	flickers_left = total_flickers
	is_flickering = true
	time_last_flicker.refresh()
	SoundPlayer.play(SoundManager.Sound.GOGOGO, false)
