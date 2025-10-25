extends Activator

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if !anim.animation_finished.is_connected(_on_animation_finished):
		anim.animation_finished.connect(_on_animation_finished)


func on_interact(_player : Node2D) -> void:
	# Taking 4, as animation is 4 frames long
	var current_frame = 0
	if anim.animation != "Closed":
		current_frame = 4 - anim.frame
	
	if active:
		anim.play("Close")
	else:
		anim.play("Open")
	anim.frame = current_frame
	active = !active


func get_save_state() -> Dictionary:
	var dict : Dictionary = super.get_save_state()
	var lever_state : Dictionary = Useful.GET_ANIMATION_STATES(anim)
	
	for key in lever_state:
		dict[key] = lever_state[key]
	
	return dict


func apply_save_state(state : Dictionary) -> void:
	super.apply_save_state(state)
	
	Useful.APPLY_ANIMATION_STATES(anim, state)


func _on_animation_finished() -> void:
	if anim.animation == "Close" && was_activated:
		emit_deactivated()
		was_activated = false
	elif anim.animation == "Open" && !was_activated:
		emit_activated()
		was_activated = true


func after_load_init() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if was_activated:
		emit_activated()
