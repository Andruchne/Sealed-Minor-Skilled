extends Node2D

var soulcheck : String = "res://Scenes/Levels/Minigame_Soulcheck.tscn"

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
	emit_signal("scene_changed")
