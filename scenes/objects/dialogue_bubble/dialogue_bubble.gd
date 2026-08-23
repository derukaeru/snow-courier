class_name DialogBubble extends Node3D

@onready var label: Label3D = $Label3D
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var type_sfx: AudioStreamPlayer3D = $type_sfx

signal dialogue_finished
signal done

var typing: bool = false

var dialogue_name: String = ""
var dialogue_paragraph: String = ""
var dialogue_line: int = 0

var text: String = ""
var letter_index: int = 0

var typing_speed: float = 0.05
var type_diff: float = 0.0

func _ready() -> void:
	typing = true
	dialogue_finished.connect(next_line)

func _process(delta: float) -> void:
	if not typing: return
	
	type_diff -= delta
	
	if type_diff <= 0:
		type_diff = typing_speed
		add_letter(text[letter_index])
	
	if letter_index >= text.length():
		typing = false
		await get_tree().create_timer(2.0).timeout
		
		animation.play("disappear")
		await animation.animation_finished
		
		dialogue_finished.emit()

func add_letter(letter: String) -> void:
	label.text += letter
	letter_index += 1
	type_sfx.play()

func next_line() -> void:
	type_diff = 0
	letter_index = 0
	dialogue_line += 1
	typing = false
	
	if Dialogues.dialogue[dialogue_name][dialogue_paragraph].size() <= dialogue_line: 
		done.emit()
		queue_free()
		return
	
	text = Dialogues.dialogue[dialogue_name][dialogue_paragraph][dialogue_line]
	
	label.text = ""
	animation.play("RESET")
	typing = true
	
