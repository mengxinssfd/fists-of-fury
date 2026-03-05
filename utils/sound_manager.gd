class_name SoundManager extends Node

enum Sound {
	CLICK,
	EAT_FOOD,
	GOGOGO,
	GRUNT,
	GUN_SHOT,
	HIT1,
	HIT2,
	KNIFE_HIT,
	SWOOSH,
}

@onready var sounds: Array[AudioStreamPlayer] = [
	$Click,
	$EatFood,
	$GoGoGo,
	$Grunt,
	$GunShot,
	$Hit1,
	$Hit2,
	$KnifeHit,
	$Miss,
]


func play(sound: Sound, tweak_pitch := false) -> void:
	var added_pitch := 0.0
	if tweak_pitch: added_pitch = randf_range(-0.3, 0.3)
	var player: AudioStreamPlayer = sounds[sound as int]
	player.pitch_scale = 1 + added_pitch
	player.play()
