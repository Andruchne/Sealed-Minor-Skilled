extends Node

func _process(_delta: float) -> void:
	input_quicksave_quickload()
	input_main_menu()


func input_quicksave_quickload() -> void:
	if Input.is_action_just_pressed("Quicksave"):
		GameManager.SAVE_GAME("Quicksave", 0, true)
	elif Input.is_action_just_pressed("Quickload"):
		GameManager.LOAD_GAME(0)


func input_main_menu() -> void:
	if Input.is_action_just_pressed("Esc"):
		GameManager.TOGGLE_GAME_MENU()
