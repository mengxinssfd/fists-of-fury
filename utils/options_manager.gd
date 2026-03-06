extends Node

var is_shakescreen_enabled := false
var music_volume := 5
var sfx_volume := 5


func set_shakescreen_enabled(value: bool) -> void:
	is_shakescreen_enabled = value


func set_music_volume(value: int) -> void:
	music_volume = value
	AudioServer.set_bus_volume_db(1, linear_to_db(value / 10.0))


func set_sfx_volume(value: int) -> void:
	sfx_volume = value
	AudioServer.set_bus_volume_db(2, linear_to_db(value / 10.0))
