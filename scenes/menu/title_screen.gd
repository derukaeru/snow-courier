class_name TitleScreen extends Control
@onready var settings_screen: SettingsScreen = $settings_screen
@onready var hover_sfx: AudioStreamPlayer = $hover_sfx
@onready var select_sfx: AudioStreamPlayer = $select_sfx

func _ready() -> void:
	GameManager.ui.hide()

func start_pressed() -> void:
	select_sfx.play()
	SceneChanger.change_scene("main")

func settings_pressed() -> void:
	settings_screen.open()
	select_sfx.play()

func _on_exit_pressed() -> void:
	select_sfx.play()
	get_tree().quit()

func mouse_entered(source: Button) -> void:
	source.text = "> " + source.text + " <" if not source.text.begins_with("> ") else source.text
	hover_sfx.play()

func mouse_exited(source: Button) -> void:
	source.text = source.text.trim_prefix("> ").trim_suffix(" <")
