extends Control

var save_slots : Array


func _ready() -> void:
	setup()


func setup() -> void: 
	get_slots()
	show_existing_saves()


func get_slots() -> void:
	var children = get_children() 
	for child in children:
		if child is SaveSlot:
			save_slots.append(child as SaveSlot)
		elif child is LoadSlot:
			save_slots.append(child as LoadSlot)
	
	for slot in save_slots:
		slot.button_pressed.connect(show_existing_saves)


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
		var success : bool
		
		for save in saves:
			var index : int = get_save_index(save)
			
			if index != -1 && index == save_slots[i].save_index:
				var save_data = ResourceLoader.load(GameManager.get_save_file(str(i)))
				if save_data is GameSaveData:
					save_slots[i].set_info(save_data)
					success = true
			
			var save_data = ResourceLoader.load(GameManager.get_save_file(str(i)))
			if save_data is GameSaveData:
				save_slots[i].set_info(save_data)
				
		if !success:
			save_slots[i].clear_spot()


func get_save_index(filename : String) -> int:
	var underscore_pos : int = filename.find("_")
	if underscore_pos != -1:
		var number_str := filename.substr(0, underscore_pos)
		return int(number_str)
	
	return -1
