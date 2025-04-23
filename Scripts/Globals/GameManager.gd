extends Node2D

var canvas_layer : CanvasLayer

const SAVE_GAME_PATH = "user://saves/savegame.tres"

var soulcheck : String = "res://Scenes/Levels/Minigame_Soulcheck.tscn"

var popup_label : String = "res://Scenes/UI/Popup_Label.tscn"
var current_label : Popup_Label 

# To cap fps
var FPS_MAX : int = 60
# To manage whether main game is running or not, e.g. if characters can move
var MAIN_ACTIVE : bool = true

signal minigame_triggered()
signal minigame_finished(has_won : bool)

signal scene_changed()


func _ready() -> void:
	CAP_FPS()
	SET_LANGUAGE("en")
	get_canvas_layer()


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


func CHANGE_SCENE(new_scene : String) -> void:
	get_tree().change_scene_to_file(new_scene)
	get_canvas_layer()
	emit_signal("scene_changed")


func get_canvas_layer() -> void:
	await get_tree().process_frame
	canvas_layer = get_tree().get_first_node_in_group("Canvas")
	if canvas_layer == null:
		print("GameManager: No CanvasLayer found in current scene.")


func SAVE_GAME() -> void:
	if !MAIN_ACTIVE:
		return
	
	var save_data := GameSaveData.new()
	
	var player = get_tree().get_first_node_in_group("Player")
	save_data.player_info = player.get_player_info()
	
	# Save current scene root
	var root := get_tree().current_scene
	var root_packed := PackedScene.new()
	root_packed.pack(root)
	save_data.scene_root = root_packed

	# Save GameObjects and their state
	var objects := root.get_tree().get_nodes_in_group("GameObject")

	for obj in objects:
		var packed := PackedScene.new()
		packed.pack(obj)
		save_data.game_object_scenes.append(packed)

		if obj.has_method("get_save_state"):
			save_data.game_object_states.append(obj.get_save_state())
		else:
			save_data.game_object_states.append(null)

	ResourceSaver.save(save_data, SAVE_GAME_PATH)
	show_label("Saved", Popup_Label.Save_Text_Type.Exclamation)


func LOAD_GAME() -> void:
	var save_data = ResourceLoader.load(SAVE_GAME_PATH)
	if save_data is GameSaveData:
		# Free current root scene
		var old_root := get_tree().current_scene
		if old_root:
			old_root.queue_free()

		# Replace root with saved scene
		if save_data.scene_root && save_data.scene_root is PackedScene:
			var new_root = save_data.scene_root.instantiate()
			get_tree().root.add_child(new_root)
			get_tree().current_scene = new_root

			# Replace GameObjects under new root
			var game_objects : Array = new_root.get_tree().get_nodes_in_group("GameObject")
			for obj in game_objects:
				obj.queue_free()

			for i in save_data.game_object_scenes.size():
				var packed_scene = save_data.game_object_scenes[i]
				if packed_scene && packed_scene is PackedScene:
					var instance = packed_scene.instantiate()
					new_root.add_child(instance)

					if i < save_data.game_object_states.size():
						var state = save_data.game_object_states[i]
						if instance.has_method("apply_save_state"):
							instance.apply_save_state(state)

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
