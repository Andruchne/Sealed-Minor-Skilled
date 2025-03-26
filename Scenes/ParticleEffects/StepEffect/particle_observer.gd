extends CPUParticles2D


func _process(_delta: float) -> void:
	check_emission()


func check_emission() -> void:
	if !emitting:
		queue_free()
