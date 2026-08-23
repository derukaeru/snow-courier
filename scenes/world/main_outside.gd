extends Node3D

@onready var camera_pivot_1: Marker3D = $main_camera_pivot_1
@onready var spawns_container: Node3D = $spawns
@onready var car: VehicleBody3D = $car

var spawns: Dictionary = {}

func _ready() -> void:
	EventBus.set_camera.emit(camera_pivot_1, Vector3.ZERO, false)
	EventBus.changed_map.connect(changed_map)
	EventBus.set_car.connect(
		func(anchor: Marker3D) -> void:
			car.position = anchor.position
			car.basis = anchor.basis
			car.rotation = anchor.rotation
	)
	
	if GameManager.current_mail_task >= 0:
		EventBus.set_mailbox.emit(GameManager.current_mail_task)

func changed_map(prev: String, _new: String) -> void:
	var player: Player = Util.get_player()
	if not player: return
	
	match prev:
		"post_office":
			player.global_position = $spawns/post_office.global_position
