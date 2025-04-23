extends Control

var save_slots : Array[SaveSlot]


func _ready() -> void:
	setup()


func setup() -> void: 
	get_slots()
	show_existing_saves()


func get_slots() -> void:
	var children = get_children() 
	for child in children:
		save_slots.append(child as SaveSlot)
	
	for slot in save_slots:
		pass


func get_saves() -> Array:
	var saves := []
	var dir := DirAccess.open("user://saves")
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				saves.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	
	return saves


func show_existing_saves() -> void:
	var saves = get_saves()
	for i in range(save_slots.size()):
		if i < saves.size():
			var save_data = ResourceLoader.load(GameManager.SAVE_GAME_PATH)
			if save_data is GameSaveData:
				save_slots[i].set_info(saves[i].get_basename(), save_data.player_info)
		else:
			save_slots[i].clear_spot()


func save_into_slot(slot : SaveSlot) -> void:
	pass
