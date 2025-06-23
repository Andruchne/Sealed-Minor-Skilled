extends Area2D

var cobweb_trigger : bool
var cobweb_dialogue_triggered : bool


func _process(_delta: float) -> void:
	cobweb_dialogue_check()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") && (MemoryManager.memory.dirr_nothing || MemoryManager.memory.dirr_look_back):
		cobweb_trigger = true


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player") && (MemoryManager.memory.dirr_nothing || MemoryManager.memory.dirr_look_back):
		cobweb_trigger = false


func cobweb_dialogue_check() -> void:
	if cobweb_trigger && !cobweb_dialogue_triggered:
		if MemoryManager.memory.cobweb:
			if MemoryManager.memory.dirr_nothing:
				var dirr : Dirr = get_tree().get_first_node_in_group("Dirr")
				dirr.start_dialogue("really_nothing_dialogue")
			if MemoryManager.memory.dirr_look_back:
				var dirr : Dirr = get_tree().get_first_node_in_group("Dirr")
				dirr.start_dialogue("found_nothing_dialogue")
		else:
			var dirr : Dirr = get_tree().get_first_node_in_group("Dirr")
			dirr.start_dialogue("found_cobweb_dialogue")
			MemoryManager.memory.knows_cobweb = true
			MemoryManager.update_general_memory()
		cobweb_dialogue_triggered = true
