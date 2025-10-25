extends Sprite2D

@export var dialogue_to_trigger : String

@onready var sign_dialogue : DialogueHolder = $DialogueHolder
@onready var cooldown_timer : Timer  = $Timer

var is_interactable : bool = true


func _ready() -> void:
	if !cooldown_timer.timeout.is_connected(_on_timer_timeout):
		cooldown_timer.timeout.connect(_on_timer_timeout)


func on_interact(_player : Node2D) -> void:
	if is_interactable:
		start_dialogue(dialogue_to_trigger)
		is_interactable = false


func start_dialogue(dialogue : String) -> void:
	DialogueManager.dialogue_finished.connect(on_dialogue_finished)
	DialogueManager.POPUP_DIALOGUE(sign_dialogue.get_dialogue(dialogue), true)


func on_dialogue_finished(_finish_id : String) -> void:
	DialogueManager.dialogue_finished.disconnect(on_dialogue_finished)
	# Not pretty, but temporary fix for reusable dialogue
	sign_dialogue._ready()
	cooldown_timer.start()


func _on_timer_timeout() -> void:
	is_interactable = true
