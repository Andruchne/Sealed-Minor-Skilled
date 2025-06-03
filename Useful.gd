extends Node2D

func GET_ANIMATION_STATES(anim : AnimatedSprite2D) -> Dictionary:
	var a_name : String = anim.name
	var dict : Dictionary = {
		a_name + "_animation" : anim.animation,
		a_name + "_frame" : anim.frame,
		a_name + "_flip_h" : anim.flip_h,
		a_name + "_flip_v" : anim.flip_v
	}
	return dict


func APPLY_ANIMATION_STATES(anim : AnimatedSprite2D, anim_states : Dictionary) -> void:
	var a_name : String = anim.name
	
	anim.animation = anim_states.get(a_name + "_animation")
	anim.frame = anim_states.get(a_name + "_frame")
	anim.flip_h = anim_states.get(a_name + "_flip_h")
	anim.flip_v = anim_states.get(a_name + "_flip_v")


func APPROX(value : float, aim_value : float, tolerance : float) -> bool:
	return abs(value - aim_value) <= tolerance
