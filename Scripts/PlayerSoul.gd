extends CharacterBody2D

@onready var anim_sprite : AnimatedSprite2D = $AnimatedSprite2D
var sprite_height : float

@export var speed : float = 80.0
@export var drawer : Node2D

var last_direction : Vector2

var is_alive : bool = true
var death_triggered : bool = false

func _ready() -> void:
	if !drawer:
		print("PlayerSoul: No valid brush_drawer given")
		queue_free()
	
	drawer.line_crossed.connect(on_line_crossed)
	sprite_height = anim_sprite.sprite_frames.get_frame_texture("Idle", 0).get_size().y / 3
	# Activate drawing
	drawer.set_draw(true, Vector2(position.x, position.y + sprite_height))


func _physics_process(_delta: float) -> void:
	if is_alive:
		handle_animation(move())
	elif !death_triggered:
		anim_sprite.play("Death")
		death_triggered = true
	move_and_slide()


func move() -> Vector2:
	# Get direction by reading Input
	var direction : Vector2
	direction.x = Input.get_axis("Left", "Right")
	direction.y = Input.get_axis("Up", "Down")
	direction = direction.normalized()
	
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
	if direction.x > 0:
		anim_sprite.play("Walk_Right")
	elif direction.x < 0:
		anim_sprite.play("Walk_Left")
	else:
		anim_sprite.play("Idle")


func on_line_crossed() -> void:
	death()


func death() -> void:
	velocity = Vector2.ZERO
	is_alive = false
