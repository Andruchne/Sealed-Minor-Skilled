extends Label

const first_level : String = "res://Scenes/Levels/SealedCave_0.tscn"

@export var speed : float = 0.5
var direction : float = 1

func _process(delta: float) -> void:
	if visible:
		lerp_modulate(delta)
		
		if Input.is_action_just_pressed("Interact"):
			MemoryManager.RESET()
			GameManager.CHANGE_SCENE(first_level, -1)
		elif Input.is_action_just_pressed("Esc"):
			get_tree().quit()

func lerp_modulate(delta: float) -> void:
	var current_color : Color = modulate
	
	current_color.a = clamp(modulate.a + speed * direction * delta, 0.5, 1)
	
	if current_color.a <= 0.5 or current_color.a >= 1:
		direction *= -1
	
	modulate = current_color
