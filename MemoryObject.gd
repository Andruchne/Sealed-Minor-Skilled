extends Node
class_name MemoryObject

# For memory kept over saves
var memory_keeper : MemoryKeeperObject

# Temporarily holds items
var cobweb : bool

# Actual memory of actions
var dirr_look_back : bool
var dirr_nothing : bool
var dirr_prepare_snack : bool

var memory_holder : Dictionary[String, bool]


func _ready() -> void:
	setup()


func setup() -> void:
	add_entry("cobweb")
	add_entry("dirr_look_back")
	add_entry("dirr_nothing")
	add_entry("dirr_prepare_snack")


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


func check_keeper_memory(entry : String) -> bool:
	return memory_keeper.check_memory(entry)


func set_memory(entry : String, state : bool) -> void:
	if get(entry) != null:
		set(entry, state)


func set_memory_keeper(entry : String, state : bool) -> void:
	if get(entry) != null:
		memory_keeper.set(entry, state)
