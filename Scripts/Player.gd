extends CharacterBody2D


@export var speed : float = 80.0

@export var blink_duration : float = 0.25
@export var blink_min_interval : float = 2
@export var blink_max_interval : float = 10

# For Animation handling
@onready var anim_body = $BodyAnimSprite
@onready var anim_eyes_lens = $LensAnimSprite
@onready var anim_eyes_lens_half = $LensHalfAnimSprite
@onready var anim_eyes_white = $WhiteAnimSprite
@onready var anim_eyes_white_half = $WhiteHalfAnimSprite
var eyes_hidden : bool = false

# For blinking animation
@onready var timer_blink_interval = $BlinkInterval
@onready var timer_blink_progression = $BlinkProgression
var blink_stage : int = 0

var animations : Array = []

var last_direction : Vector2 = Vector2.ZERO

func _ready() -> void:
	setup()


func _physics_process(_delta: float) -> void:
	handle_animation(move())
	physics_push()
	
	move_and_slide()

func setup() -> void:
	# Add animations to the array
	animations.append(anim_body)
	animations.append(anim_eyes_lens)
	animations.append(anim_eyes_lens_half)
	animations.append(anim_eyes_white)
	animations.append(anim_eyes_white_half)
	
	# Set timer intervals
	timer_blink_interval.wait_time = randf_range(blink_min_interval, blink_max_interval)
	# We divide by four, because we have to go through four blinking stages 
	timer_blink_progression.wait_time = blink_duration / 4
	# Start blinking timer
	timer_blink_interval.start()


func move() -> Vector2:
	# Get direction by reading Input
	var direction : Vector2
	direction.x = Input.get_axis("Left", "Right")
	direction.y = Input.get_axis("Up", "Down")
	direction = direction.normalized()
	
	# Move to direction
	if direction:
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	
	return direction


func physics_push() -> void:
	# To avoid applying force to same object multiple times
	var processed_collisions : Array = []
	
	for index in get_slide_collision_count():
		var collision = get_slide_collision(index)
		if collision.get_collider() is RigidBody2D && collision.get_collider() not in processed_collisions:
			collision.get_collider().apply_central_force(-collision.get_normal() * velocity.length())
			processed_collisions.append(collision.get_collider())


func handle_animation(direction : Vector2) -> void:
	# Mirror Sprite
	if direction.x > 0:
		flip_horizontal(false)
	elif direction.x < 0:
		flip_horizontal(true)
	
	# Play either Walk Animation
	if direction.length() > 0:
		if (direction.y > 0 && direction.x != 0) || (direction.x != 0 && direction.y == 0):
			play_animation("Walk_Bottom_Right")
			toggle_eyes_state(false)
			
		elif direction.y < 0 && direction.x != 0:
			play_animation("Walk_Top_Right")
			toggle_eyes_state(true)
		
		elif direction.y > 0:
			play_animation("Walk_Bottom")
			toggle_eyes_state(false)
			
		elif direction.y < 0:
			play_animation("Walk_Top")
			toggle_eyes_state(true)
			
		last_direction = direction;
		
	# Or Idle Animation
	else:	
		if (last_direction.y > 0 && last_direction.x != 0) || (last_direction.x != 0 && last_direction.y == 0):
			play_animation("Idle_Bottom_Right")
			toggle_eyes_state(false)
			
		elif last_direction.y < 0 && last_direction.x != 0:
			play_animation("Idle_Top_Right")
			toggle_eyes_state(true)
			
		elif last_direction.y > 0:
			play_animation("Idle_Bottom")
			toggle_eyes_state(false)
			
		elif last_direction.y < 0:
			play_animation("Idle_Top")
			toggle_eyes_state(true)


# Keep all Animations synced
func play_animation(anim_name : String) -> void:
	for anim in animations:
		anim.play(anim_name)


func flip_horizontal(flip : bool) -> void:
	for anim in animations:
		anim.flip_h = flip

# Blinking timer finished
func _on_blink_interval_timeout() -> void:
	# Start blinking and set a new random blink interval
	timer_blink_progression.start()
	timer_blink_interval.wait_time = randf_range(blink_min_interval, blink_max_interval)


func _on_blink_progression_timeout() -> void:
	blink_stage += 1
	
	# Hide and unhide the different progression stages of blinking
	match blink_stage:
		1:
			anim_eyes_lens.visible = false
			anim_eyes_white.visible = false
			anim_eyes_lens_half.visible = true
			anim_eyes_white_half.visible = true

		2:
			anim_eyes_lens_half.visible = false
			anim_eyes_white_half.visible = false

		3:
			anim_eyes_lens_half.visible = true
			anim_eyes_white_half.visible = true

		4:
			anim_eyes_lens_half.visible = false
			anim_eyes_white_half.visible = false
			anim_eyes_lens.visible = true
			anim_eyes_white.visible = true
			# Reset blinkin
			blink_stage = 0
			timer_blink_progression.stop()
			timer_blink_interval.start()


func toggle_eyes_state(hidden_state : bool) -> void:
	if hidden_state:
		if !eyes_hidden:
				hide_eyes()
				eyes_hidden = true
	else:
		if eyes_hidden:
				unhide_eyes()
				eyes_hidden = false


func hide_eyes() -> void:
	anim_eyes_lens.visible = false
	anim_eyes_white.visible = false
	anim_eyes_lens_half.visible = false
	anim_eyes_white_half.visible = false
	timer_blink_interval.stop()
	timer_blink_progression.stop()


func unhide_eyes() -> void:
	# Also reset the current frame to 0, to keep in sync
	# Even when invisible, animations will continue running
	# If we were to switch onto the same animation twice for the eyes, it would get out of sync with the body
	anim_eyes_lens.visible = true
	anim_eyes_lens.frame = 0
	anim_eyes_lens_half.frame = 0
	anim_eyes_white.visible = true
	anim_eyes_white.frame = 0
	anim_eyes_white_half.frame = 0
	
	blink_stage = 0
	timer_blink_interval.start()
