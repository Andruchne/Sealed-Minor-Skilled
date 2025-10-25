extends CharacterBody2D

@onready var anim_sprite : AnimatedSprite2D = $AnimatedSprite2D
var sprite_height : float

@onready var speech_box : Control = $Control
@onready var speech_text : TextShower = $Control/NinePatchRect/DialogueText
@onready var box_patch_rect : NinePatchRect = $Control/NinePatchRect
var initial_box_texture : CompressedTexture2D
var initial_box_pos : Vector2
@export var bottom_box_pos : Vector2
@export var flipped_box : CompressedTexture2D

@export var speed : float = 80.0
@export var drawer : Node2D

@export var final_speech : bool

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

# For the talking intro
var is_talking : bool = false

# To know which conversation
var tutorial_talk_active : bool = false
var first_talk_index : int = 0

var second_talk_active : bool = false
var second_talk_index : int = 0

var green_talk_active : bool = false
var green_talk_index : int = 0

var ungreen_talk_active : bool = false
var ungreen_talk_index : int = 0

var ungreen_talk_same_active : bool = false
var ungreen_talk_same_index : int = 0
var checkpoint_touched

var path_crossed_active : bool = false
var path_crossed_index : int = 0

var finished_active : bool = false
var finished_index : int = 0

# Final Talk
var final_intro_active : bool = false
var final_intro_index : int = 0

var final_cobweb_active : bool = false
var final_cobweb_index : int = 0

var final_bye_active : bool = false
var final_bye_index : int = 0

var final : bool = false

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
	
	initial_box_texture = box_patch_rect.texture
	initial_box_pos = speech_box.position
	
	drawer.line_crossed.connect(on_line_crossed)
	speech_text.text_finished.connect(on_finished_show_text)
	sprite_height = anim_sprite.sprite_frames.get_frame_texture("Idle", 0).get_size().y / 3
	# Activate drawing
	drawer.set_draw(true, Vector2(position.x, position.y + sprite_height))
	anim_sprite.play("Spawn")
	# Connect to Checkpoint manager
	checkpoint_manager = get_tree().get_first_node_in_group("Checkpoint_Manager")
	if checkpoint_manager:
		checkpoint_manager.checkpoints_cleared.connect(on_checkpoints_complete)
	
	if checkpoint_manager && MemoryManager.memory.soul_intro_played:
		checkpoint_manager.set_first_checkpoint_activeness()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Interact") && is_talking && speech_text.is_finished:
		if tutorial_talk_active:
			talk_intro()
		elif path_crossed_active:
			talk_path_crossed()
		elif green_talk_active:
			talk_green_hit()
		elif ungreen_talk_active:
			talk_ungreen_hit()
		elif ungreen_talk_same_active:
			talk_ungreen_hit_same()
		elif finished_active:
			talk_finished()
		elif second_talk_active:
			talk_second_try()
		elif final_intro_active:
			talk_final_intro()
		elif final_cobweb_active:
			talk_final_cobweb()
		elif final_bye_active:
			talk_final_bye()
	elif Input.is_action_just_pressed("Interact") && is_talking && !speech_text.is_finished:
		speech_text.finish_current_dialogue()


func talk_intro() -> void:
	match first_talk_index:
		0:
			show_message(tr("soul_01_intro_first_talk"))
		1:
			show_message(tr("soul_02_intro_first_talk"))
		2: 
			show_message(tr("soul_03_intro_first_talk"))
		3:
			show_message(tr("soul_04_intro_first_talk"))
		4: 
			show_message(tr("soul_05_intro_first_talk"))
		5:
			show_message(tr("soul_06_intro_first_talk"))
			checkpoint_manager.set_first_checkpoint_activeness()
		6:
			show_message(tr("soul_07_intro_first_talk"))
		7:
			stop_messages()
			tutorial_talk_active = false
			MemoryManager.memory.soul_green_guide = true
		_:
			stop_messages()
			tutorial_talk_active = false
			MemoryManager.memory.soul_green_guide = true
		
	first_talk_index += 1


func talk_second_try() -> void:
	match second_talk_index:
		0:
			show_message(tr("soul_01_intro_second_try"))
		1:
			var color : String = get_primary_color()
			show_message(tr("soul_02_intro_second_try").format({"color" : tr("color_" + color)}))
			checkpoint_manager.set_first_checkpoint_activeness()
		2: 
			show_message(tr("soul_03_intro_second_try"))
		3:
			stop_messages()
			second_talk_active = false
		
	second_talk_index += 1


