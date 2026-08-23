class_name SettingsScreen extends Control
@onready var animation: AnimationPlayer = $AnimationPlayer

@onready var sound_effect_slider: HSlider = $sound_effect_slider
@onready var music_slider: HSlider = $music_slider

@onready var fullscreen: CheckButton = $fullscreen_toggle

@onready var hover_sfx: AudioStreamPlayer = $hover_sfx
@onready var select_sfx: AudioStreamPlayer = $select_sfx

func _ready() -> void:
	pass

func exit_pressed() -> void:
	animation.play_backwards("open")
	select_sfx.play()
	await animation.animation_finished
	hide()
	

func open() -> void:
	show()
	animation.play("open")
	select_sfx.play()
	
	sound_effect_slider.value = SettingsManager.sound_effect_strength
	music_slider.value = SettingsManager.music_strength
	
	fullscreen.button_pressed = SettingsManager.fullscreen

func mouse_entered(source: Button) -> void:
	source.text = "> " + source.text + " <" if not source.text.begins_with("> ") else source.text
	hover_sfx.play()

func mouse_exited(source: Button) -> void:
	source.text = source.text.trim_prefix("> ").trim_suffix(" <")

func sfx_value_changed(value: bool) -> void:
	SettingsManager.set_sfx(sound_effect_slider.value)
	hover_sfx.play()

func music_value_changed(value: bool) -> void:
	SettingsManager.set_music(music_slider.value)
	hover_sfx.play()

func fullscreen_toggled(toggled_on: bool) -> void:
	SettingsManager.set_fullscreen(toggled_on)
	hover_sfx.play()
