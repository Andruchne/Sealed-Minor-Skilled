extends Node2D

var beginning_dialogue : Dialogue = Dialogue.new()

func _ready() -> void:
	setup()

func setup() -> void:
	setup_beginning_dialogue()


func setup_beginning_dialogue() -> void:
	# First dialogue stage
	var start_dialogue : Array
	start_dialogue.append(tr("dirr_01_start"))
	start_dialogue.append(tr("dirr_01_whats_inside"))
	start_dialogue.append(tr("dirr_01_what_was_it"))
	beginning_dialogue.add_character_dialogue(start_dialogue)
	
	var start_eyes_mood : Array = [DialogueManager.Mood.GLAD, DialogueManager.Mood.NORMAL, DialogueManager.Mood.NORMAL]
	var start_mouth_mood : Array = [DialogueManager.Mood.GLAD, DialogueManager.Mood.NORMAL, DialogueManager.Mood.NORMAL]
	beginning_dialogue.add_moods(start_eyes_mood, start_mouth_mood)
	
	var options : Array
	options.append(tr("dirr_01_choice_me"))
	options.append(tr("dirr_01_choice_nothing"))
	options.append(tr("dirr_01_choice_look_again"))
	
	var answer_id : Array
	answer_id.append("dirr_01_choice_me")
	answer_id.append("dirr_01_choice_nothing")
	answer_id.append("dirr_01_choice_look_again")
	
	# Second dialogue stage
	# First answer
	var response_choice_me : Dialogue = Dialogue.new()
	var response_choice_me_text : Array
	response_choice_me_text.append(tr("dirr_01_ew"))
	response_choice_me.add_character_dialogue(response_choice_me_text)
	
	var me_eyes_mood : Array = [DialogueManager.Mood.SUS]
	var me_mouth_mood : Array = [DialogueManager.Mood.NORMAL]
	response_choice_me.add_moods(me_eyes_mood, me_mouth_mood)
	
	var options_choice_me : Array
	options_choice_me.append(tr("dirr_01_choice_point_me"))
	options_choice_me.append(tr("dirr_01_choice_you_ugly"))
	options_choice_me.append(tr("dirr_01_choice_true_look_again"))
	
	var choice_me_answer_id : Array
	choice_me_answer_id.append("dirr_01_choice_point_me")
	choice_me_answer_id.append("dirr_01_choice_you_ugly")
	choice_me_answer_id.append("dirr_01_choice_true_look_again")
	
	var response_choice_me_point : Dialogue = Dialogue.new()
	var response_choice_me_following_text : Array
	response_choice_me_following_text.append(tr("dirr_01_oh_you"))
	response_choice_me_following_text.append(tr("dirr_01_wait_you"))
	response_choice_me_following_text.append(tr("dirr_01_come"))
	response_choice_me_point.add_character_dialogue(response_choice_me_following_text)
	
	var me_point_eyes_mood : Array = [DialogueManager.Mood.NORMAL, DialogueManager.Mood.SUS, DialogueManager.Mood.GLAD]
	var me_point_mouth_mood : Array = [DialogueManager.Mood.NORMAL, DialogueManager.Mood.NORMAL, DialogueManager.Mood.GLAD]
	response_choice_me_point.add_moods(me_point_eyes_mood, me_point_mouth_mood)
	
	var response_choice_me_ugly : Dialogue = Dialogue.new()
	var response_choice_me_ugly_text : Array
	response_choice_me_ugly_text.append(tr("dirr_01_offended"))
	response_choice_me_ugly.add_character_dialogue(response_choice_me_ugly_text)
	
	var me_ugly_eyes_mood : Array = [DialogueManager.Mood.ANGRY]
	var me_ugly_mouth_mood : Array = [DialogueManager.Mood.NORMAL]
	response_choice_me_ugly.add_moods(me_ugly_eyes_mood, me_ugly_mouth_mood)
	
	var response_choice_me_true_look : Dialogue = Dialogue.new()
	var response_choice_me_true_look_text : Array
	response_choice_me_true_look_text.append(tr("dirr_01_wait_come_too"))
	response_choice_me_true_look.add_character_dialogue(response_choice_me_true_look_text)
	
	var me_true_look_eyes_mood : Array = [DialogueManager.Mood.NORMAL]
	var me_true_look_mood : Array = [DialogueManager.Mood.NORMAL]
	response_choice_me_true_look.add_moods(me_true_look_eyes_mood, me_true_look_mood)
	
	var choice_me_dialogues : Array 
	choice_me_dialogues.append(response_choice_me_point)
	choice_me_dialogues.append(response_choice_me_ugly)
	choice_me_dialogues.append(response_choice_me_true_look)
	
	# Add choices to answer of "me", to finish off first response option
	response_choice_me.add_dialogue_options(options_choice_me, choice_me_answer_id, choice_me_dialogues)
	
	# Second answer
	var response_choice_nothing : Dialogue = Dialogue.new()
	var response_choice_nothing_text : Array
	response_choice_nothing_text.append(tr("dirr_01_nothing_gyoho"))
	response_choice_nothing_text.append(tr("dirr_01_long_wait"))
	response_choice_nothing_text.append(tr("dirr_01_least_see_inside"))
	response_choice_nothing.add_character_dialogue(response_choice_nothing_text)
	
	var nothing_eyes_mood : Array = [DialogueManager.Mood.GLAD, DialogueManager.Mood.ANGRY, DialogueManager.Mood.NORMAL]
	var nothing_look_mood : Array = [DialogueManager.Mood.NORMAL, DialogueManager.Mood.NORMAL, DialogueManager.Mood.NORMAL]
	response_choice_nothing.add_moods(nothing_eyes_mood, nothing_look_mood)
	
	# Third answer
	var response_choice_look_again : Dialogue = Dialogue.new()
	var response_choice_look_again_text : Array
	response_choice_look_again_text.append(tr("dirr_01_wait_come_too"))
	response_choice_look_again.add_character_dialogue(response_choice_look_again_text)
	
	var look_again_eyes_mood : Array = [DialogueManager.Mood.NORMAL]
	var look_again_look_mood : Array = [DialogueManager.Mood.NORMAL]
	response_choice_look_again.add_moods(look_again_eyes_mood, look_again_look_mood)
	
	var first_choices_dialogues : Array
	first_choices_dialogues.append(response_choice_me)
	first_choices_dialogues.append(response_choice_nothing)
	first_choices_dialogues.append(response_choice_look_again)
	
	# Finish first dialogue sequence
	beginning_dialogue.add_dialogue_options(options, answer_id, first_choices_dialogues)
