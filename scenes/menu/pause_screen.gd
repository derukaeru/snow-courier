class_name PauseScreen extends Control

@onready var settings_screen: SettingsScreen = $settings_screen
@onready var animation: AnimationPlayer = $AnimationPlayer

@onready var hover_sfx: AudioStreamPlayer = $hover_sfx
@onready var select_sfx: AudioStreamPlayer = $select_sfx

func _ready() -> void:
	hide()

func _on_resume_pressed() -> void:
	close()
	select_sfx.play()

func _on_settings_pressed() -> void:
	settings_screen.open()
	select_sfx.play()

func _on_exit_pressed() -> void:
	SceneChanger.change_scene("title_screen")
	select_sfx.play()

func open() -> void:
	GameManager.ui.shader.hide()
	show()
	animation.play("open")
	select_sfx.play()

func close() -> void:
	animation.play_backwards("open")
	await animation.animation_finished
	hide()
	GameManager.ui.shader.show()
	get_tree().paused = false

func mouse_entered(source: Button) -> void:
	source.text = "> " + source.text + " <" if not source.text.begins_with("> ") else source.text
	hover_sfx.play()

func mouse_exited(source: Button) -> void:
	source.text = source.text.trim_prefix("> ").trim_suffix(" <")
