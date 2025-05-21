extends Node2D

@onready var door : AnimatedSprite2D = $Door
@onready var door_moss : AnimatedSprite2D = $DoorMoss
@onready var flame : AnimatedSprite2D = $"32x32_SoulFlame"

var is_completed : bool
var is_cleared : bool
var is_open : bool

var new_scene : String = "res://Scenes/Levels/SealedCave_1.tscn"

func on_interact(player : Node2D) -> void:
	if !is_cleared && !is_completed:
		GameManager.minigame_finished.connect(on_minigame_finished)
		player.begin_minigame("Soulcheck")
	elif is_cleared && !is_open && !door.is_playing():
		door.play("Open")
		door_moss.play("Open")
	elif is_open:
		GameManager.CHANGE_SCENE(new_scene)


func on_minigame_finished(has_won : bool) -> void:
	GameManager.minigame_finished.disconnect(on_minigame_finished)
	if has_won:
		flame.play("Off")
		is_completed = true


func _on_32_soul_flame_animation_finished() -> void:
	is_cleared = true


func _on_door_animation_finished() -> void:
	if is_cleared:
		is_open = true


func get_save_state() -> Dictionary:
	var dict : Dictionary = {
		"is_completed" : is_completed,
		"is_cleared" : is_cleared,
		"is_open" : is_open
	}
	var door_state : Dictionary = Useful.GET_ANIMATION_STATES(door)
	var door_moss_state : Dictionary = Useful.GET_ANIMATION_STATES(door_moss)
	var flame_state : Dictionary = Useful.GET_ANIMATION_STATES(flame)
	
	for key in door_state:
		dict[key] = door_state[key]
	for key in door_moss_state:
		dict[key] = door_moss_state[key]
	for key in flame_state:
		dict[key] = flame_state[key]
	
	return dict


func apply_save_state(state : Dictionary) -> void:
	is_completed = state.get("is_completed")
	is_cleared = state.get("is_cleared")
	is_open = state.get("is_open")
	
	Useful.APPLY_ANIMATION_STATES(door, state)
	Useful.APPLY_ANIMATION_STATES(door_moss, state)
	Useful.APPLY_ANIMATION_STATES(flame, state)
