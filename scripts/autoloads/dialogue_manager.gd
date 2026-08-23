extends Node

@onready var dialogue_bubble: PackedScene = load(Registry.UID.dialogue_bubble)

func say(id: String, paragraph_id: String, line_id: int, _position: Vector3) -> DialogBubble:
	if not Dialogues.dialogue.has(id):
		return null
	if line_id < 0:
		line_id = randi() % Dialogues.dialogue[id].length()
	
	var bubble: DialogBubble = dialogue_bubble.instantiate()
	bubble.text = Dialogues.dialogue[id][paragraph_id][line_id]
	bubble.typing = true
	
	bubble.dialogue_name = id
	bubble.dialogue_line = line_id
	bubble.dialogue_paragraph = paragraph_id
	
	return bubble
