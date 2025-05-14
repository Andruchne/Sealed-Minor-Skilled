extends Control

@onready var background : Panel = $Panel/BlackBackground

@export var transition_duration : float = 0.5

signal transition_finished()

func uncover_screen() -> void:
	set_background(0)


func cover_screen() -> void:
	set_background(1)

# Getting in
func transition_in() -> void:
	transition_background(0)

# Getting out
func transition_out() -> void:
	transition_background(1)


func transition_background(target_alpha : float) -> void:
	var tween = create_tween()
	tween.tween_property(background, "modulate", Color(background.modulate, target_alpha), transition_duration).set_trans(Tween.TRANS_LINEAR)
	tween.connect("finished", _on_tween_finished)


func set_background(target_alpha : float) -> void:
	background.modulate = Color(background.modulate, target_alpha)


func _on_tween_finished() -> void:
	transition_finished.emit()
