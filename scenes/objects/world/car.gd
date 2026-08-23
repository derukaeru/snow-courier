class_name Car extends VehicleBody3D

@onready var model_container: Node3D = $model_container
@onready var leave_marker: Marker3D = $leave_marker
@onready var player_seat: Marker3D = $player_seat

@onready var brakelight_mesh_left: MeshInstance3D = $brakelight_mesh_left
@onready var brakelight_mesh_right: MeshInstance3D = $brakelight_mesh_right

@onready var enter_interact_left: InteractableComponent = $enter_interact_left
@onready var enter_interact_right: InteractableComponent = $enter_interact_right

@onready var leave_car: InteractableComponent = $leave_car
@onready var engine_sfx: AudioStreamPlayer3D = $engine_sfx
@onready var enter_sfx: AudioStreamPlayer3D = $enter_sfx

var brakelight_left_mat: Material
var brakelight_right_mat: Material

var max_steer: float = 0.6
var speed: float = 500

var max_speed: float = speed
var min_pitch: float = 0.8
var max_pitch: float = 1.7
var min_volume_db: float = -20.0
var max_volume_db: float = 0.0

var player_in: bool = false
var is_leaving: bool = false
var is_braking: bool = false
var deceleration: float = 15.0

var target_fov: float = 80.0

func _ready() -> void:
	freeze = true
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = Vector3(0.0, -0.7, 0.0)
	
	brakelight_left_mat = brakelight_mesh_left.get_active_material(0)
	brakelight_right_mat = brakelight_mesh_right.get_active_material(0)
	
	EventBus.car_exited.emit(self)
	engine_sfx.play()

func _physics_process(delta: float) -> void:
	if is_leaving:
		linear_velocity = linear_velocity.move_toward(Vector3.ZERO, deceleration * delta)
		angular_velocity = angular_velocity.move_toward(Vector3.ZERO, deceleration * delta)
		
		if linear_velocity.length() < 0.05 and angular_velocity.length() < 0.05:
			is_leaving = false
			freeze = true
	
	var current_speed: float = linear_velocity.length()
	var speed_ratio: float = clamp(current_speed / max_speed, 0.0, 1.0)
	
	engine_sfx.volume_db = lerp(min_volume_db, max_volume_db, speed_ratio)
	engine_sfx.pitch_scale = lerp(min_pitch, max_pitch, speed_ratio)
	
	if not player_in: return
	
	var player: Player = Util.get_player()
	if not player: return
	
	player.global_position = player_seat.global_position
	player.target_rotation = rotation.y
	
	var steer_inp: float = Input.get_axis("right", "left")
	steering = move_toward(steering, steer_inp * max_steer, delta * 10)
	
	var acceleration_inp: float = Input.get_axis("backward", "forward")
	var forward_speed: float = -global_transform.basis.z.dot(linear_velocity)
	
	is_braking = (acceleration_inp < 0 and forward_speed > 0.01)
	
	if acceleration_inp == 0:
		brake = 0.5
		engine_force = 0.0
	else:
		brake = 0.0
		engine_force = acceleration_inp * speed
	
	if is_braking:
		brakelight_left_mat.emission_enabled = true
		brakelight_right_mat.emission_enabled = true
	else:
		brakelight_left_mat.emission_enabled = false
		brakelight_right_mat.emission_enabled = false
	

func interacted() -> void:
	var player: Player = Util.get_player()
	if not player: return
	
	if player_in: return
	player.hide()
	player.can_move = false
	player.is_in_car = true
	
	player.target_rotation = 0.0
	player.collision.set_deferred("disabled", true)
	player.camera.fov = 110.0
	
	player_in = true
	freeze = false
	is_leaving = false
	
	steering = 0.0
	brake = 0.0
	engine_force = 0.0
		
	enter_interact_left.active = false
	enter_interact_right.active = false
	
	tween_bob()
	
	enter_sfx.play()
	await get_tree().create_timer(1.0).timeout
	leave_car.active = true
	
func exit() -> void:
	var player: Player = Util.get_player()
	if not player: return
	if not player_in: return
	
	global_transform.basis = Basis()
	angular_velocity = Vector3.ZERO
	
	player.position = leave_marker.position
	
	player.show()
	player.can_move = true
	player.is_in_car = false
	
	player.camera.fov = 80.0
	
	player_in = false
	is_leaving = true
	
	brake = 1.0
	engine_force = 0.0
	steering = 0.0
	
	enter_interact_left.active = true
	enter_interact_right.active = true
	leave_car.active = false
	
	player.collision.set_deferred("disabled", false)
	tween_bob()

func tween_bob() -> void:
	var tw: Tween = get_tree().create_tween()
	tw.tween_property(model_container, "scale:x", 0.9, 0.1)
	tw.parallel()
	tw.tween_property(model_container, "scale:y", 1.1, 0.1)
	
	tw.tween_property(model_container, "scale:x", 1.0, 0.1)
	tw.parallel()
	tw.tween_property(model_container, "scale:y", 1.0, 0.1)
