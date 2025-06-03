extends CharacterBody2D

@export var speed : float = 80.0

@export var blink_duration : float = 0.25
@export var blink_min_interval : float = 2
@export var blink_max_interval : float = 10

# For Animation handling
@onready var anim_body : AnimatedSprite2D = $BodyAnimSprite
@onready var anim_shirt : AnimatedSprite2D = $ShirtAnimSprite
@onready var anim_pants : AnimatedSprite2D = $PantsAnimSprite

@onready var anim_eyes_lens : AnimatedSprite2D = $LensAnimSprite
@onready var anim_eyes_lens_half : AnimatedSprite2D = $LensHalfAnimSprite
@onready var anim_eyes_white : AnimatedSprite2D = $WhiteAnimSprite
@onready var anim_eyes_white_half : AnimatedSprite2D = $WhiteHalfAnimSprite

var eyes_hidden : bool = false
var last_anim : String = ""
var is_mirrored : bool = false

@onready var interact_area : Area2D = $InteractArea

# For blinking animation
@onready var timer_blink_interval : Timer = $BlinkInterval
@onready var timer_blink_progression : Timer = $BlinkProgression
var blink_stage : int = 0

var animations : Array = []

var last_direction : Vector2 = Vector2.ZERO
var current_direction : Vector2 = Vector2.ZERO

# For step effect
@onready var step_handler = $StepHandler
var last_anim_frame : int = 0
# False == Start Left Foot || True == Start Right Foot
var foot_dictionary = {
	"Walk_Bottom" : true,
	"Walk_Bottom_Right" : true,
	"Walk_Top" : true,
	"Walk_Top_Right" : false
}

# To check terrain type
var tilemap : TileMapLayer

# To transition screen
@onready var transitioner : Control = $Camera2D/Transitioner
var execute_after_trans : Callable

@onready var camera : Camera2D = $Camera2D

var interactable_list : Array = []

var sit_up : bool

func _ready() -> void:
	await get_tree().process_frame
	setup()


func _process(_delta: float) -> void:
	check_step()
	interact()


func _physics_process(_delta: float) -> void:
	if !GameManager.MAIN_ACTIVE:
		handle_animation(Vector2.ZERO)
		return
	
	handle_animation(move())
	physics_push()
	
	move_and_slide()


func first_level_action() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if get_tree().current_scene.name == "SealedCave_0" && !sit_up:
		if !anim_body.animation_finished.is_connected(_on_body_anim_sprite_animation_finished):
			anim_body.animation_finished.connect(_on_body_anim_sprite_animation_finished)
		GameManager.MAIN_ACTIVE = false
		play_animation("Sit_Up")
		sit_up = true


func setup() -> void:
	tilemap = get_tree().get_first_node_in_group("Ground")
	
	# To fix animation bug, when loading level
	last_anim = ""
	
	# Add animations to the array
	animations.append(anim_body)
	animations.append(anim_pants)
	animations.append(anim_shirt)
	animations.append(anim_eyes_lens)
	animations.append(anim_eyes_lens_half)
	animations.append(anim_eyes_white)
	animations.append(anim_eyes_white_half)
	
	# Set timer intervals
	timer_blink_interval.wait_time = randf_range(blink_min_interval, blink_max_interval)
	# We divide by four, because we have to go through four blinking stages 
	timer_blink_progression.wait_time = blink_duration / 4
	
	first_level_action()
	# Start blinking timer
	if anim_body.animation != "Sit" && anim_body.animation != "Sit_Up":
		timer_blink_interval.start()
	
	# Start with covered screen
	transition_in()
	
	if !transitioner.transition_finished.is_connected(on_transition_finished):
		transitioner.transition_finished.connect(on_transition_finished)
	
	if !GameManager.minigame_finished.is_connected(on_minigame_finished):
		GameManager.minigame_finished.connect(on_minigame_finished)
	
	if !interact_area.area_entered.is_connected(_on_interact_area_entered):
		interact_area.area_entered.connect(_on_interact_area_entered)
	
	if !interact_area.area_exited.is_connected(_on_interact_area_area_exited):
		interact_area.area_exited.connect(_on_interact_area_area_exited)
	
	if !timer_blink_interval.timeout.is_connected(_on_blink_interval_timeout):
		timer_blink_interval.timeout.connect(_on_blink_interval_timeout)
	
	if !timer_blink_progression.timeout.is_connected(_on_blink_progression_timeout):
		timer_blink_progression.timeout.connect(_on_blink_progression_timeout)


func move() -> Vector2:
	# Get direction by reading Input
	var direction : Vector2
	direction.x = Input.get_axis("Left", "Right")
	direction.y = Input.get_axis("Up", "Down")
	direction = direction.normalized()
	current_direction = direction
	
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



#
# Animation Handling
#

