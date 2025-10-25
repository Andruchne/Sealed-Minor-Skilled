extends Area2D

@export var dialogue_trigger : bool

var entered_once : bool
var lever : Node2D

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	lever = get_tree().get_first_node_in_group("Lever")
	
	if !area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") && !entered_once && !dialogue_trigger:
		lever.on_interact(area)
		entered_once = true
	elif MemoryManager.memory.dirr_follow_player && !entered_once && dialogue_trigger:
		var dirr : Dirr = get_tree().get_first_node_in_group("Dirr")
		if dirr != null:
			dirr.start_dialogue("right_direction_dialogue")
			entered_once = true


func get_save_state() -> Dictionary:
	var dict : Dictionary = {
		"entered_once" : entered_once,
	}
	return dict


func apply_save_state(state : Dictionary) -> void:
	entered_once = state.get("entered_once")
