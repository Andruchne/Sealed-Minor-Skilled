extends CharacterBody2D

@onready var dirr_dialogues : Node2D = $DialogueHolder

var temp_intro : bool

func on_interact(_player : Node2D) -> void:
	if !temp_intro:
		DialogueManager.POPUP_DIALOGUE(dirr_dialogues.beginning_dialogue)
		temp_intro = true
