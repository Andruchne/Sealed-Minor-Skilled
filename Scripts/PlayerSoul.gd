extends CharacterBody2D

@onready var anim_sprite : AnimatedSprite2D = $AnimatedSprite2D
var sprite_height : float

@export var speed : float = 80.0
@export var drawer : Node2D

var last_direction : Vector2
var current_direction : Vector2

var is_alive : bool = true
var death_triggered : bool = false

# For handling animation, when checkpoint reached
var last_check_frame : int = 0
var last_frame_progress : float = 0
var last_animation : String = ""
var is_checked : bool = false

# For the spawn/despawn animation
var is_spawning : bool = true

# For the win animation
var is_won : bool = false
var finished_won : bool = false
var checkpoint_manager

signal minigame_finished(has_won : bool)

func _ready() -> void:
	if !drawer:
		print("PlayerSoul: No valid brush_drawer given")
		queue_free()
		return
	
	drawer.line_crossed.connect(on_line_crossed)
	sprite_height = anim_sprite.sprite_frames.get_frame_texture("Idle", 0).get_size().y / 3
	# Activate drawing
	drawer.set_draw(true, Vector2(position.x, position.y + sprite_height))
	anim_sprite.play("Spawn")
	# Connect to Checkpoint manager
	checkpoint_manager = get_tree().get_first_node_in_group("Checkpoint_Manager")
	if checkpoint_manager:
		checkpoint_manager.checkpoints_cleared.connect(on_checkpoints_complete)


func _physics_process(_delta: float) -> void:
	if is_alive && !is_spawning:
		handle_animation(move())
	elif !is_alive && !death_triggered:
		anim_sprite.play("Death")
		death_triggered = true
	move_and_slide()


func move() -> Vector2:
	# Get direction by reading Input
	var direction : Vector2
	direction.x = Input.get_axis("Left", "Right")
	direction.y = Input.get_axis("Up", "Down")
	direction = direction.normalized()
	current_direction = direction
	
	if direction == last_direction:
		direction = Vector2.ZERO
	
	# Move to direction
	if direction:
		velocity = direction * speed
		drawer.move_draw(Vector2(position.x, position.y + sprite_height), direction)
		last_direction = direction * -1
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	
	return direction


func paint() -> void:
	if Input.is_action_just_pressed("Interact"):
		drawer.set_draw(true, Vector2(position.x, position.y + sprite_height))
	elif Input.is_action_just_released("Interact"):
		drawer.set_draw(false, Vector2(position.x, position.y + sprite_height))


func handle_animation(direction : Vector2) -> void:
	if is_spawning:
		return
	
	if !is_checked && !is_won:
		if direction.x > 0:
			anim_sprite.play("Walk_Right")
		elif direction.x < 0:
			anim_sprite.play("Walk_Left")
		else:
			anim_sprite.play("Idle")
	# For checked animation
	elif is_checked:
		if direction.x > 0:
			player_check_animation("Check_Walk_Right")
		elif direction.x < 0:
			player_check_animation("Check_Walk_Left")
		else:
			player_check_animation("Check_Idle")
		
		# Save last frame & animation progress
		last_check_frame = anim_sprite.frame
		last_frame_progress = anim_sprite.frame_progress
	elif !finished_won && is_won && !is_checked:
		anim_sprite.play("Win")
		is_spawning = true
		velocity = Vector2.ZERO
	


func player_check_animation(animation : String) -> void:
	if last_animation == animation:
		return
	
	anim_sprite.play(animation)
	anim_sprite.frame = last_check_frame
	anim_sprite.frame_progress = last_frame_progress
	last_animation = animation


func on_line_crossed() -> void:
	death()


func death() -> void:
	velocity = Vector2.ZERO
	is_alive = false
	is_checked = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Soulcheck") && is_alive:
		var checkpoint = area.get_parent()
		if checkpoint.active:
			is_checked = true
			anim_sprite.frame = 0
			anim_sprite.frame_progress = 0
			# Not the prettiest way, but due to execution order, the proper way of managing states
			checkpoint.set_active(false)


func _on_animated_sprite_2d_animation_looped() -> void:
	if is_checked:
		is_checked = false
		last_check_frame = 0
		last_frame_progress = 0
		last_animation = ""
		# Call it early, to fix short frame flicker
		handle_animation(current_direction)
	elif !is_won && is_spawning:
		is_spawning = false
		handle_animation(current_direction)
	elif is_won && !is_checked:
		finished_won = true
		anim_sprite.play("Despawn")


func on_checkpoints_complete() -> void:
	is_won = true


func _on_animated_sprite_2d_animation_finished() -> void:
	# After a single loop animation finishes, an end-condition is settled
	if is_won && !death_triggered:
		emit_signal("minigame_finished", true)
	else:
		emit_signal("minigame_finished", false)
