extends Node3D
@onready var camera_pivot: Marker3D = $camera_pivot

func _ready() -> void:
	EventBus.set_camera.emit(camera_pivot, Vector3.ZERO, true)
	EventBus.changed_map.connect(changed_map)

func changed_map(prev: String, _to: String) -> void:
	var player: Player = Util.get_player()
	if not player: return
	
	match prev:
		"main_outside":
			player.global_position = $entrance.global_position

func _on_postman_done_talking() -> void:
	GameManager.give_mail_task()
