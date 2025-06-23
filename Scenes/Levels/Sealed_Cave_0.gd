extends Node2D

const dirr_prefab : String = "res://Scenes/Characters/Dirr.tscn"
var dirr_instance : Dirr 

@onready var upperSpawn : Node2D = $PlayerSpawn

func _ready() -> void:
	await get_tree().process_frame
	setup()


func setup() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	
	if !MemoryManager.memory.dirr_at_0 && !MemoryManager.memory.dirr_follow_player:
		var old_dirr : Dirr = get_tree().get_first_node_in_group("Dirr")
		if old_dirr != null:
			old_dirr.queue_free()
			await get_tree().process_frame
		return
	
	if !MemoryManager.memory.dirr_spawned_01 && (MemoryManager.memory.dirr_look_back || MemoryManager.memory.dirr_nothing):
		var dirr = preload(dirr_prefab)
		dirr_instance = dirr.instantiate()
		get_tree().current_scene.add_child(dirr_instance)
		dirr_instance.global_position = upperSpawn.global_position
		
		dirr_instance.current_target_position = dirr_instance.global_position + Vector2(0, 180)
		dirr_instance.static_collider.disabled = true
		MemoryManager.memory.dirr_follow_player = false
		MemoryManager.memory.dirr_spawned_01 = true
