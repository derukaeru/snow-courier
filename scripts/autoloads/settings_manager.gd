extends Node

var sound_effect_strength: float = 0.5
var music_strength: float = 0.5

var fullscreen: bool = false

func _ready() -> void:
	apply_audio_settings()

func set_sfx(value: float) -> void:
	sound_effect_strength = value
	apply_audio_settings()
	print(sound_effect_strength)

func set_music(value: float) -> void:
	music_strength = value
	apply_audio_settings()
	print(music_strength)

func set_fullscreen(value: bool) -> void:
	fullscreen = value
	apply_display_settings()

func apply_audio_settings() -> void:
	var music: int = AudioServer.get_bus_index("music")
	var sfx: int = AudioServer.get_bus_index("sfx")
	
	AudioServer.set_bus_volume_db(music, linear_to_db(music_strength))
	AudioServer.set_bus_volume_db(sfx, linear_to_db(sound_effect_strength))

func apply_display_settings() -> void:
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