func handle_animation(direction : Vector2) -> void:
	if anim_body.animation == "Sit_Up" || anim_body.animation == "Sit":
		return
	
	# Mirror Sprite
	if direction.x > 0:
		flip_horizontal(false)
		is_mirrored = false
	elif direction.x < 0:
		flip_horizontal(true)
		is_mirrored = true
	
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
	if (anim_name != last_anim):
		for anim : AnimatedSprite2D in animations:
			if anim.sprite_frames.has_animation(anim_name):
				anim.play(anim_name)
				anim.frame = 0
	
	last_anim = anim_name


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
	anim_eyes_lens.visible = true
	anim_eyes_white.visible = true
	
	blink_stage = 0
	timer_blink_interval.start()



# Step checking
func get_current_tile_type(foot_index : int) -> String:
	if tilemap == null:
		return ""
	
	var tile_under : Vector2i = tilemap.local_to_map(step_handler.get_foot_pos(foot_index))
	var tile_data = tilemap.get_cell_tile_data(tile_under)
	
	if (tile_data):
		var terrain_index = tile_data.terrain
		var terrain_name = tilemap.tile_set.get_terrain_name(0, terrain_index)
		return terrain_name
	
	return ""


func check_step() -> void:
	var current_frame : int = anim_body.frame
	
	if current_frame != last_anim_frame && foot_dictionary.has(last_anim):
		last_anim_frame = current_frame
		var orientation : bool = foot_dictionary[last_anim]
		
		if orientation:
			match current_frame:
				1:
					if (is_mirrored):
						invoke_step(0)
					else:
						invoke_step(1)
				4:
					if (is_mirrored):
						invoke_step(1)
					else:
						invoke_step(0)
		else:
			match current_frame:
				1:
					if (is_mirrored):
						invoke_step(1)
					else:
						invoke_step(0)
				4:
					if (is_mirrored):
						invoke_step(0)
					else:
						invoke_step(1)


func invoke_step(foot_index : int) -> void:
	step_handler.play_step(foot_index, get_current_tile_type(foot_index))


func _on_interact_area_entered(area: Area2D) -> void:
	if area.is_in_group("Interactable"):
		interactable_list.append(area.get_parent())


func _on_interact_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("Interactable"):
		var index : int = interactable_list.find(area.get_parent())
		interactable_list.remove_at(index)


func is_looking_towards_target(target_position : Vector2) -> bool:
	var to_target: Vector2 = (target_position - global_position).normalized()
	var dot_product: float = last_direction.dot(to_target)
	var threshold: float = 0.001
	print(dot_product)
	return dot_product > threshold


func is_less_distant(target_position : Vector2, compare_to : Vector2) -> bool:
	if (target_position - global_position).length() < (compare_to - global_position).length():
		return true
	return false


func interact() -> void:
	if GameManager.MAIN_ACTIVE && Input.is_action_just_pressed("Interact"):
		# Check if any interactable is valid
		var valid_inter : Array = []
		for interactable in interactable_list:
			print(is_looking_towards_target(interactable.global_position))
			if is_looking_towards_target(interactable.global_position):
				valid_inter.append(interactable)
		if valid_inter.size() > 0:
			var interacted = false
			for val in valid_inter:
				if !interacted || is_less_distant(val.global_position, interacted.global_position):
					interacted = val
			
			interacted.on_interact(self)


func begin_minigame(type : String) -> void:
	match type:
		"Soulcheck":
			transitioner.transition_out()
			execute_after_trans = GameManager.TRIGGER_SOULCHECK




func on_minigame_finished(_has_won : bool) -> void:
	transition_in()


func transition_in() -> void:
	transitioner.cover_screen()
	transitioner.transition_in()


func on_transition_finished() -> void:
	if execute_after_trans.is_valid():
		execute_after_trans.call()
		execute_after_trans = Callable()


func get_save_state() -> Dictionary:
	return {
		"current_direction" : current_direction,
		"last_direction" : last_direction,
		"last_anim_frame" : last_anim_frame,
		"is_mirrored" : is_mirrored,
		"eyes_hidden" : eyes_hidden,
		"sit_up" : sit_up,
	}


func apply_save_state(state : Dictionary) -> void:
	current_direction = state.get("current_direction")
	last_direction = state.get("last_direction")
	last_anim_frame = state.get("last_anim_frame")
	is_mirrored = state.get("is_mirrored")
	sit_up = state.get("sit_up")
	
	await get_tree().process_frame
	toggle_eyes_state(state.get("eyes_hidden"))
	handle_animation(last_direction)


func after_load_init() -> void:
	camera.make_current()
	await get_tree().process_frame
	tilemap = get_tree().get_first_node_in_group("Ground")
	


func get_player_info() -> PlayerInfo:
	var info = PlayerInfo.new()
	info.body_color = anim_body.modulate
	info.lens_color = anim_eyes_lens.modulate
	info.shirt_color = anim_shirt.modulate
	info.pants_color = anim_pants.modulate
	return info


func _on_body_anim_sprite_animation_finished() -> void:
	if anim_body.animation == "Sit_Up":
		play_animation("Idle_Bottom_Right")
		handle_animation(Vector2(0, 1))
		GameManager.MAIN_ACTIVE = true
