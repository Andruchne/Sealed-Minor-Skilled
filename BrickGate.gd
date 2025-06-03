extends Node2D

@onready var gate : AnimatedSprite2D = $Gate
@onready var collider : CollisionShape2D = $StaticBody2D/CollisionShape2D

var is_open : bool
var current_active : int

var activators : Array[Activator] = []


func _ready() -> void:
	await get_tree().process_frame
	connect_activators()


func connect_activators() -> void:
	var nodes : Array = get_tree().get_nodes_in_group("Activator")
	activators.clear()
	
	for node in nodes:
		if is_instance_valid(node) && node != null && node.is_inside_tree():
			activators.append(node as Activator)
	
	for activator in activators:
		if activator && activator is Activator:
			activator.activated.connect(add_active)
			activator.deactivated.connect(remove_active)


func on_interact(_player : Node2D) -> void:
	pass


func _on_gate_animation_finished() -> void:
	if gate.animation == "Open":
		is_open = true
		collider.disabled = true


func _on_gate_animation_changed() -> void:
	if gate != null && gate.animation == "Close":
		is_open = false
		collider.disabled = false


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


func check_state() -> void:
	# Open Gate
	if !is_open && current_active == activators.size():
		var start_frame : int = 0
		if gate.animation == "Close":
			# Get appropriate frame to start with, in case switching mid anim
			start_frame = gate.sprite_frames.get_frame_count(gate.animation) - gate.frame
		gate.play("Open")
		gate.frame = start_frame
	# Close Gate
	elif is_open && current_active < activators.size():
		gate.play("Close")
	# Close Gate mid Open anim
	elif !is_open && gate.animation == "Open":
		var start_frame : int = 0
		# Get appropriate frame to start with, in case switching mid anim
		start_frame = gate.sprite_frames.get_frame_count(gate.animation) - gate.frame
		gate.play("Close")
		gate.frame = start_frame
