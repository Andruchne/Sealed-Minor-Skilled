extends CharacterBody2D

@onready var dirr_dialogues : DialogueHolder = $DialogueHolder

var temp_intro : bool

func on_interact(_player : Node2D) -> void:
	if !temp_intro:
		DialogueManager.POPUP_DIALOGUE(dirr_dialogues.get_dialogue("beginning_dialogue"))
		temp_intro = true
