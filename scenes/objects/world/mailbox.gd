class_name Mailbox extends InteractableComponent
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var model_container: Node3D = $model_container

@export var id: int = 0
var is_active: bool = false

func _ready() -> void:
	super._ready()
	
	EventBus.set_mailbox.connect(set_as_next_mail)

func _on_interacted() -> void:
	if not is_active: return
	
	animation.play("interact")
	EventBus.delivered_mail.emit(id)
	GameManager.give_mail_task()
	is_active = false

func set_as_next_mail(_id: int) -> void:
	if _id != id: return
	
	is_active = true
	var marker: Node3D = load(Registry.UID.mail_marker).instantiate()
	add_child(marker)
	
	marker.position.y = 1.5
