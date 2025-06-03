extends Node2D

@export var load_level : String
@export var spawn_index : int

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		call_deferred("change_level")

func change_level() -> void:
	GameManager.CHANGE_SCENE(load_level, spawn_index)
