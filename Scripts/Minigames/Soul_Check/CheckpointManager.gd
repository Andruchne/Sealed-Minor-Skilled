extends Node2D

@export var first_checkpoint_color : Color
@export var second_checkpoint_color : Color
@export var third_checkpoint_color : Color

@export var alt_first_checkpoint_color : Color
@export var alt_second_checkpoint_color : Color
@export var alt_third_checkpoint_color : Color

var checkpoints : Array
var current_active_checkpoints : Array

var start_index : int = 0
@onready var interval : Timer = $Interval

var alt_color : bool = false

signal checkpoints_cleared()


func _ready() -> void:
	alt_color = MemoryManager.memory.alt_color
	checkpoints = get_tree().get_nodes_in_group("Checkpoint")
	# Hide all checkpoints
	for cp in checkpoints:
		cp.visible = false
		cp.checkpoint_checked.connect(on_checkpoint_checked)
	
	# Take first three checkpoints
	for i in range(3):
		add_next_checkpoint()


func add_next_checkpoint() -> void:
	if checkpoints.size() > 0:
		current_active_checkpoints.append(checkpoints[0])
		checkpoints.remove_at(0)


func set_alt_color(new_state : bool) -> void:
	if alt_color == new_state:
		return 
	
	MemoryManager.memory.alt_color = new_state
	alt_color = new_state
	set_checkpoint_activeness()


func set_first_checkpoint_activeness() -> void:
	if current_active_checkpoints.size() <= 0:
		return
	
	var cp = current_active_checkpoints[start_index]
	if cp != null && is_instance_valid(cp):
		var set_color : Color
		match start_index:
			0:
				cp.set_active(true)
				if !alt_color:
					set_color = first_checkpoint_color
				else:
					set_color = alt_first_checkpoint_color
			1:
				if !alt_color:
					set_color = second_checkpoint_color
				else:
					set_color = alt_second_checkpoint_color
			2:
				if !alt_color:
					set_color = third_checkpoint_color
				else:
					set_color = alt_third_checkpoint_color
		
		var tween = create_tween()
		tween.tween_property(cp, "modulate", set_color, 0.25).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		cp.visible = true
		start_index += 1
	
	if start_index >= current_active_checkpoints.size():
		start_index = 0
	else:
		interval.start()


func set_checkpoint_activeness() -> void:
	var index : int = 0
	for cp in current_active_checkpoints:
		var set_color : Color
		match index:
			0:
				cp.set_active(true)
				if !alt_color:
					set_color = first_checkpoint_color
				else:
					set_color = alt_first_checkpoint_color
			1:
				if !alt_color:
					set_color = second_checkpoint_color
				else:
					set_color = alt_second_checkpoint_color
			2:
				if !alt_color:
					set_color = third_checkpoint_color
				else:
					set_color = alt_third_checkpoint_color
		
		var tween = create_tween()
		tween.tween_property(cp, "modulate", set_color, 0.4).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		cp.visible = true
		index += 1


func on_checkpoint_checked() -> void:
	current_active_checkpoints.remove_at(0)
	add_next_checkpoint()
	set_checkpoint_activeness()
	check_completion()


func check_completion() -> void:
	if checkpoints.size() <= 0 && current_active_checkpoints.size() <= 0:
		emit_signal("checkpoints_cleared") 


func _on_interval_timeout() -> void:
	set_checkpoint_activeness()
