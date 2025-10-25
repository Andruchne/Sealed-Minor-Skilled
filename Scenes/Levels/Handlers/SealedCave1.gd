extends Node2D

const dirr_prefab : String = "res://Scenes/Characters/Dirr.tscn"
var dirr_instance : Dirr 

@onready var lowerSpawn : Node2D = $PlayerSpawn_0

func _ready() -> void:
	await get_tree().process_frame
	setup()


func setup() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	
	if !MemoryManager.memory.dirr_at_1 && !MemoryManager.memory.dirr_follow_player:
		await get_tree().process_frame
		await get_tree().process_frame
		var old_dirr : Dirr = get_tree().get_first_node_in_group("Dirr")
		if old_dirr != null:
			old_dirr.queue_free()
			await get_tree().process_frame
		return
	
	if !MemoryManager.memory.dirr_spawned_02 && (MemoryManager.memory.window_race || MemoryManager.memory.dirr_go_home):
		var old_dirr : Dirr = get_tree().get_first_node_in_group("Dirr")
		if old_dirr != null:
			old_dirr.queue_free()
		var dirr = preload(dirr_prefab)
		dirr_instance = dirr.instantiate()
		get_tree().current_scene.add_child(dirr_instance)
		dirr_instance.global_position = lowerSpawn.global_position + Vector2(0, -50)
		dirr_instance.move_through_gate()
		dirr_instance.state_move_through_gate = true
		dirr_instance.static_collider.disabled = true
		
		MemoryManager.memory.dirr_spawned_02 = true
