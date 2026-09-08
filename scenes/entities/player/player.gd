class_name Player extends CharacterBody3D

@onready var model_container: Node3D = $model_container
@onready var interaction_area: Area3D = $interaction_area
@onready var collision: CollisionShape3D = $CollisionShape3D

@onready var camera_anchor: Node3D = $camera_anchor
@onready var camera: Camera3D = $camera_anchor/Camera3D

@export var ground_check_height: float = 50.0
@export var ground_check_depth: float = 100.0

const gravity: float = 9.8
const DEFAULT_SPEED: float = 2.0
var speed: float = DEFAULT_SPEED
var target_rotation: float = 0.0

var can_move: bool = true
var can_rotate: bool = true
var is_outside: bool = true
var is_in_car: bool = false

var look_target: Vector3
var movement_tw: Tween 

var mails: Array = []
func _ready() -> void:
	EventBus.player_can_move.connect(
		func(outside: bool = true) -> void: 
			can_move = true
			velocity = Vector3.ZERO
			is_outside = outside
	)
	EventBus.player_not_move.connect(
		func() -> void: 
			can_move = false
			velocity = Vector3.ZERO
	)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var cam_basis: Basis = camera_anchor.global_transform.basis
	var direction = (cam_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	direction.y = 0
	direction = direction.normalized()
	
	if can_move:
		if direction:
			if is_outside:
				speed = DEFAULT_SPEED * 1.4
			else:
				speed = DEFAULT_SPEED
			
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			
			if (movement_tw and not movement_tw.is_valid()) or not movement_tw:
				movement_tw = get_tree().create_tween()
				
				movement_tw.tween_property(model_container, "position:y", 0.1, 0.16)
				movement_tw.parallel()
				movement_tw.tween_property(model_container, "scale:x", 0.96, 0.16)
				movement_tw.parallel()
				movement_tw.tween_property(model_container, "scale:y", 1.05, 0.16)
				
				movement_tw.tween_property(model_container, "position:y", 0.0, 0.1)
				movement_tw.parallel()
				movement_tw.tween_property(model_container, "scale:x", 1, 0.1)
				movement_tw.parallel()
				movement_tw.tween_property(model_container, "scale:y", 1, 0.1)
				
				look_target = Vector3(velocity.x, 0, velocity.z)
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	
	model_container.rotation.y = lerp_angle(model_container.rotation.y, atan2(-look_target.x, -look_target.z), .23)
	if abs(target_rotation - camera_anchor.rotation.y) > 0.1:
		camera_anchor.rotation.y = lerp_angle(camera_anchor.rotation.y, target_rotation, 0.2)
	
	move_and_slide()
	snap_to_ground_if_needed()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		interact()
	
	if is_in_car: return
	if Input.is_action_just_pressed("ui_left"):
		target_rotation += deg_to_rad(40)
	if Input.is_action_just_pressed("ui_right"):
		target_rotation -= deg_to_rad(40)

func interact() -> void:
	var interactions = interaction_area.get_overlapping_areas().filter(
		func(a) -> bool: 
			return a is InteractableComponent
	)
	
	for entry in interactions:
		if entry.active:
			entry.interact()

func snap_to_ground_if_needed() -> void:
	var space_state := get_world_3d().direct_space_state
	var origin: Vector3 = global_position + Vector3.UP * ground_check_height
	var target: Vector3 = global_position + Vector3.DOWN * ground_check_depth
	
	var query := PhysicsRayQueryParameters3D.create(origin, target)
	query.exclude = [self]
	
	var result: Dictionary = space_state.intersect_ray(query)
	if result.is_empty():
		return 
	
	var floor_y: float = result.position.y
	
	if global_position.y < floor_y - 0.05:
		global_position.y = floor_y + 0.05
		velocity.y = 0.0
