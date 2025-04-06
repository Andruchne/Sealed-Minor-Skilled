@tool
extends Resource
class_name DialogueHolderObject

@export var order : int = 0

@export var dialogues : Array[String] = [] : set = _set_dialogues
var dialogue_size : int = 0

@export var eyes_mood : Array[DialogueManager.Mood] = [] : set = _set_eyes_mood
var eyes_mood_size : int = 0

@export var mouth_mood : Array[DialogueManager.Mood] = [] : set = _set_mouth_mood
var mouth_mood_size : int = 0

@export var options : Dictionary[String, DialogueHolderObject] = {}


# Setter functions to sync arrays when they change in the Inspector
func _set_dialogues(ids):
	dialogues = ids
	if dialogues.size() != dialogue_size: 
		if dialogues.size() > dialogue_size:
			size_up_arrays()
		elif dialogues.size() < dialogue_size:
			size_down_arrays()
		dialogue_size = dialogues.size()


func _set_eyes_mood(moods):
	eyes_mood = moods
	if moods.size() != eyes_mood_size:
		if eyes_mood.size() > eyes_mood_size:
			size_up_arrays()
		elif eyes_mood.size() < eyes_mood_size:
			size_down_arrays()
		eyes_mood_size = eyes_mood.size()


func _set_mouth_mood(moods):
	mouth_mood = moods
	if moods.size() != mouth_mood_size:
		if mouth_mood.size() > mouth_mood_size:
			size_up_arrays()
		elif mouth_mood.size() < mouth_mood_size:
			size_down_arrays()
		mouth_mood_size = mouth_mood.size()


func size_up_arrays():
	var max_size : int = max(dialogues.size(), eyes_mood.size(), mouth_mood.size())

	dialogues.resize(max_size)
	eyes_mood.resize(max_size)
	mouth_mood.resize(max_size)
	
	for i in range(max_size):
		if dialogues[i] == null:
			dialogues[i] = ""
		if eyes_mood[i] == null:
			eyes_mood[i] = DialogueManager.Mood.NORMAL
		if mouth_mood[i] == null:
			mouth_mood[i] = DialogueManager.Mood.NORMAL

	notify_property_list_changed()


func size_down_arrays():
	var min_size : int = min(dialogues.size(), eyes_mood.size(), mouth_mood.size())

	dialogues.resize(min_size)
	eyes_mood.resize(min_size)
	mouth_mood.resize(min_size)

	notify_property_list_changed()
