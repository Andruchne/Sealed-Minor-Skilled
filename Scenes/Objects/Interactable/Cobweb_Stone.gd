extends Node2D

@onready var stone_dialogue : DialogueHolder = $DialogueHolder
@onready var anim_stone : AnimatedSprite2D = $AnimatedSprite2D

var is_cleared : bool


func on_interact(_player : Node2D) -> void:
	if !is_cleared:
		anim_stone.play("Normal")
		start_dialogue("cobweb_take")
		is_cleared = true


func start_dialogue(dialogue : String) -> void:
	DialogueManager.dialogue_finished.connect(on_dialogue_finished)
	DialogueManager.POPUP_DIALOGUE(stone_dialogue.get_dialogue(dialogue), true)


func on_dialogue_finished(_finish_id : String) -> void:
	DialogueManager.dialogue_finished.disconnect(on_dialogue_finished)


func get_save_state() -> Dictionary:
	var dict : Dictionary = {
		"is_cleared" : is_cleared,
	}
	var stone_state : Dictionary = Useful.GET_ANIMATION_STATES(anim_stone)
	
	for key in stone_state:
		dict[key] = stone_state[key]
	
	return dict


func apply_save_state(state : Dictionary) -> void:
	is_cleared = state.get("is_cleared")
	
	Useful.APPLY_ANIMATION_STATES(anim_stone, state)
