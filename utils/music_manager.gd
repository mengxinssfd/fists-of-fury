class_name MusicManager extends Node

enum Music {
	INTRO,
	MENU,
	STAGE1,
	STAGE2,
}

const MUSIC_MAP := {
	Music.INTRO: preload("res://assets/music/intro.mp3"),
	Music.MENU: preload("res://assets/music/menu.mp3"),
	Music.STAGE1: preload("res://assets/music/stage-01.mp3"),
	Music.STAGE2: preload("res://assets/music/stage-02.mp3"),
}

var autoplay_music: AudioStream = null

@onready var music_stream_player: AudioStreamPlayer = $MusicStreamPlayer


func _ready() -> void:
	if autoplay_music: _play(autoplay_music)


func play(music: Music) -> void:
	if music_stream_player.is_node_ready():
		_play(MUSIC_MAP[music])
	else:
		autoplay_music = MUSIC_MAP[music]


func _play(music: AudioStream) -> void:
	music_stream_player.stream = music
	music_stream_player.play()
