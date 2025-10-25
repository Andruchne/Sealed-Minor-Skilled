class_name Dirr
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
var state_move_through_gate_2 : bool 

# Positions to move to
var front_pos : Vector2 = Vector2(745, 844)
var behind_pos : Vector2 = Vector2(745.0, 807.0)
var out_pos : Vector2 = Vector2(737.0, 771.0)
var back_pos : Vector2 = Vector2(736.0, 1044.0)

# Positions to move to second
var front_pos_0 : Vector2 = Vector2(745.0, 865.0)
var behind_pos_0 : Vector2 = Vector2(745.0, 830.0)
var front_pos_1 : Vector2 = Vector2(745.0, 651.0)
var behind_pos_1 : Vector2 = Vector2(745.0, 622.0)
var out_pos_0 : Vector2 = Vector2(737.0, 558.0)

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

var collect_treasure : bool

var leave : bool
var final_scene : bool
var final_scene_finished : bool
signal final_scene_finish()

var ignore_anim : bool


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
		if !state_follow_player:
			handle_animation(direction)
	else:
		reached_target = true
		if !state_follow_player:
			handle_animation(Vector2.ZERO)
		target_reached()
	
	return new_velocity


func handle_animation(direction : Vector2) -> void:
	if (ignore_anim):
		return
	
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
		if (last_direction.y > 0 && Useful.APPROX(last_direction.x, 0, 8)) || last_direction.length() == 0:
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
	if !DialogueManager.character_talk.is_connected(on_start_talk):
		DialogueManager.character_talk.connect(on_start_talk)
	if !DialogueManager.character_stop_talk.is_connected(on_stop_talk):
		DialogueManager.character_stop_talk.connect(on_stop_talk)
	if !DialogueManager.dialogue_finished.is_connected(on_dialogue_finished):
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
	
	MemoryManager.memory.dirr_offended = true
	
	MemoryManager.memory.dirr_go_home = true
	MemoryManager.memory.dirr_at_1 = false
	MemoryManager.memory.dirr_at_0 = false
	MemoryManager.memory.dirr_at_2 = true


func dialogue_01_point_important() -> void:
	state_move_through_gate = true
	
	MemoryManager.memory.dirr_go_home = true
	MemoryManager.memory.dirr_at_1 = false
	MemoryManager.memory.dirr_at_0 = false
	MemoryManager.memory.dirr_at_2 = true


func dialogue_01_snack_creature() -> void:
	state_move_through_gate = true
	MemoryManager.memory.knows_cobweb = true
	MemoryManager.update_general_memory()
	
	MemoryManager.memory.dirr_go_home = true
	MemoryManager.memory.dirr_at_1 = false
	MemoryManager.memory.dirr_at_0 = false
	MemoryManager.memory.dirr_at_2 = true


func dialogue_01_snack_given() -> void:
	state_move_through_gate = true
	MemoryManager.memory.knows_cobweb = true
	MemoryManager.update_general_memory()
	
	MemoryManager.memory.dirr_collected_cobweb = true
	MemoryManager.memory.cobweb = false
	
	MemoryManager.memory.dirr_go_home = true
	MemoryManager.memory.dirr_at_1 = false
	MemoryManager.memory.dirr_at_0 = false
	MemoryManager.memory.dirr_at_2 = true


func dialogue_01_nothing_look() -> void:
	state_move_back = true
	MemoryManager.memory.dirr_nothing = true
	
	MemoryManager.memory.dirr_at_1 = false
	MemoryManager.memory.dirr_at_0 = true


func dialogue_01_look_again() -> void:
	follow_player()
	MemoryManager.memory.dirr_follow_player = true
	MemoryManager.memory.dirr_look_back = true
	
	MemoryManager.memory.dirr_at_1 = false
	MemoryManager.memory.dirr_at_0 = true


func dialogue_01_window_rush() -> void:
	MemoryManager.memory.window_race = true
	current_target_position = global_position + Vector2(0, -200)
	leave = true;
	
	MemoryManager.memory.dirr_at_1 = true
	MemoryManager.memory.dirr_at_0 = false
	
	MemoryManager.memory.dirr_follow_player = false


func dialogue_01_found_cobweb() -> void:
	await get_tree().process_frame
	GameManager.MAIN_ACTIVE = false
	current_target_position = global_position + Vector2(25, 25);
	collect_treasure = true


func dialogue_01_found_cobweb_2() -> void:
	current_target_position = global_position + Vector2(-25, -25)
	MemoryManager.memory.dirr_go_home = true
	
	MemoryManager.memory.dirr_at_1 = true
	MemoryManager.memory.dirr_at_0 = false
	
	MemoryManager.memory.dirr_follow_player = false


func dialogue_final_bye() -> void:
	start_dialogue("final_bye")


