extends AnimatedSprite2D

@export var checked_color : Color
@export var color_trans_duration : float = sprite_frames.get_frame_duration("Transition", 0)

var checked : bool = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	if !checked && area.is_in_group("Draw_Check"):
		play("Transition")
		transition_color()
		checked = true

func transition_color() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", checked_color, color_trans_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
