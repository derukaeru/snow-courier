extends CanvasLayer

signal loading_screen_ready
@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	show()
	animation.play("fade")
	await animation.animation_finished
	loading_screen_ready.emit()
 
func _on_progress_changed(_value) -> void:
	pass

func _on_loading_finished() -> void:
	animation.play_backwards("fade")
	await animation.animation_finished
	queue_free()
