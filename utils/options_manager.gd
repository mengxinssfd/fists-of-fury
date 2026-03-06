extends Node

var is_shakescreen_enabled := false
var music_volume := 3
var sfx_volume := 5


func set_shakescreen_enabled(value: bool) -> void:
	is_shakescreen_enabled = value


func set_music_volume(value: int) -> void:
	music_volume = value


func set_sfx_volume(value: int) -> void:
	sfx_volume = value
