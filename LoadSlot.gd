extends CustomButtonBase
class_name LoadSlot

@export var save_index : int

@onready var title : LineEdit = $EditPlaceholder

@onready var time : Label = $Time

@onready var player_parent : Control = $Player

@onready var player_body : TextureRect = $Player/Body
@onready var player_lens : TextureRect = $Player/Eyes_Lens
@onready var player_shirt : TextureRect = $Player/Shirt
@onready var player_pants : TextureRect = $Player/Pants


func clear_spot() -> void:
	title.text = "Slot"
	player_parent.visible = false
	time.text = "__:__"


func set_info(save_data : GameSaveData) -> void:
	title.text = save_data.save_name
	
	player_parent.visible = true
	player_body.modulate = save_data.player_info.body_color
	player_lens.modulate = save_data.player_info.lens_color
	
	player_shirt.modulate = save_data.player_info.shirt_color
	player_pants.modulate = save_data.player_info.pants_color
	
	time.text = "00:00"


func pressed() -> void:
	GameManager.LOAD_GAME(save_index)
