extends Panel

var eyes_dict = {
	DialogueManager.Mood.NORMAL : Vector2(0, 0),
	DialogueManager.Mood.GLAD : Vector2(0, 64),
	DialogueManager.Mood.SUS : Vector2(0, 128),
	DialogueManager.Mood.ANGRY : Vector2(128, 128)
}

var mouth_dict = {
	DialogueManager.Mood.NORMAL : Vector2(128, 0),
	DialogueManager.Mood.GLAD : Vector2(128, 64)
}

@export var portrait_texture : CompressedTexture2D

@onready var eyes : NinePatchRect = $Eyes
@onready var mouth : NinePatchRect = $Mouth
@onready var head : NinePatchRect = $Head

var portrait_parts : Array = []

# Texture specifics - We're assuming it will stay consistent
var portrait_size : int = 64
var max_anim_frames : int = 3

@onready var anim_timer : Timer = $AnimTimer

var current_mouth_origin : Vector2
var is_talking : bool = false
var current_anim_stage : int = 0

func _ready() -> void:
	setup()


func setup() -> void:
	portrait_parts.append(eyes)
	portrait_parts.append(mouth)
	portrait_parts.append(head)
	
	for part in portrait_parts:
		part.texture = portrait_texture
	
	current_mouth_origin = mouth.region_rect.position


func set_eyes(mood : DialogueManager.Mood) -> void:
	eyes.region_rect.position = eyes_dict[mood]


func set_mouth(mood : DialogueManager.Mood) -> void:
	mouth.region_rect.position = mouth_dict[mood]
	current_mouth_origin = mouth_dict[mood]


func start_talk() -> void:
	if !anim_timer.is_stopped():
		return
	
	anim_timer.start()
	is_talking = true


func stop_talk() -> void:
	anim_timer.stop()
	is_talking = false
	current_anim_stage = 0
	mouth.region_rect.position = current_mouth_origin


func next_mouth_frame() -> void:
	if current_anim_stage < max_anim_frames - 1:
		current_anim_stage += 1
	else:
		current_anim_stage = 0
	
	mouth.region_rect.position = Vector2(current_mouth_origin.x + portrait_size * current_anim_stage, current_mouth_origin.y)


func _on_anim_timer_timeout() -> void:
	next_mouth_frame()
