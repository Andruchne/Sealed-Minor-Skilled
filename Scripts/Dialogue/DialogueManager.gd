extends Node2D

# For the portrait
enum Mood {
	NORMAL,
	GLAD,
	SUS,
	ANGRY
}

var dialogue_box : String = "res://Scenes/Dialogue/Dialogue_Box_Holder.tscn"
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


func POPUP_DIALOGUE(dialogue : Dialogue) -> void:
	GameManager.MAIN_ACTIVE = false
	
	# Add dialogue box
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


func on_text_finished() -> void:
	is_text_finished = true


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
	disconnect_current_dialogue()
	
	# Get new dialogue instance
	current_dialogue = current_dialogue.get_next_text(option_picked)
	current_progress_index = 0
	
	current_box.queue_free()
	POPUP_DIALOGUE(current_dialogue)


func on_dialogue_finished() -> void:
	disconnect_current_dialogue()
	
	current_box.text_finished.disconnect(on_text_finished)
	current_box.queue_free()
	
	current_progress_index = 0
	current_texts = []
	GameManager.MAIN_ACTIVE = true


func disconnect_current_dialogue() -> void:
	current_dialogue.options_given.disconnect(on_options_given)
	current_dialogue.dialogue_finished.disconnect(on_dialogue_finished)
