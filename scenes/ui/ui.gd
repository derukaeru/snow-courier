class_name UI extends CanvasLayer

@onready var pause_screen: PauseScreen = $pause_screen
@onready var room_transition: ColorRect = $room_transition
@onready var room_transition_anim: AnimationPlayer = $room_transition/AnimationPlayer
@onready var shader: ColorRect = $shader

@onready var car_ui: Control = $car_ui
@onready var distance_label: Label = $pause_screen/settings_screen/fullscreen_label
@onready var song_label: Label = $car_ui/song
@onready var speed_label: Label = $car_ui/speed
@onready var objective: Label = $objective
@onready var time_label: Label = $car_ui/time

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
	
	time_label.text = Time.get_time_string_from_system().substr(0, 5)
	
	var player: Player = Util.get_player()
	if not player: return
	
	if GameManager.current_mail_task >= 0 and player.is_in_car:
		distance_label.show()
		distance_label.text = str(int(player.position.distance_to(GameManager.current_mailbox.position))) + "m"
	else:
		distance_label.hide()
