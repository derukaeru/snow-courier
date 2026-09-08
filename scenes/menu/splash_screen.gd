extends Control

@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	GameManager.ui.hide()
	animation.play("fade")
	
	await animation.animation_finished
	SceneChanger.change_scene("title_screen")
