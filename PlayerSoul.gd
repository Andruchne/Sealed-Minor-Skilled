extends CharacterBody2D

@onready var anim_sprite : AnimatedSprite2D = $AnimatedSprite2D
var sprite_height : float

@export var speed : float = 80.0
@export var draw_holder : Node2D

func _ready() -> void:
	if !draw_holder:
		print("PlayerSoul: No valid brush_drawer given")
		queue_free()
	
	sprite_height = anim_sprite.sprite_frames.get_frame_texture("Idle", 0).get_size().y / 3
	# Activate drawing
	draw_holder.set_draw(true, Vector2(position.x, position.y + sprite_height))


func _physics_process(_delta: float) -> void:
	#paint()
	move()
	move_and_slide()


func move() -> Vector2:
	# Get direction by reading Input
	var direction : Vector2
	direction.x = Input.get_axis("Left", "Right")
	direction.y = Input.get_axis("Up", "Down")
	direction = direction.normalized()
	
	# Move to direction
	if direction:
		velocity = direction * speed
		draw_holder.move_draw(Vector2(position.x, position.y + sprite_height), direction)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	
	return direction


func paint() -> void:
	if Input.is_action_just_pressed("Interact"):
		draw_holder.set_draw(true, Vector2(position.x, position.y + sprite_height))
	elif Input.is_action_just_released("Interact"):
		draw_holder.set_draw(false, Vector2(position.x, position.y + sprite_height))
