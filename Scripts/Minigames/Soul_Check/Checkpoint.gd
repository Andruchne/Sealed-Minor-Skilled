extends AnimatedSprite2D

@export var checked_color : Color
@export var color_trans_duration : float = sprite_frames.get_frame_duration("Transition", 0)

var checked : bool = false
var active : bool = false
# Second bool, because we're listening to two area entered signals
# As both checked for one and the same bool, toggling it as well, I implemented a second one
var private_active : bool = false

signal checkpoint_checked()


func interacted() -> void:
	if active && !checked:
		play("Transition")
		transition_color()
		checked = true
		emit_signal("checkpoint_checked")
		set_active(false)
	elif !active && !checked && !is_playing():
		play("InvalidCheck")


func transition_color() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", checked_color, color_trans_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func set_active(state : bool) -> void:
	active = state
