class_name CustomButtonBase
extends NinePatchRect

var hovered : bool = false
var click_down : bool = false

@export var default_button_img : CompressedTexture2D
@export var hovered_button_img : CompressedTexture2D
@export var pressed_button_img : CompressedTexture2D

var texture_set_disabled : bool

signal button_pressed()

func _process(_delta: float) -> void:
	button_clicked()


func button_clicked() -> void:
	if hovered && Input.is_action_just_pressed("Mouse_Left"):
		if !texture_set_disabled:
			texture = pressed_button_img
		click_down = true
	elif click_down && hovered && Input.is_action_just_released("Mouse_Left"):
		texture = hovered_button_img
		pressed()
		emit_signal("button_pressed")
		click_down = false


func _on_mouse_entered() -> void:
	if !texture_set_disabled:
		texture = hovered_button_img
	hovered = true


func _on_mouse_exited() -> void:
	if !texture_set_disabled:
		texture = default_button_img
	hovered = false
	click_down = false

# Override function
func pressed() -> void:
	pass

# This is supposed to be seen as toggle
# If a texture is set, anything else setting textures, will be left off
# Calling this function a second time, enables it again
func set_button_state(state_index : int) -> void:
	if state_index > 2 || state_index < 0:
		return
	
	match state_index:
		0:
			texture = default_button_img
		1: 
			texture = hovered_button_img
		2:
			texture = pressed_button_img


func texture_setting_disable(set_state : bool):
	texture_set_disabled = set_state