func dialogue_final_bye_finished() -> void:
	final_scene = false
	final_scene_finished = true
	if !MemoryManager.memory.dirr_at_0:
		current_target_position = global_position + Vector2(150, 0)
	else:
		current_target_position = global_position + Vector2(30, 0)


func dialogue_final_followed() -> void:
	emit_signal("final_scene_finish")


func follow_player() -> void:
	player = get_tree().get_first_node_in_group("Player")
	distance_before_stop = 20
	static_collider.disabled = true
	state_follow_player = true


func move_through_gate() -> void:
	match current_stage:
		0:
			ignore_anim = true
			static_collider.disabled = true
			char_anim.play("Walk_Top")
			current_target_position = front_pos
			MemoryManager.memory.dirr_at_1 = false
			MemoryManager.memory.dirr_at_2 = true
		1:
			if !MemoryManager.memory.sc0_gate_open:
				char_anim.play("Roll_Top")
			current_target_position = behind_pos
		2:
			char_anim.play("Walk_Top")
			current_target_position = out_pos
		3:
			queue_free()
	current_stage += 1


func move_through_gate_2() -> void:
	match current_stage:
		0:
			ignore_anim = true
			static_collider.disabled = true
			char_anim.play("Walk_Top")
			current_target_position = front_pos_0
		1:
			if !MemoryManager.memory.sc2_gate_open_0:
				char_anim.play("Roll_Top")
			current_target_position = behind_pos_0
		2:
			char_anim.play("Walk_Top")
			current_target_position = front_pos_1
		3:
			if !MemoryManager.memory.sc2_gate_open_1:
				char_anim.play("Roll_Top")
			current_target_position = behind_pos_1
		4:
			char_anim.play("Walk_Top")
			current_target_position = out_pos_0
		5:
			MemoryManager.memory.dirr_at_2 = false
			MemoryManager.memory.dirr_first_arrived = true
			queue_free()
	current_stage += 1


func move_back() -> void:
	match current_stage:
		0:
			char_anim.play("Walk_Bottom")
			static_collider.disabled = true
			current_target_position = back_pos
		1:
			queue_free()
	current_stage += 1


func target_reached() -> void:
	if state_move_through_gate:
		move_through_gate()
	elif state_move_through_gate_2:
		move_through_gate_2()
	
	elif final_scene:
		final_interactions()
	elif final_scene_finished:
		emit_signal("final_scene_finish")
	
	# For moving in Scene 1
	elif collect_treasure && !MemoryManager.memory.dirr_collected_cobweb:
		var cobweb_stone : CobwebStone = get_tree().get_first_node_in_group("Cobweb")
		cobweb_stone.clear_stone()
		start_dialogue("found_cobweb_dialogue_2")
		MemoryManager.memory.dirr_collected_cobweb = true
	elif collect_treasure && MemoryManager.memory.dirr_collected_cobweb:
		current_target_position = global_position + Vector2(0, -200)
		collect_treasure = false
		leave = true
	elif state_move_back:
		move_back()
	elif leave:
		queue_free()


func final_interactions() -> void:
	if MemoryManager.memory.window_race:
		if MemoryManager.memory.dirr_first_arrived:
			start_dialogue("final_window_race_lose")
		else:
			start_dialogue("final_window_race_win")
	elif MemoryManager.memory.dirr_collected_cobweb:
		start_dialogue("final_snack")
	elif MemoryManager.memory.dirr_offended:
		start_dialogue("final_offend")
	elif MemoryManager.memory.dirr_follow_player:
		start_dialogue("final_followed")
	elif MemoryManager.memory.dirr_at_0:
		start_dialogue("final_waiting")
	else:
		start_dialogue("final_important")


func get_save_state() -> Dictionary:
	var dict : Dictionary = {
		"intro_finished" : intro_finished,
		"reached_target" : reached_target,
		"current_stage" : current_stage,
		"current_target_position" : current_target_position,
		"last_direction" : last_direction,
		"state_move_through_gate" : state_move_through_gate,
		"state_follow_player" : state_follow_player,
		"state_move_back" : state_move_back,
		"state_move_through_gate_2" : state_move_through_gate_2,
		
		"collect_treasure" : collect_treasure,
		"leave" : leave
	}
	var anim_state : Dictionary = Useful.GET_ANIMATION_STATES(char_anim)
	
	for key in anim_state:
		dict[key] = anim_state[key]
	
	return dict


func apply_save_state(state : Dictionary) -> void:
	intro_finished = state.get("intro_finished")
	reached_target = state.get("reached_target")
	current_stage = state.get("current_stage")
	current_target_position = state.get("current_target_position")
	last_direction = state.get("last_direction")
	state_move_through_gate = state.get("state_move_through_gate")
	state_follow_player = state.get("state_follow_player")
	state_move_back = state.get("state_move_back")
	state_move_through_gate_2 = state.get("state_move_through_gate_2")
	
	collect_treasure = state.get("collect_treasure")
	leave = state.get("leave")
	
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
