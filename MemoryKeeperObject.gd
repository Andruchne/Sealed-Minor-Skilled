extends Node
class_name MemoryKeeperObject

var cobweb_snack : bool
var cobweb_tasted : bool

var memory_holder : Dictionary[String, bool]


func setup() -> void:
	add_entry("cobweb_snack")
	add_entry("cobweb_tasted")


func add_entry(new_entry : String) -> void: 
	if get(new_entry) != null:
		memory_holder[new_entry] = get(new_entry)
	else:
		push_error("Variable " + new_entry + " does not exist")


func check_memory(entry : String) -> bool:
	if memory_holder.has(entry):
		return memory_holder[entry]
	else:
		return false


func set_memory(entry : String, state : bool) -> void:
	if get(entry) != null:
		set(entry, state)
