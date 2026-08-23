class_name StaticNPC extends StaticBody3D
signal done_talking(paragraph: String)
signal done_line

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var talk_area: InteractableComponent = $talk_area

@export var NAME: String = ""
@export var dialogue_paragraph: String = ""
@export var dialogue_line: int = 0

var dialogue_bubble: DialogBubble
var talking: bool = false
var talking_dialogue: bool = false

func _process(_delta: float) -> void:
	if talking:
		talk_area.hide()
	elif not talk_area.visible:
		talk_area.show()

func talk_interacted() -> void:
	if not talking:
		dialogue_bubble = DialogueManager.say(NAME, dialogue_paragraph, dialogue_line, global_position)
		add_child(dialogue_bubble)
		dialogue_bubble.global_position = global_position + Vector3(0.0, 1.5, 0.0)
		
		dialogue_bubble.dialogue_finished.connect(func() -> void: done_line.emit())
		dialogue_bubble.done.connect(
			func() -> void: 
				talking = false
				done_talking.emit(dialogue_paragraph)
		)
		
		talking = true
