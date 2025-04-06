extends Control

const MAX_OPTIONS : int = 4

var option_scene : String = "res://Scenes/Dialogue/Dialogue_Option.tscn"
@onready var bottom_box : VBoxContainer = $Panel/BottomDialogue/VBoxContainer
@onready var top_box : VBoxContainer = $Panel/TopDialogue/VBoxContainer

var current_active_index : int = 0
var active_box : VBoxContainer
var option_boxes : Array = []
var option_box_ids : Array = []

signal option_picked(option_id : String)


func _process(_delta: float) -> void:
	handle_input()


func handle_input() -> void:
	if Input.is_action_just_pressed("Up"):
		increment_index(-1)
	elif Input.is_action_just_pressed("Down"):
		increment_index(1)
	elif Input.is_action_just_pressed("Interact"):
		emit_signal("option_picked", option_box_ids[current_active_index])


func increment_index(by_value : int) -> void:
	option_boxes[current_active_index].set_normal()
	current_active_index += by_value
	hold_index_boundaries()
	option_boxes[current_active_index].set_picked()


func hold_index_boundaries() -> void:
	if current_active_index < 0:
		current_active_index = option_boxes.size() - 1
	elif current_active_index >= option_boxes.size():
		current_active_index = 0


func show_top_box() -> void:
	bottom_box.visible = false
	top_box.visible = true


func set_options(option_ids : Array, options : Array) -> void:
	# Safety check
	if option_ids.size() != options.size():
		print("DialogueOptionManager: Given Option Id's don't match given options")
		return
	
	# Keep a maximum amount of options & use this to add id's
	var count : int = 0
	
	# Determine currently active box
	if bottom_box.visible:
		active_box = bottom_box
	else:
		active_box = top_box
	
	# Set and add options to the current active box
	for option in options:
		if count >= MAX_OPTIONS:
			continue
		# Create option bar
		var dialogue_option = load(option_scene).instantiate()
		active_box.add_child(dialogue_option)
		dialogue_option.set_text(option)
		# Add to option array
		option_box_ids.append(option_ids[count])
		option_boxes.append(dialogue_option)
		count += 1
	
	# Mark the first index as being picked by default
	option_boxes[current_active_index].set_picked()
