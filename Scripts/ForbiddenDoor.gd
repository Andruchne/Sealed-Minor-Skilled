extends Node2D

@onready var door : AnimatedSprite2D = $Door
@onready var door_moss : AnimatedSprite2D = $DoorMoss
@onready var flame : AnimatedSprite2D = $"32x32_SoulFlame"

var is_completed : bool
var is_cleared : bool
var is_open : bool

var new_scene = preload("res://Scenes/Levels/SealedCave_1.tscn")

func on_interact(player : Node2D) -> void:
	if !is_cleared && !is_completed:
		GameManager.minigame_finished.connect(on_minigame_finished)
		player.begin_minigame("Soulcheck")
	elif is_cleared && !is_open && !door.is_playing():
		door.play("Open")
		door_moss.play("Open")
	elif is_open:
		pass


func on_minigame_finished(has_won : bool) -> void:
	if has_won:
		flame.play("Off")
		is_completed = true


func _on_32_soul_flame_animation_finished() -> void:
	is_cleared = true


func _on_door_animation_finished() -> void:
	if is_cleared:
		is_open = true
