extends NinePatchRect

@export var normal_option_tex : CompressedTexture2D
@export var picked_option_tex : CompressedTexture2D

@onready var text_label : Label = $Text


func set_text(text : String) -> void:
	text_label.text = text


func set_picked() -> void:
	texture = picked_option_tex


func set_normal() -> void:
	texture = normal_option_tex 
