extends Panel

@onready var marking_field : RichTextLabel = $HBoxContainer/Marking
@onready var text_field : RichTextLabel = $HBoxContainer/Text
@onready var char_timer : Timer = $Timer

var goal_string : String
var current_string : String
var current_index : int

var letter_time : float = 0.04
var space_time : float = 0.04
var punctuation_time = 0.1

signal text_finished()
signal text_empty()
signal text_talk()

func format_text() -> void:
	if marking_field.get_line_count() < text_field.get_line_count():
		marking_field.text += "\n"
	
	match goal_string[current_index]:
		"!", ".", "?":
			if (current_index != goal_string.length() - 1 && goal_string[current_index - 1] != "." && goal_string[current_index + 1] != "." &&
			goal_string[current_index + 1] != "?" && goal_string[current_index + 1] != "!"):
				marking_field.text += "\n*"
				current_string += "\n"
				# We do plus 1, as it will get incremented after this call by one again
				if goal_string[current_index + 1] == " ":
					current_index += 1


func adjust_timer(char : String) -> void:
	match char:
		"!", ".", ",", "?":
			char_timer.wait_time = punctuation_time
			emit_signal("text_empty")
		" ":
			char_timer.wait_time = space_time
		_:
			char_timer.wait_time = letter_time
			emit_signal("text_talk")


func show_dialogue(text : String) -> void:
	marking_field.text = "*"
	text_field.text = ""
	goal_string = text
	
	if text.length() > 0:
		adjust_timer(text[0])
		char_timer.start()
	else:
		emit_signal("text_finished")


func finish_current_dialogue() -> void:
	while current_index < goal_string.length():
		current_string += goal_string[current_index]
		text_field.text = current_string
		format_text()
		current_index += 1
	emit_signal("text_finished")


func _on_timer_timeout() -> void:
	if current_index < goal_string.length():
		current_string += goal_string[current_index]
		text_field.text = current_string
		format_text()
		current_index += 1
		if current_index < goal_string.length():
			adjust_timer(goal_string[current_index])
	else:
		goal_string = ""
		current_string = ""
		current_index = 0
		char_timer.stop()
		emit_signal("text_finished")
