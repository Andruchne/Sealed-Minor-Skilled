extends Control
class_name Popup_Label

enum Save_Text_Type {
	Dots,
	Exclamation
} 

@onready var label : Label = $Top_Right
@onready var interval_timer : Timer = $Interval
@onready var end_timer : Timer = $End_Timer

var current_index : int
var current_type : Save_Text_Type

var max_update_count : int

func popup_text(text : String, type : Save_Text_Type) -> void:
	current_index = 0
	current_type = type
	label.text = text
	end_timer.start()
	
	match type:
		Save_Text_Type.Dots:
			interval_timer.start()
			max_update_count = 3
		Save_Text_Type.Exclamation:
			label.text += "!"


func _on_interval_timeout() -> void:
	if current_index >= max_update_count:
		interval_timer.stop()
		return
	
	match current_type:
		Save_Text_Type.Dots:
			dot_follow()
		Save_Text_Type.Exclamation:
			exclamation_follow()
	
	current_index += 1


func dot_follow() -> void:
	label.text += "."


func exclamation_follow() -> void:
	label.text += "!"


func _on_end_timer_timeout() -> void:
	var tween = create_tween()
	
	var start_color = label.modulate
	var end_color = start_color
	end_color.a = 0.0
	
	tween.tween_property(label, "modulate", end_color, 0.4)
	tween.tween_callback(finish)
	tween.play()


func finish() -> void:
	queue_free()
