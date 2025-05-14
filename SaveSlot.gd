extends CustomButtonBase
class_name SaveSlot

@export var save_index : int

@onready var title_edit_button : CustomButtonBase = $TitleEditButton
@onready var title : LineEdit = $EditPlaceholder

@onready var time : Label = $Time

@onready var player_parent : Control = $Player

@onready var player_body : TextureRect = $Player/Body
@onready var player_lens : TextureRect = $Player/Eyes_Lens
@onready var player_shirt : TextureRect = $Player/Shirt
@onready var player_pants : TextureRect = $Player/Pants

@onready var unsaved_token : Label = $UnsavedToken

var initial_title : String
var title_edit_enabled : bool

func _ready() -> void:
	title_edit_button.button_pressed.connect(edit_title_pressed)


func clear_spot() -> void:
	title.text = "Slot"
	player_parent.visible = false
	time.text = "__:__"


func set_info(save_data : GameSaveData) -> void:
	initial_title = save_data.save_name
	title.text = save_data.save_name
	
	player_parent.visible = true
	player_body.modulate = save_data.player_info.body_color
	player_lens.modulate = save_data.player_info.lens_color
	player_shirt.modulate = save_data.player_info.shirt_color
	player_pants.modulate = save_data.player_info.pants_color
	
	time.text = "00:00"
	
	if unsaved_token.visible:
		unsaved_token.visible = false


func _on_mouse_entered() -> void:
	if !title_edit_enabled:
		super()


func _on_mouse_exited() -> void:
	if !title_edit_enabled:
		super()


func pressed() -> void:
	GameManager.SAVE_GAME(title.text, save_index)


func edit_title_pressed() -> void:
	if !title_edit_enabled:
		title.grab_focus()
		title.caret_column = title.text.length()
		title_edit_enabled = true
		title_edit_button.set_button_state(2)
		title_edit_button.texture_setting_disable(true)
	else:
		finish_title_edit()


func finish_title_edit() -> void:
	title.release_focus()
	title_edit_enabled = false
	title_edit_button.set_button_state(0)
	title_edit_button.texture_setting_disable(false)
	
	if title.text != initial_title:
		unsaved_token.visible = true
	elif unsaved_token.visible:
		unsaved_token.visible = false


func _on_edit_placeholder_text_submitted(new_text: String) -> void:
	finish_title_edit()


func _on_edit_placeholder_focus_exited() -> void:
	if title_edit_enabled:
		finish_title_edit()
