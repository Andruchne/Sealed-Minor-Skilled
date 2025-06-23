extends Node2D

@export var level_index : int = 1
@export var access_index : int = 0

@export var dialogue_actions : Dictionary[String, String]

@onready var gate : AnimatedSprite2D = $Gate
@onready var collider : CollisionShape2D = $StaticBody2D/CollisionShape2D

@onready var gate_dialogue : DialogueHolder = $DialogueHolder

var is_open : bool
var current_active : int

var activators : Array[Activator] = []
var activator_count : int = 0


var is_interactable : bool = true
@onready var cooldown_timer : Timer = $Timer


func _ready() -> void:
	await get_tree().process_frame
	setup()
	connect_activators()


func setup() -> void:
	if !gate.animation_changed.is_connected(_on_gate_animation_changed):
		gate.animation_changed.connect(_on_gate_animation_changed)
	if !gate.animation_finished.is_connected(_on_gate_animation_finished):
		gate.animation_finished.connect(_on_gate_animation_finished)
	if !cooldown_timer.timeout.is_connected(_on_timer_timeout):
		cooldown_timer.timeout.connect(_on_timer_timeout)


func connect_activators() -> void:
	var nodes : Array = get_tree().get_nodes_in_group("Activator")
	activators.clear()
	
	var total_count : int = 0
	
	for node in nodes:
		if is_instance_valid(node) && node != null && node.is_inside_tree():
			for i in (node as Activator).access_indexes:
				if i == access_index:
					activators.append(node as Activator)
					if (node as Activator).total:
						total_count += 1
	
	activator_count = activators.size() - total_count
	
	for activator in activators:
		if activator && activator is Activator:
			activator.activated.connect(add_active)
			activator.deactivated.connect(remove_active)
			activator.total_activated.connect(add_total_active)
			activator.total_deactivated.connect(remove_total_active)


func on_interact(_player : Node2D) -> void:
	if is_interactable:
		if !MemoryManager.memory.squeezed_gap:
			start_dialogue("gate_squeeze")
		else:
			start_dialogue("gate_smell")
		is_interactable = false


func start_dialogue(dialogue : String) -> void:
	DialogueManager.dialogue_finished.connect(on_dialogue_finished)
	DialogueManager.POPUP_DIALOGUE(gate_dialogue.get_dialogue(dialogue), true)


func on_dialogue_finished(finish_id : String) -> void:
	DialogueManager.dialogue_finished.disconnect(on_dialogue_finished)
	# Not pretty, but temporary fix for reusable dialogue
	gate_dialogue._ready()
	cooldown_timer.start()
	do_action_after_dialogue(finish_id)


func do_action_after_dialogue(finish_id : String) -> void:
	if dialogue_actions.has(finish_id):
		var func_name = dialogue_actions[finish_id]
		if has_method(func_name):
			call(func_name)


func squeezed_action() -> void:
	MemoryManager.memory.squeezed_gap = true
	MemoryManager.update_general_memory()


func _on_gate_animation_finished() -> void:
	if gate.animation == "Open":
		is_open = true
		collider.disabled = true
		is_interactable = false
		if level_index == 1:
			MemoryManager.memory.sc0_gate_open = true
		elif level_index == 2:
			if access_index == 0:
				MemoryManager.memory.sc2_gate_open_0 = true
			else:
				MemoryManager.memory.sc2_gate_open_1 = true


func _on_gate_animation_changed() -> void:
	if gate != null && gate.animation == "Close":
		is_open = false
		collider.disabled = false
		is_interactable = true
		if level_index == 1:
			MemoryManager.memory.sc0_gate_open = false


func get_save_state() -> Dictionary:
	var dict : Dictionary = {
		"is_open" : is_open
	}
	var gate_state : Dictionary = Useful.GET_ANIMATION_STATES(gate)
	
	for key in gate_state:
		dict[key] = gate_state[key]
	
	return dict


func apply_save_state(state : Dictionary) -> void:
	is_open = state.get("is_open")
	
	Useful.APPLY_ANIMATION_STATES(gate, state)


func add_active() -> void:
	current_active += 1
	check_state()


func remove_active() -> void:
	current_active -= 1
	check_state()


func add_total_active() -> void:
	current_active += activator_count
	check_state()


func remove_total_active() -> void:
	current_active -= activator_count
	check_state()


func check_state() -> void:
	# Open Gate
	if !is_open && current_active == activator_count:
		var start_frame : int = 0
		if gate.animation == "Close":
			# Get appropriate frame to start with, in case switching mid anim
			start_frame = gate.sprite_frames.get_frame_count(gate.animation) - gate.frame
		gate.play("Open")
		gate.frame = start_frame
	# Close Gate
	elif is_open && current_active < activator_count:
		gate.play("Close")
	# Close Gate mid Open anim
	elif !is_open && gate.animation == "Open":
		var start_frame : int = 0
		# Get appropriate frame to start with, in case switching mid anim
		start_frame = gate.sprite_frames.get_frame_count(gate.animation) - gate.frame
		gate.play("Close")
		gate.frame = start_frame


func _on_timer_timeout() -> void:
	is_interactable = true
