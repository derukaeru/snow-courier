extends CanvasLayer

signal loading_screen_ready
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var loading_progress: Label = $loading_progress

func _ready() -> void:
	show()
	animation.play("fade")
	await animation.animation_finished
	loading_screen_ready.emit()
 
func _on_progress_changed(_value) -> void:
	loading_progress.text = str(int(_value * 10)) + "%"

func _on_loading_finished() -> void:
	loading_progress.hide()
	animation.play_backwards("fade")
	await animation.animation_finished
	queue_free()
