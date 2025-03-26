extends Node2D

var main_camera : Camera2D

@onready var minigame_cam : Camera2D = $Camera2D
@onready var player : Node2D = $PlayerSoul

func _ready() -> void:
	main_camera = get_viewport().get_camera_2d()
	minigame_cam.make_current()
	player.minigame_finished.connect(on_minigame_finished)


func on_minigame_finished() -> void:
	main_camera.make_current()
	GameManager.MINIGAME_END()
	queue_free()
