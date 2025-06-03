extends Node2D

var level_memory : Dictionary[String, LevelData]
var memory : MemoryObject = MemoryObject.new()


func remembers(memory_entry : String) -> bool:
	return memory.check_memory(memory_entry)


func remembers_keeper(memory_entry : String) -> bool:
	return memory.check_keeper_memory(memory_entry)


func set_memory(memory_entry : String, state : bool) -> void:
	memory.set_memory(memory_entry, state)


func set_memory_keeper(memory_entry : String, state : bool) -> void:
	memory.set_memory_keeper(memory_entry, state)


func save_level_state() -> void:
	var current_level : LevelData = LevelData.new()
	
	# Save current scene root
	var root := get_tree().current_scene
	var root_packed := PackedScene.new()
	root_packed.pack(root)
	current_level.scene_root = root_packed

	# Save GameObjects and their state
	var objects := root.get_tree().get_nodes_in_group("GameObject")

	for obj in objects:
		var packed := PackedScene.new()
		packed.pack(obj)
		current_level.game_object_scenes.append(packed)

		if obj.has_method("get_save_state"):
			current_level.game_object_states.append(obj.get_save_state())
		else:
			current_level.game_object_states.append(null)
	
	level_memory[root.name] = current_level


func load_level_state(load_level : String, spawn_index) -> void:
	var level_name : String = load_level.get_file().get_basename()
	
	if !level_memory.has(level_name):
		get_tree().change_scene_to_file(load_level)
		await get_tree().process_frame
		return
	
	var instances : Array = []
	var level_info : LevelData = level_memory[level_name]
	
	# Free current root scene
	var old_root := get_tree().current_scene
	if old_root:
		old_root.queue_free()

	# Replace root with saved scene
	if level_info.scene_root && level_info.scene_root is PackedScene:
		var new_root = level_info.scene_root.instantiate()
		get_tree().root.add_child(new_root)
		get_tree().current_scene = new_root

		# Replace GameObjects under new root
		var game_objects : Array = new_root.get_tree().get_nodes_in_group("GameObject")
		for obj in game_objects:
			obj.queue_free()
			
		await get_tree().process_frame
		await get_tree().process_frame
			
		for i in level_info.game_object_scenes.size():
			var packed_scene = level_info.game_object_scenes[i]
			if packed_scene && packed_scene is PackedScene:
				var instance = packed_scene.instantiate()
				instances.append(instance)
				new_root.add_child(instance)

				if i < level_info.game_object_states.size():
					var state = level_info.game_object_states[i]
					if instance.has_method("apply_save_state"):
						instance.apply_save_state(state)
			
		for instance in instances:
			if instance.has_method("after_load_init"):
				instance.call_deferred("after_load_init")
		
	GameManager.spawn_player(spawn_index)
