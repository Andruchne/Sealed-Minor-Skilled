extends Node2D
class_name MemoryObject

# For memory kept over saves
var memory_keeper : MemoryKeeperObject

# Temporarily holds items
var cobweb : bool

var alt_color : bool

# Actual memory of actions
var dirr_look_back : bool
var dirr_nothing : bool
var dirr_prepare_snack : bool

# Soul actions
var soul_intro_played : bool
var soul_green_guide : bool
var soul_green_hit_once : bool
var soul_warned_trace : bool
var soul_first_win : bool
var soul_intro_second_try : bool


func check_memory(entry : String) -> bool:
	var result : bool = get(entry)
	if result != null:
		return result
	else:
		return false


func check_keeper_memory(entry : String) -> bool:
	return memory_keeper.check_memory(entry)


func set_memory(entry : String, state : bool) -> void:
	if get(entry) != null:
		set(entry, state)


func set_memory_keeper(entry : String, state : bool) -> void:
	if get(entry) != null:
		memory_keeper.set(entry, state)
