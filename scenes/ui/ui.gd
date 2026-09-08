class_name UI extends CanvasLayer

@onready var pause_screen: PauseScreen = $pause_screen
@onready var room_transition: ColorRect = $room_transition
@onready var room_transition_anim: AnimationPlayer = $room_transition/AnimationPlayer
@onready var shader: ColorRect = $shader
@onready var distance_label: Label = $pause_screen/settings_screen/fullscreen_label

func _process(_delta: float) -> void:
	if not GameManager.game_running or get_tree().paused: return
	
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			if pause_screen.settings_screen.visible:
				pause_screen.settings_screen.exit_pressed()
			else:
				get_tree().paused = false
				pause_screen.close()
		else:
			get_tree().paused = true
			pause_screen.open()
