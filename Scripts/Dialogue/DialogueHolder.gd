extends Node2D
class_name DialogueHolder

@export var dialogues : Dictionary[String, DialogueHolderObject]
var dialogue_entries : Dictionary[String, Dialogue]


func _ready() -> void:
	for i in range(dialogues.values().size()):
		dialogue_entries[dialogues.keys()[i]] = setup_dialogues(dialogues.values()[i])


func setup_dialogues(dialogueHolderObject : DialogueHolderObject) -> Dialogue:
	var new_dialogue : Dialogue = Dialogue.new()
	
	var say_text : Array[String]
	for text in dialogueHolderObject.dialogues:
		say_text.append(tr(text))
	new_dialogue.add_character_dialogue(say_text)
	
	new_dialogue.add_moods(dialogueHolderObject.eyes_mood, dialogueHolderObject.mouth_mood)
	
	new_dialogue.set_finish_id(dialogueHolderObject.finish_id)
	
	if dialogueHolderObject.options.size() > 0:
		
		var ordered_keys : Array[String]
		var ordered_values : Array[DialogueHolderObject]
		
		var current_row : int = 0
		
		var options_count : int = dialogueHolderObject.options.size()
		
		# Dictionary is aquired unsorted. Having an order and using this logic, makes it sorted again
		while ordered_keys.size() != options_count:
			for i in range(dialogueHolderObject.options.size()):
				if current_row == dialogueHolderObject.options.values()[i].order:
					if dialogueHolderObject.options.values()[i].add_condition == "" || MemoryManager.remembers(dialogueHolderObject.options.values()[i].add_condition):
						ordered_keys.append(dialogueHolderObject.options.keys()[i])
						ordered_values.append(dialogueHolderObject.options.values()[i])
					else:
						options_count -= 1
			current_row += 1
		
		var options : Array[String]
		for option_texts in ordered_keys:
			options.append(tr(option_texts))
		
		var answer_ids : Array[String]
		for option in ordered_keys:
			answer_ids.append(option)
		
		var answer_dialogues : Array[Dialogue]
		for further_dialogue in ordered_values:
			answer_dialogues.append(setup_dialogues(further_dialogue))
		
		new_dialogue.add_dialogue_options(options, answer_ids, answer_dialogues)
	
	return new_dialogue


func get_dialogue(id : String) -> Dialogue:
	return dialogue_entries[id]
