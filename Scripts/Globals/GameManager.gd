extends Node2D

var soulcheck : String = "res://Scenes/Levels/Minigame_Soulcheck.tscn"

# To cap fps
var FPS_MAX : int = 60
# To manage whether main game is running or not, e.g. if characters can move
var MAIN_ACTIVE : bool = true

signal minigame_triggered()
signal minigame_finished()

func _ready() -> void:
	CAP_FPS()


func CAP_FPS() -> void:
	Engine.max_fps = FPS_MAX


func TRIGGER_SOULCHECK() -> void:
	var soulcheck_minigame = load(soulcheck).instantiate()
	get_tree().current_scene.add_child(soulcheck_minigame)
	MAIN_ACTIVE = false
	print("huhu")

func MINIGAME_END() -> void:
	minigame_finished.emit()
	MAIN_ACTIVE = true
