extends Node
class_name MemoryKeeperObject

var cobweb_snack : bool
var cobweb_tasted : bool


func check_memory(entry : String) -> bool:
	var result : bool = get(entry)
	if result != null:
		return result
	else:
		return false


func set_memory(entry : String, state : bool) -> void:
	if get(entry) != null:
		set(entry, state)
