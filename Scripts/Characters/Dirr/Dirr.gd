extends CharacterBody2D

@export var dialogue_actions : Dictionary[String, String]

@onready var dirr_dialogues : DialogueHolder = $DialogueHolder
@onready var char_anim : AnimatedSprite2D = $AnimatedSprite2D

@onready var temp_platform : Node2D = $"../Platform"

var temp_intro : bool
var temp_reaction : bool

var current_target_position : Vector2
var speed : float = 30


func _ready() -> void:
	if temp_platform:
		temp_platform.activated.connect(platform_activated)


func _physics_process(delta: float) -> void:
	velocity = move()
	move_and_slide()


func move() -> Vector2:
	var set_velocity : Vector2 = Vector2.ZERO
	
	if current_target_position && global_position.distance_to(current_target_position) > 5:
		var direction = (current_target_position - global_position).normalized()
		set_velocity = direction * speed
	
	return set_velocity

func on_interact(_player : Node2D) -> void:
	if !temp_intro:
		start_dialogue("beginning_dialogue")
		temp_intro = true


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
	current_target_position = global_position + Vector2(0, -40)
	char_anim.play("Idle_Top")


func platform_activated() -> void:
	if !temp_reaction:
		start_dialogue("don't_touch")
		temp_reaction = true
