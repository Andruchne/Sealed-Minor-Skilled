extends NinePatchRect
class_name SaveSlot

@export var default_texture : CompressedTexture2D
@export var hovered_texture : CompressedTexture2D
@export var pressed_texture : CompressedTexture2D

@onready var title : Label = $Title
@onready var time : Label = $Time

@onready var player_parent : Control = $Player

@onready var player_body : TextureRect = $Player/Body
@onready var player_lens : TextureRect = $Player/Eyes_Lens

var hovered : bool = false
var click_down : bool = false

signal button_pressed(slot : SaveSlot)


func clear_spot() -> void:
	title.text = "Slot"
	player_parent.visible = false
	time.text = "__:__"


func set_info(title_text : String, player_info : PlayerInfo) -> void:
	title.text = title_text
	
	player_body.modulate = player_info.body_color
	player_lens.modulate = player_info.lens_color
	
	time.text = "00:00"


func _process(_delta: float) -> void:
	button_clicked()


func button_clicked() -> void:
	if hovered && Input.is_action_just_pressed("Mouse_Left"):
		texture = pressed_texture
		click_down = true
	elif click_down && hovered && Input.is_action_just_released("Mouse_Left"):
		texture = hovered_texture
		emit_signal("button_pressed", self)

func _on_mouse_entered() -> void:
	texture = hovered_texture
	hovered = true


func _on_mouse_exited() -> void:
	texture = default_texture
	hovered = false
	click_down = false
