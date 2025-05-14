extends Node2D

# For the portrait
enum Mood {
	NORMAL,
	GLAD,
	SUS,
	ANGRY
}

var dialogue_box : String = "res://Scenes/Dialogue/Dialogue_Box_Holder.tscn"
var clear_dialogue_box : String = "res://Scenes/Dialogue/Clear_Dialogue_Box_Holder.tscn"
var option_box : String = "res://Scenes/Dialogue/Dialogue_Option_Holder.tscn"

var canvas_layer : CanvasLayer

var current_box 
var current_dialogue : Dialogue

var current_progress_index : int = 0
var current_texts : Array
var current_mouth_moods : Array
var current_eyes_moods : Array

var is_text_displayed : bool
var is_text_finished : bool

var saved_finish_id : String

var clear_box : bool

signal character_talk()
signal character_stop_talk()

signal dialogue_finished(finish_id : String)

func _ready() -> void:
	setup()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Interact") && is_text_displayed:
		if is_text_finished:
			display_text()
		else:
			current_box.finish_current_text()


func setup() -> void:
	GameManager.scene_changed.connect(get_canvas_layer)
	get_canvas_layer()


func get_canvas_layer() -> void:
	await get_tree().process_frame
	canvas_layer = get_tree().get_first_node_in_group("Canvas")
	if canvas_layer == null:
		print("No CanvasLayer found in current scene. Destroying Dialogue Manager")
		queue_free()


func POPUP_DIALOGUE(dialogue : Dialogue, clear : bool = false) -> void:
	GameManager.MAIN_ACTIVE = false
	
	# Add dialogue box
	if clear:
		current_box = load(clear_dialogue_box).instantiate()
		clear_box = true
	else:
		current_box = load(dialogue_box).instantiate()
	canvas_layer.add_child(current_box)
	current_dialogue = dialogue
	
	# Listen to signals
	current_box.text_finished.connect(on_text_finished)
	
	dialogue.options_given.connect(on_options_given)
	dialogue.dialogue_finished.connect(on_dialogue_finished)
	
	current_texts = dialogue.get_next_text()
	current_eyes_moods = current_dialogue.get_eyes_moods()
	current_mouth_moods = current_dialogue.get_mouth_moods()
	is_text_displayed = true
	display_text()


func display_text() -> void:
	if current_progress_index >= current_texts.size():
		current_dialogue.get_next_text()
		return
	
	current_box.show_text(current_texts[current_progress_index])
	current_box.set_mood(current_mouth_moods[current_progress_index], current_eyes_moods[current_progress_index])
	current_progress_index += 1
	is_text_finished = false
	emit_signal("character_talk")


func on_text_finished() -> void:
	is_text_finished = true
	emit_signal("character_stop_talk")


func on_options_given(options : Array) -> void:
	current_box.text_finished.disconnect(on_text_finished)
	current_box.queue_free()
	
	current_texts = options
	
	current_box = load(option_box).instantiate()
	canvas_layer.add_child(current_box)
	current_box.set_options(current_dialogue.get_option_ids(), current_texts)
	current_box.option_picked.connect(on_option_picked)
	
	is_text_displayed = false


func on_option_picked(option_picked : String) -> void:
	current_box.option_picked.disconnect(on_option_picked)
	current_box.queue_free()
	
	# Get new dialogue instance
	var dialogue : Dialogue = current_dialogue.get_next_text(option_picked)
	disconnect_current_dialogue()
	current_dialogue = dialogue
	
	current_progress_index = 0
	
	
	current_box.queue_free()
	POPUP_DIALOGUE(current_dialogue, clear_box)


func on_dialogue_finished() -> void:
	disconnect_current_dialogue()
	
	current_box.text_finished.disconnect(on_text_finished)
	current_box.queue_free()
	
	clear_box = false
	
	current_progress_index = 0
	current_texts = []
	emit_signal("dialogue_finished", current_dialogue.finish_id)
	GameManager.MAIN_ACTIVE = true


func disconnect_current_dialogue() -> void:
	current_dialogue.reset()
	current_dialogue.options_given.disconnect(on_options_given)
	current_dialogue.dialogue_finished.disconnect(on_dialogue_finished)
