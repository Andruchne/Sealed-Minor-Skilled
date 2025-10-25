extends Node
class_name Activator

var active : bool = false

var was_activated : bool = false

@export var specific_ids : Array[int] = [0]
@export var access_indexes : Array[int] = [0]
@export var total : bool = false

signal activated()
signal deactivated()

signal total_activated()
signal total_deactivated()


func get_save_state() -> Dictionary:
	var dict : Dictionary = {
		"active" : active,
		"was_activated" : was_activated
	}
	return dict


func apply_save_state(state : Dictionary) -> void:
	active = state.get("active")
	was_activated = state.get("was_activated")


func emit_activated() -> void:
	if !total:
		emit_signal("activated")
	else:
		emit_signal("total_activated")


func emit_deactivated() -> void:
	if !total:
		emit_signal("deactivated")
	else:
		emit_signal("total_deactivated")
