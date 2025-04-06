extends Control

@onready var portrait : Panel = $Panel/BottomDialogue/HorizontalContainer/PortraitHolder/Portrait
@onready var dialogue : Panel = $Panel/BottomDialogue/HorizontalContainer/TextHolder/DialogueText

signal text_finished


func _ready() -> void:
	dialogue.text_finished.connect(on_text_finished)
	dialogue.text_empty.connect(on_halt_talk)
	dialogue.text_talk.connect(on_start_talk)


func on_text_finished() -> void:
	on_halt_talk()
	emit_signal("text_finished")


func on_halt_talk() -> void:
	portrait.stop_talk()


func on_start_talk() -> void:
	portrait.start_talk()


func show_text(text : String) -> void:
	portrait.start_talk()
	dialogue.show_dialogue(text)


func finish_current_text() -> void:
	dialogue.finish_current_dialogue()


func set_mood(mouth_mood : DialogueManager.Mood, eyes_mood : DialogueManager.Mood) -> void:
	portrait.set_mouth(mouth_mood)
	portrait.set_eyes(eyes_mood)
