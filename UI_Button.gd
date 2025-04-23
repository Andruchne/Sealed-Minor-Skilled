@tool
extends NinePatchRect
class_name UI_Button

@onready var label : Label = get_node_or_null("Label")

var hovered : bool = false
var click_down : bool = false

@export var default_button_img : CompressedTexture2D
@export var hovered_button_img : CompressedTexture2D
@export var pressed_button_img : CompressedTexture2D

@export var label_text: String:
	set(value):
		label_text = value
		update_label_text()

signal button_pressed()


func _ready():
	call_deferred("_update_label_safe")

func _update_label_safe():
	if is_instance_valid(label):
		label.text = label_text


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	button_clicked()


func button_clicked() -> void:
	if hovered && Input.is_action_just_pressed("Mouse_Left"):
		texture = pressed_button_img
		click_down = true
	elif click_down && hovered && Input.is_action_just_released("Mouse_Left"):
		texture = hovered_button_img
		emit_signal("button_pressed")

func update_label_text():
	if Engine.is_editor_hint():
		var label_temp : Label = get_node_or_null("Label")
		if is_instance_valid(label_temp):
			label_temp.text = label_text


func _on_mouse_entered() -> void:
	texture = hovered_button_img
	hovered = true


func _on_mouse_exited() -> void:
	texture = default_button_img
	hovered = false
	click_down = false