func talk_green_hit() -> void:
	match green_talk_index:
		0:
			show_message(tr("soul_01_intro_green_hit"))
		1:
			var color : String = get_primary_color()
			show_message(tr("soul_02_intro_green_hit").format({"color" : tr("color_" + color)}))
		2:
			show_message(tr("soul_03_intro_green_hit"))
		_:
			stop_messages()
			green_talk_active = false
	
	green_talk_index += 1


func talk_ungreen_hit() -> void:
	match ungreen_talk_index:
		0:
			show_message(tr("soul_01_intro_ungreen_hit"))
		1:
			stop_messages()
			ungreen_talk_active = false
		2: 
			show_message(tr("soul_02_intro_ungreen_hit"))
		3:
			show_message(tr("soul_03_intro_ungreen_hit"))
		4:
			checkpoint_manager.set_alt_color(true)
			show_message(tr("soul_04_intro_ungreen_hit"))
		5:
			stop_messages()
			ungreen_talk_active = false
		6:
			show_message(tr("soul_05_intro_ungreen_hit"))
		7:
			stop_messages()
			ungreen_talk_active = false
		_:
			stop_messages()
			ungreen_talk_active = false
	
	ungreen_talk_index += 1


func talk_ungreen_hit_same() -> void:
	match ungreen_talk_same_index:
		0:
			show_message(tr("soul_01_intro_ungreen_same"))
		1:
			stop_messages()
			ungreen_talk_same_active = false
		2:
			show_message(tr("soul_02_intro_ungreen_same"))
		3: 
			stop_messages()
			ungreen_talk_same_active = false
		2:
			show_message(tr("soul_03_intro_ungreen_same"))
		_:
			stop_messages()
			ungreen_talk_same_active = false
		
	ungreen_talk_same_index += 1


func talk_path_crossed() -> void:
	match path_crossed_index:
		0:
			show_message(tr("soul_01_intro_path_crossed"))
		1:
			show_message(tr("soul_02_intro_path_crossed"))
		2:
			show_message(tr("soul_03_intro_path_crossed"))
		3:
			show_message(tr("soul_04_intro_path_crossed"))
		_:
			MemoryManager.memory.soul_intro_second_try = true
			path_crossed_active = false
			stop_messages()
			death()
	
	path_crossed_index += 1


func talk_finished() -> void:
	match finished_index:
		0:
			show_message(tr("soul_01_intro_finish"))
		1:
			show_message(tr("soul_02_intro_finish"))
		2:
			show_message(tr("soul_03_intro_finish"))
		3:
			show_message(tr("soul_04_intro_finish"))
		4:
			finished_active = false
			stop_messages()
			is_won = true
		_:
			finished_active = false
			stop_messages()
			is_won = true
	
	finished_index += 1


func talk_final_intro() -> void:
	match final_intro_index:
		0:
			show_message(tr("soul_01_final_intro"))
		1:
			show_message(tr("soul_02_final_intro"))
		2:
			final_intro_active = false
			speech_box.visible = false
			trigger_dirr_reaction()
		_:
			final_intro_active = false
			speech_box.visible = false
			trigger_dirr_reaction()
	
	final_intro_index += 1


func talk_final_cobweb() -> void:
	match final_cobweb_index:
		0:
			show_message(tr("soul_01_final_cobweb"))
		1:
			show_message(tr("soul_02_final_cobweb"))
		2:
			show_message(tr("soul_03_final_cobweb"))
		3:
			final_cobweb_active = false
			final_bye_active = true
			talk_final_bye()
		_:
			final_cobweb_active = false
			final_bye_active = true
			talk_final_bye()
	
	final_cobweb_index += 1


func talk_final_bye() -> void:
	match final_bye_index:
		0:
			show_message(tr("soul_01_final_bye"))
		1:
			show_message(tr("soul_02_final_bye"))
		3:
			final_bye_active = false
			speech_box.visible = false
			final = true
			anim_sprite.play("Despawn")
		_:
			final_bye_active = false
			speech_box.visible = false
			final = true
			anim_sprite.play("Despawn")
	
	final_bye_index += 1


func trigger_dirr_reaction() -> void:
	var dirr_load = preload("res://Scenes/Characters/Dirr.tscn")
	var dirr : Dirr = dirr_load.instantiate()
	dirr.global_position = global_position + Vector2(260, 0)
	get_tree().current_scene.add_child(dirr)
	dirr.scale *= 2
	dirr.speed *= 2
	dirr.final_scene = true
	dirr.final_scene_finish.connect(final_dirr_finished)
	
	if !MemoryManager.memory.dirr_at_0:
		dirr.current_target_position = global_position + Vector2(100, 0)
	else:
		dirr.current_target_position = dirr.global_position + Vector2(dirr.min_distance_for_move + 1, 0)


