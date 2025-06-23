extends Node2D

@export var load_level : String
@export var spawn_index : int

@onready var area2D : Area2D = $Area2D

var is_active : bool = true : set = is_active_changed

var entered : Array = []


func _ready() -> void:
	if !area2D.area_entered.is_connected(_on_area_2d_area_entered):
		area2D.area_entered.connect(_on_area_2d_area_entered)
	if !area2D.area_exited.is_connected(_on_area_2d_area_exited):
		area2D.area_exited.connect(_on_area_2d_area_exited)


func _on_area_2d_area_entered(area: Area2D) -> void:
	entered.append(area)
	if is_active && area.is_in_group("Player"):
		call_deferred("change_level")

func change_level() -> void:
	GameManager.CHANGE_SCENE(load_level, spawn_index)


func is_active_changed(state : bool) -> void:
	is_active = state
	if state:
		for ent in entered:
			if ent.is_in_group("Player"):
				call_deferred("change_level")

func _on_area_2d_area_exited(area: Area2D) -> void:
	entered.remove_at(entered.find(area))
