extends Node2D

var canvas_layer : CanvasLayer

#savegame.tres
const SAVE_GAME_PATH = "user://saves/"

var soulcheck : String = "res://Scenes/Levels/Minigame_Soulcheck.tscn"

var popup_label : String = "res://Scenes/UI/Popup_Label.tscn"
var current_label : Popup_Label 

var game_menu : String = "res://Scenes/UI/Game_Menu.tscn"
var current_game_menu : Control

# To cap fps
var FPS_MAX : int = 60
# To manage whether main game is running or not, e.g. if characters can move
var MAIN_ACTIVE : bool = true

signal minigame_triggered()
signal minigame_finished(has_won : bool)

signal scene_changed()


func _ready() -> void:
	setup_folder()
	CAP_FPS()
	SET_LANGUAGE("en")
	get_canvas_layer()


func setup_folder() -> void:
	# Will only create this directory, if it doesn't already exist
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(SAVE_GAME_PATH):
		var error = dir.make_dir_recursive(SAVE_GAME_PATH)
		if error != OK:
			push_error("Error: Unable to create save folder")


func CAP_FPS() -> void:
	Engine.max_fps = FPS_MAX


func SET_LANGUAGE(language : String) -> void:
	TranslationServer.set_locale(language)


func TRIGGER_SOULCHECK() -> void:
	emit_signal("minigame_triggered")
	var soulcheck_minigame = load(soulcheck).instantiate()
	get_tree().current_scene.add_child(soulcheck_minigame)
	MAIN_ACTIVE = false


func MINIGAME_END(has_won : bool) -> void:
	emit_signal("minigame_finished", has_won)
	MAIN_ACTIVE = true


func CHANGE_SCENE(new_scene : String, spawn_index : int = 0) -> void:
	MemoryManager.save_level_state()
	MemoryManager.load_level_state(new_scene, spawn_index)
	await get_tree().process_frame
	emit_signal("scene_changed")
	get_canvas_layer()
	await get_tree().process_frame
	spawn_player(spawn_index)


func get_canvas_layer() -> void:
	await get_tree().process_frame
	canvas_layer = get_tree().get_first_node_in_group("Canvas")
	if canvas_layer == null:
		print("GameManager: No CanvasLayer found in current scene.")


func spawn_player(spawn_index : int) -> void:
	var spawn_positions : Array = get_tree().get_nodes_in_group("PlayerSpawn")
	var gotten_player = get_tree().get_first_node_in_group("Player")
	for spawn in spawn_positions:
		if spawn.spawn_index == spawn_index:
			gotten_player.position = spawn.position
			gotten_player.handle_animation(spawn.look_direction)
			gotten_player.last_direction = spawn.look_direction


func SAVE_GAME(save_name : String, save_index : int = 0, is_quicksave : bool = false) -> void:
	if is_quicksave && !MAIN_ACTIVE:
		return
	
	delete_existing_save_files(str(save_index))
	var save_data := GameSaveData.new()
	
	save_data.save_index = save_index
	save_data.save_name = save_name
	
	var current_player = get_tree().get_first_node_in_group("Player")
	save_data.player_info = current_player.get_player_info()
	
	# Save current scene root
	var root := get_tree().current_scene
	var root_packed := PackedScene.new()
	root_packed.pack(root)
	save_data.level_data.scene_root = root_packed

	# Save GameObjects and their state
	var objects := root.get_tree().get_nodes_in_group("GameObject")

	for obj in objects:
		var packed := PackedScene.new()
		packed.pack(obj)
		save_data.level_data.game_object_scenes.append(packed)

		if obj.has_method("get_save_state"):
			save_data.level_data.game_object_states.append(obj.get_save_state())
		else:
			save_data.level_data.game_object_states.append(null)
	
	ResourceSaver.save(save_data, create_save_path(save_name, save_index))
	
	show_label("Saved", Popup_Label.Save_Text_Type.Exclamation)


func LOAD_GAME(load_index : int) -> void:
	var save_data = ResourceLoader.load(get_save_file(str(load_index)))
	
	if save_data is GameSaveData:
		var instances : Array = []
		
		# Free current root scene
		var old_root := get_tree().current_scene
		if old_root:
			old_root.queue_free()

		# Replace root with saved scene
		if save_data.level_data.scene_root && save_data.level_data.scene_root is PackedScene:
			var new_root = save_data.level_data.scene_root.instantiate()
			get_tree().root.add_child(new_root)
			get_tree().current_scene = new_root

			# Replace GameObjects under new root
			var game_objects : Array = new_root.get_tree().get_nodes_in_group("GameObject")
			for obj in game_objects:
				obj.queue_free()
			
			await get_tree().process_frame
			
			for i in save_data.level_data.game_object_scenes.size():
				var packed_scene = save_data.level_data.game_object_scenes[i]
				if packed_scene && packed_scene is PackedScene:
					var instance = packed_scene.instantiate()
					instances.append(instance)
					new_root.add_child(instance)

					if i < save_data.level_data.game_object_states.size():
						var state = save_data.level_data.game_object_states[i]
						if instance.has_method("apply_save_state"):
							instance.apply_save_state(state)
			
			for instance in instances:
				if instance.has_method("after_load_init"):
					instance.call_deferred("after_load_init")
		
		get_canvas_layer()
		MAIN_ACTIVE = true
		await get_tree().process_frame
		show_label("Loaded", Popup_Label.Save_Text_Type.Exclamation)


func show_label(text : String, type : Popup_Label.Save_Text_Type) -> void:
	if current_label:
		current_label.queue_free()
	
	current_label = load(popup_label).instantiate()
	canvas_layer.add_child(current_label)
	current_label.popup_text(text, type)


func TOGGLE_GAME_MENU() -> void:
	if current_game_menu == null:
		current_game_menu = load(game_menu).instantiate()
		canvas_layer.add_child(current_game_menu)
		GameManager.MAIN_ACTIVE = false
	else:
		current_game_menu.queue_free()
		GameManager.MAIN_ACTIVE = true


func get_save_file(search_number: String) -> String:
	var dir = DirAccess.open(SAVE_GAME_PATH)
	if dir == null:
		return ""
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.begins_with(search_number):
				dir.list_dir_end()
				return SAVE_GAME_PATH.path_join(file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return ""


func create_save_path(save_name : String, save_index : int) -> String:
	var save_file : String = "%d_%s.tres" % [save_index, save_name]
	var path : String = SAVE_GAME_PATH + save_file
	return path


func delete_existing_save_files(search_number: String) -> void:
	var dir = DirAccess.open(SAVE_GAME_PATH)
	if dir == null:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.begins_with(search_number):
				var full_path = SAVE_GAME_PATH.path_join(file_name)
				DirAccess.remove_absolute(full_path)
		file_name = dir.get_next()
	
	dir.list_dir_end()