func final_dirr_finished() -> void:
	if MemoryManager.memory.cobweb:
		final_cobweb_active = true
		talk_final_cobweb()
	else:
		final_bye_active = true
		talk_final_bye()


func show_message(show_text : String) -> void:
	velocity = Vector2.ZERO
	
	if !speech_box.visible:
		speech_box.visible = true
		is_talking = true
	
	anim_sprite.play("Talk")
	speech_text.show_dialogue(show_text)


func stop_messages() -> void:
	is_talking = false
	speech_box.visible = false


func _physics_process(_delta: float) -> void:
	if is_alive && !is_spawning && !is_talking:
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
	if MemoryManager.memory.soul_warned_trace:
		death()
	else:
		MemoryManager.memory.soul_warned_trace = true
		path_crossed_active = true
		talk_path_crossed()


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
		
		if MemoryManager.memory.soul_green_guide:
			if checkpoint.active && !MemoryManager.memory.soul_green_hit_once:
				talk_green_hit()
				green_talk_active = true
				MemoryManager.memory.soul_green_hit_once = true
			elif checkpoint.visible && !checkpoint.checked && !checkpoint.active && !MemoryManager.memory.alt_color:
				if checkpoint_touched == null:
					checkpoint_touched = checkpoint
					talk_ungreen_hit()
					ungreen_talk_active = true
				elif checkpoint_touched == checkpoint && ungreen_talk_index < 4:
					talk_ungreen_hit_same()
					ungreen_talk_same_active = true
				else:
					talk_ungreen_hit()
					ungreen_talk_active = true
		
		checkpoint.interacted()
	elif area.is_in_group("Soulcheck_Top"):
		set_box_orientation(true)


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("Soulcheck_Top"):
		set_box_orientation(false)


func _on_animated_sprite_2d_animation_looped() -> void:
	if is_checked:
		is_checked = false
		last_check_frame = 0
		last_frame_progress = 0
		last_animation = ""
		# Call it early, to fix short frame flicker
		handle_animation(current_direction)
	# Beginning spawn finished
	elif !is_won && is_spawning:
		if final_speech:
			is_spawning = false
			final_intro_active = true
			talk_final_intro()
		elif !MemoryManager.memory.soul_intro_played:
			is_spawning = false
			tutorial_talk_active = true
			MemoryManager.memory.soul_intro_played = true
			talk_intro()
		elif MemoryManager.memory.soul_intro_second_try:
			MemoryManager.memory.soul_intro_second_try = false
			is_spawning = false
			second_talk_active = true
			talk_second_try()
		else:
			is_spawning = false
		
	elif is_won && !is_checked:
		finished_won = true
		anim_sprite.play("Despawn")


func on_checkpoints_complete() -> void:
	if MemoryManager.memory.soul_green_guide:
		MemoryManager.memory.soul_green_guide = false
		green_talk_active = false
	
	if !MemoryManager.memory.soul_first_win:
		finished_active = true
		talk_finished()
	else:
		is_won = true


func on_finished_show_text() -> void:
	anim_sprite.play("Idle")


func _on_animated_sprite_2d_animation_finished() -> void:
	# After a single loop animation finishes, an end-condition is settled
	if is_won && !death_triggered:
		emit_signal("minigame_finished", true)
	elif final:
		var label : Label = get_tree().get_first_node_in_group("RestartLabel")
		label.visible = true
	else:
		emit_signal("minigame_finished", false)


func set_box_orientation(is_flipped : bool):
	if is_flipped:
		box_patch_rect.texture = flipped_box
		var bottom : int = box_patch_rect.patch_margin_bottom
		box_patch_rect.patch_margin_bottom = box_patch_rect.patch_margin_top
		box_patch_rect.patch_margin_top = bottom
		speech_box.position = bottom_box_pos
	else:
		box_patch_rect.texture = initial_box_texture
		var bottom : int = box_patch_rect.patch_margin_bottom
		box_patch_rect.patch_margin_bottom = box_patch_rect.patch_margin_top
		box_patch_rect.patch_margin_top = bottom
		speech_box.position = initial_box_pos
		


func get_primary_color() -> String:
	var color : String
	if MemoryManager.memory.alt_color:
		color = "blue"
	else:
		color = "green"
	return color
