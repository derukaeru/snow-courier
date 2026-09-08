extends Node
@onready var ui: UI = load(Registry.UID.ui).instantiate()

var canvas_layer: CanvasLayer = CanvasLayer.new()

var game_running: bool = true
var changing_rooms: bool = false

const normal_fov: float = 75.0
var current_mail_task: int = -1
var current_mailbox: Mailbox = null

func _ready() -> void:
	add_child(canvas_layer)
	canvas_layer.layer = 8
	
	canvas_layer.add_child(ui)
	process_mode = Node.PROCESS_MODE_ALWAYS

func change_map(id: String) -> void:
	if Registry.MAPS.has(id):
		if id == "main_outside":
			EventBus.go_to_map.emit(id, true)
		if id == "post_office":
			EventBus.go_to_map.emit(id, false)

func reset() -> void:
	changing_rooms = false
	game_running = false
	
	ui.pause_screen.hide()

func give_mail_task() -> void:
	var id: int = randi_range(0, 38)
	
	current_mail_task = id
	EventBus.set_mailbox.emit(id)
