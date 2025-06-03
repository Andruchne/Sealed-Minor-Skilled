extends Node
class_name Activator

var active : bool = false

var was_activated : bool = false

signal activated()
signal deactivated()


func get_save_state() -> Dictionary:
	var dict : Dictionary = {
		"active" : active,
		"was_activated" : was_activated
	}
	return dict


func apply_save_state(state : Dictionary) -> void:
	active = state.get("active")
	was_activated = state.get("was_activated")


func signals() -> void:
	emit_signal("activated")
	emit_signal("deactivated")
