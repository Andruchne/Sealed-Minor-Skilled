extends Node

var memory : MemoryObject = MemoryObject.new()


func remembers(memory_entry : String) -> bool:
	return memory.check_memory(memory_entry)


func remembers_keeper(memory_entry : String) -> bool:
	return memory.check_keeper_memory(memory_entry)


func set_memory(memory_entry : String, state : bool) -> void:
	memory.set_memory(memory_entry, state)


func set_memory_keeper(memory_entry : String, state : bool) -> void:
	memory.set_memory_keeper(memory_entry, state)
