extends CharacterBody2D

@export var dialogue_actions : Dictionary[String, String]

@export var play_intro_cutscene : bool
var intro_finished : bool

@onready var dirr_dialogues : DialogueHolder = $DialogueHolder
@onready var char_anim : AnimatedSprite2D = $AnimatedSprite2D

@onready var static_collider = $Collider

# To keep track of interactions
var current_stage : int
var state_move_through_gate : bool 
var state_follow_player : bool
var state_move_back : bool

# Positions to move to
@export var front : Node2D
@export var behind : Node2D
@export var out : Node2D
@export var back_out : Node2D

var current_target_position : Vector2
var speed : float = 60
var distance_before_stop : float = 1

# Animation handling
var last_direction : Vector2
var last_anim : String = ""
var is_mirrored : bool = false

var player : Node2D

var min_distance_for_move : float = 10
var reached_target : bool


func _ready() -> void:
	await get_tree().process_frame
	intro_cutscene()
	setup()


func setup() -> void:
	# Fix animation when loading
	last_anim = "" 


func _physics_process(_delta: float) -> void:
	update_player_target()
	velocity = move()
	if state_follow_player:
		handle_animation(velocity)
	move_and_slide()


func intro_cutscene() -> void:
	if !intro_finished && play_intro_cutscene:
		GameManager.MAIN_ACTIVE = false
		await get_tree().create_timer(1.0).timeout
		char_anim.play("Surprised")


func move() -> Vector2:
	var new_velocity : Vector2 = Vector2.ZERO
	
	if reached_target && global_position.distance_to(current_target_position) - distance_before_stop > min_distance_for_move:
		reached_target = false
	elif reached_target:
		return Vector2.ZERO
	
	if current_target_position && global_position.distance_to(current_target_position) > distance_before_stop:
		var direction = (current_target_position - global_position).normalized()
		new_velocity = direction * speed
	else:
		reached_target = true
		target_reached()
	
	return new_velocity


func handle_animation(direction : Vector2) -> void:
	# Mirror Sprite
	if direction.x > 0:
		flip_horizontal(false)
	elif direction.x < 0:
		flip_horizontal(true)
	
	# Play either Walk Animation
	if direction.length() > 0:
		if direction.y > 0 && Useful.APPROX(direction.x, 0, 8):
			play_animation("Walk_Bottom")
			
		elif direction.y < 0 && Useful.APPROX(direction.x, 0, 8):
			play_animation("Walk_Top")
		
		elif (direction.y > -8 && direction.x != 0) || (direction.x != 0 && direction.y == 0):
			play_animation("Walk_Bottom_Right")
			
		elif direction.y < 0 && direction.x != 0:
			play_animation("Walk_Top_Right")
			
		last_direction = direction;
		
	# Or Idle Animation
	else:	
		if last_direction.y > 0 && Useful.APPROX(last_direction.x, 0, 8):
			play_animation("Idle_Bottom")
			
		elif last_direction.y < 0 && Useful.APPROX(last_direction.x, 0, 8):
			play_animation("Idle_Top")
		
		elif (last_direction.y > -8 && last_direction.x != 0) || (last_direction.x != 0 && last_direction.y == 0):
			play_animation("Idle_Bottom_Right")
			
		elif last_direction.y < 0 && last_direction.x != 0:
			play_animation("Idle_Top_Right")


func play_animation(anim_name : String) -> void:
	if (anim_name != last_anim):
		char_anim.play(anim_name)
		char_anim.frame = 0
	
	last_anim = anim_name


func flip_horizontal(flip : bool) -> void:
	char_anim.flip_h = flip
	is_mirrored = flip


func update_player_target() -> void:
	if player != null && follow_player:
		current_target_position = Vector2(player.global_position.x, player.global_position.y - 10)


func on_interact(_player : Node2D) -> void:
	pass


