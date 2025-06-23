extends Label

@export var color_speed : float = 0.5
var color_direction : float = 1


func _process(delta: float) -> void:
	if visible:
		lerp_modulate(delta)


func lerp_modulate(delta: float) -> void:
	var current_color : Color = modulate
	
	current_color.a = clamp(modulate.a + color_speed * color_direction * delta, 0.5, 1.0)
	
	if current_color.a <= 0.5 or current_color.a >= 1.0:
		color_direction *= -1
	
	modulate = current_color
