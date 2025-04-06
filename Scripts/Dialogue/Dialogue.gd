extends Node2D
class_name Dialogue

# Stored in here, are arrays of strings. One array, represents a series of texts.
var character_says : Array = []
# These arrays are supposeded to store moods, attached to those sentences.
# All three arrays should be of same size
var character_eyes_mood : Array = []
var character_mouth_mood : Array = []

# Arrays of strings here too. One array, represents different options the player can pick.
var dialogue_options : Array = []
# Dictionary, holding the upcoming dialogues, after picking an option
var option_answers : Dictionary

var character_said : bool
var player_has_options : bool

signal options_given(options : Array)
signal dialogue_finished()


# Should only be used for straight dialogue
func add_character_dialogue(string_array : Array):
	character_says = string_array


# For Player choices
func add_dialogue_options(options_array : Array, answer_id_array : Array, answer_text_array : Array):
	if answer_id_array.size() != answer_text_array.size():
		print("Dialogue: Count of ID's don't match answers")
		return
	
	dialogue_options = options_array
	player_has_options = true
	
	for i in range(answer_id_array.size()):
		option_answers[answer_id_array[i]] = answer_text_array[i]


func get_next_text(given_answer = ""):
	# If character simply talks (Usually the first words)
	if !character_said:
		character_said = true
		return character_says
	elif !player_has_options:
		emit_signal("dialogue_finished")
	# If the player has given an answer (New dialogue instance is returned)
	elif given_answer != "":
		if option_answers.has(given_answer):
			return option_answers[given_answer]
		return
	# If the player is supposed to choose
	else:
		emit_signal("options_given", dialogue_options)
	return


func add_moods(eyes_mood : Array, mouth_mood : Array) -> void:
	character_eyes_mood = eyes_mood
	character_mouth_mood = mouth_mood


func get_option_ids() -> Array:
	var ids : Array = option_answers.keys()
	return ids


func get_eyes_moods() -> Array:
	return character_eyes_mood


func get_mouth_moods() -> Array:
	return character_mouth_mood