func start_dialogue(dialogue : String) -> void:
	DialogueManager.character_talk.connect(on_start_talk)
	DialogueManager.character_stop_talk.connect(on_stop_talk)
	DialogueManager.dialogue_finished.connect(on_dialogue_finished)
	DialogueManager.POPUP_DIALOGUE(dirr_dialogues.get_dialogue(dialogue))


func on_start_talk() -> void:
	var current_frame : int = char_anim.frame
	char_anim.play("Talk_Bottom")
	char_anim.frame = current_frame


func on_stop_talk() -> void:
	var current_frame : int = char_anim.frame
	
	# Manual animation fix
	if current_frame == 3:
		current_frame = 4
		
	char_anim.play("Idle_Bottom")
	char_anim.frame = current_frame


func on_dialogue_finished(finish_id : String) -> void:
	DialogueManager.character_talk.disconnect(on_start_talk)
	DialogueManager.character_stop_talk.disconnect(on_stop_talk)
	DialogueManager.dialogue_finished.disconnect(on_dialogue_finished)
	do_action_after_dialogue(finish_id)


func do_action_after_dialogue(finish_id : String) -> void:
	if dialogue_actions.has(finish_id):
		var func_name = dialogue_actions[finish_id]
		if has_method(func_name):
			call(func_name)


func dialogue_01_you_ugly() -> void:
	state_move_through_gate = true


func dialogue_01_point_important() -> void:
	state_move_through_gate = true


func dialogue_01_snack_creature() -> void:
	state_move_through_gate = true


func dialogue_01_snack_given() -> void:
	state_move_through_gate = true


func dialogue_01_nothing_look() -> void:
	state_move_back = true


func dialogue_01_look_again() -> void:
	follow_player()


func follow_player() -> void:
	player = get_tree().get_first_node_in_group("Player")
	distance_before_stop = 20
	static_collider.disabled = true
	state_follow_player = true


func move_through_gate() -> void:
	match current_stage:
		0:
			char_anim.play("Walk_Top")
			current_target_position = front.global_position
			speed = 80
		1:
			char_anim.play("Roll_Top")
			static_collider.disabled = true
			current_target_position = behind.global_position
		2:
			char_anim.play("Walk_Top")
			current_target_position = out.global_position
		3:
			queue_free()
	current_stage += 1


func move_back() -> void:
	match current_stage:
		0:
			char_anim.play("Walk_Bottom")
			static_collider.disabled = true
			current_target_position = back_out.global_position
			speed = 80
		1:
			queue_free()
	current_stage += 1


func target_reached() -> void:
	if state_move_through_gate:
		move_through_gate()
	elif state_move_back:
		move_back()
		


func get_save_state() -> Dictionary:
	var dict : Dictionary = {
		"intro_finished" : intro_finished,
		"reached_target" : reached_target,
		"current_stage" : current_stage,
		"state_move_through_gate" : state_move_through_gate,
		"state_follow_player" : state_follow_player,
		"state_move_back" : state_move_back
	}
	var anim_state : Dictionary = Useful.GET_ANIMATION_STATES(char_anim)
	
	for key in anim_state:
		dict[key] = anim_state[key]
	
	return dict


func apply_save_state(state : Dictionary) -> void:
	intro_finished = state.get("intro_finished")
	reached_target = state.get("reached_target")
	current_stage = state.get("current_stage")
	state_move_through_gate = state.get("state_move_through_gate")
	state_follow_player = state.get("state_follow_player")
	state_move_back = state.get("state_move_back")
	
	await get_tree().process_frame
	if state_follow_player:
		follow_player()
	
	Useful.APPLY_ANIMATION_STATES(char_anim, state)


func _on_animated_sprite_2d_animation_finished() -> void:
	check_intro_finished()


func check_intro_finished() -> void:
	if play_intro_cutscene && !intro_finished:
		char_anim.play("Idle_Bottom")
		start_dialogue("beginning_dialogue")
		intro_finished = true
