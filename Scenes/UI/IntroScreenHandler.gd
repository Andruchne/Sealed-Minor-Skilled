extends Control

var level_to_load : String = "res://Scenes/Levels/SealedCave_0.tscn"

@onready var image : NinePatchRect = $IntroImage
@onready var text : TextShower = $DialogueText
@onready var image_timer : Timer = $AutoImageTimer
@onready var anim_timer : Timer = $AnimationTimer

var current_stage : int
var first_anim : bool
var skip_pause : bool
var animating : bool


func _ready() -> void:
	text.text_finished.connect(next_section)
	text.space_time = 0.1
	text.punctuation_time = 0.2
	text.letter_time = 0.06
	show_text()


func _process(delta: float) -> void:
	skip_section()


func skip_section() -> void:
	if Input.is_action_just_pressed("Interact") && !animating:
		text.finish_current_dialogue()
		
		if skip_pause:
			image_timer.stop()
			image_timer.timeout.emit()
		else:
			skip_pause = true


func next_section() -> void:
	image_timer.start()


func show_text() -> void:
	match current_stage:
		0:
			text.show_dialogue("Who knows, how long silence was your only company")
		1:
			text.show_dialogue("You don't remember thinking about it, up until now")
			next_image()
		2:
			text.show_dialogue("All you do, and have ever done, is to look at this door")
			next_image()
		3:
			text.show_dialogue("When suddenly…")
		4:
			anim_timer.start()
		5:
			text.show_dialogue("A small, unknown, yet still familiar voice faintly speaks")
		6:
			text.show_dialogue("\"It's time\"")
		7:
			text.show_dialogue("Suddenly, all you can think about, is getting out")
		8:
			text.show_dialogue("Where ever you are, all you want to do, is follow this new purpose")
		9:
			GameManager.CHANGE_SCENE(level_to_load, 1)
	
	current_stage += 1


func animate_image() -> void:
	if !first_anim:
		animating = true
		if image.region_rect.position.y < 108:
			image.region_rect.position = Vector2(0, 108)
		elif image.region_rect.position.x == 192 && image.region_rect.position.y == 216:
			first_anim = true
			animating = false
			show_text()
		else:
			next_image()
	else:
		var current_pos = image.region_rect.position
		if current_pos.y < 216 || (current_pos.y == 216 && current_pos.x < 384):
			image.region_rect.position = Vector2(384, 216)
		else:
			image.region_rect.position.x += 192
			
			if image.region_rect.position.x >= 384:
				image.region_rect.position.x = 0
				image.region_rect.position.y += 108
				if image.region_rect.position.y >= 432:
					image.region_rect.position = Vector2(384, 216)


func _on_animation_timer_timeout() -> void:
	animate_image()


func next_image() -> void:
	if image.region_rect.position.x == 192 && image.region_rect.position.y == 216:
		return
	
	image.region_rect.position.x += 192
	
	if image.region_rect.position.x >= 432:
		image.region_rect.position.x = 0
		image.region_rect.position.y += 108


func _on_auto_image_timer_timeout() -> void:
	show_text()
	skip_pause = false
