extends Control

const intro : String = "res://Scenes/Levels/Intro_Screen.tscn"


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Interact"):
		GameManager.CHANGE_SCENE(intro)
