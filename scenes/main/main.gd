extends Node3D

@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var map_container: Node3D = $map_container
@onready var entities: Node3D = $entities
@onready var car_anchor: Marker3D = $car_anchor

@onready var background_music: AudioStreamPlayer = $background_music

var old_map_id: String
var map_id: String = "post_office"

var current_music_playing: String = "lofi-snowskate"

func _ready() -> void:
	EventBus.go_to_map.connect(go_to_map)
	EventBus.changed_map.connect(changed_map)
	EventBus.set_camera.connect(set_camera)
	
	EventBus.change_env_background_color.connect(change_background_color)
	EventBus.change_env_fog_color.connect(change_fog_color)
	EventBus.change_env_fog_density.connect(change_fog_density)
	
	EventBus.add_entities.connect(add_entities)
	EventBus.car_exited.connect(set_car_anchor)
	
	GameManager.ui.show()
	go_to_map(map_id)

func _process(_delta: float) -> void:
	var player: Player = Util.get_player()
	if not player: return
	
	if Input.is_action_just_pressed("cycle") and player.is_in_car:
		cycle_music()

func go_to_map(id: String, is_outside: bool = false) -> void:
	EventBus.player_not_move.emit()
	GameManager.changing_rooms = true
	
	GameManager.ui.room_transition_anim.play("transition")
	GameManager.ui.room_transition.show()
	
	var map_path: String = Registry.MAPS[id]
	ResourceLoader.load_threaded_request(map_path)
	
	transition_zoom_camera()
	await GameManager.ui.room_transition_anim.animation_finished
	old_map_id = map_id
	
	for map in map_container.get_children():
		map.queue_free()
	
	while ResourceLoader.load_threaded_get_status(map_path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
	
	var status := ResourceLoader.load_threaded_get_status(map_path)
	if status != ResourceLoader.THREAD_LOAD_LOADED:
		print("Failed to load map: %s (status %d)" % [map_path, status])
		return

	var map_scene: PackedScene = ResourceLoader.load_threaded_get(map_path)
	var new_map: Node3D = map_scene.instantiate()
	map_container.add_child(new_map)
	
	map_id = id
	GameManager.ui.room_transition_anim.play_backwards("transition")
	EventBus.changed_map.emit(old_map_id, map_id)
	
	await GameManager.ui.room_transition_anim.animation_finished
	
	GameManager.ui.room_transition.hide()
	EventBus.player_can_move.emit(is_outside)
	GameManager.changing_rooms = false

@warning_ignore("unused_parameter")
func changed_map(prev_map: String, new_map: String) -> void:
	match new_map:
		"main_outside":
			change_background_color(Color("#191919"))
			EventBus.set_car.emit(car_anchor)

func set_camera(camera_marker: Marker3D, pivot: Vector3 = Vector3.ZERO, wander_free: bool = false) -> void:
	var player: Player = Util.get_player()
	if not player: return
	
	player.camera_anchor.top_level = wander_free
	player.camera_anchor.global_position = Vector3.ZERO
	player.camera_anchor.position = pivot
	
	player.camera.position = camera_marker.position
	player.camera.rotation = camera_marker.rotation

func transition_zoom_camera() -> void:
	var current_camera: Camera3D = get_viewport().get_camera_3d()
	if not current_camera:
		return print("theres no current camera")
	
	var tw: Tween = get_tree().create_tween()
	tw.tween_property(current_camera, "fov", 55, 0.72)
	
	await tw.finished
	current_camera.fov = GameManager.normal_fov

func change_fog_density(value: float) -> void:
	world_env.environment.fog_density = value

func change_background_color(color: Color) -> void:
	world_env.environment.background_color = color

func change_fog_color(color: Color) -> void:
	world_env.environment.fog_light_color = color

func set_default_env() -> void:
	change_background_color(Color("#191919"))
	change_fog_color(Color("#1e2127"))
	change_fog_density(0.29)

func add_entities(node: Node3D) -> void:
	entities.add_child(node)

func get_current_map() -> Node3D:
	return map_container.get_child(0)

func set_car_anchor(car: VehicleBody3D) -> void:
	car_anchor.position = car.position
	car_anchor.basis = car.basis
	car_anchor.rotation = car.rotation

func cycle_music() -> void:
	var music_names: Array = Registry.MUSIC.keys()
	var current_index: int = music_names.find(current_music_playing)
	
	if not current_index:
		return push_error("Could not find index of song %s " % current_music_playing)
	
	current_index += 1
	if current_index >= music_names.size():
		current_index = 0
	
	current_music_playing = music_names[current_index]
	load_music()

func load_music() -> void:
	if not Registry.MUSIC.has(current_music_playing): 
		return push_error("Registry does not have a record of this music %s " % current_music_playing)
	background_music.stream = load(Registry.MUSIC[current_music_playing])
