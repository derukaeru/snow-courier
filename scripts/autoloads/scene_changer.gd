extends Node

@onready var loading_screen: PackedScene = load(Registry.UID.loading_screen)
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_thread: bool = true

signal progress_changed(progress)
signal loading_finished

func _ready() -> void:
	set_process(false)
	
func change_scene(scene_name: String) -> void:
	scene_path = Registry.UID[scene_name]
	
	var new_load_screen = loading_screen.instantiate()
	GameManager.ui.add_child(new_load_screen)
	
	progress_changed.connect(new_load_screen._on_progress_changed)
	loading_finished.connect(new_load_screen._on_loading_finished)
	
	await new_load_screen.loading_screen_ready
	start_load()
	
func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_thread)
	if state == OK:
		set_process(true)
	
func _process(_delta: float) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_changed.emit(progress[0])
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			
			get_tree().change_scene_to_packed(loaded_resource)
			loading_finished.emit()
