extends Control

@export var title_variations : Array[String]

@onready var title_label : Label = $Main/Title

@onready var save_button : UI_Button = $Main/Save_Button
@onready var load_button : UI_Button = $Main/Load_Button
@onready var option_button : UI_Button = $Main/Option_Button
@onready var exit_button : UI_Button = $Main/Exit_Button
@onready var return_button : CustomButtonBase = $Return

@onready var main_menu : Control = $Main
@onready var save_menu : Control = $Save
@onready var load_menu : Control = $Load

const MAX_ROTATION : float = 8
const MIN_ROTATION : float = -8
var rotation_speed : float = 20

var current_menu : Control
var previous_menus : Array[Control]

func _ready() -> void:
	if title_label:
		if title_variations.size() > 0:
			title_label.text = title_variations[randi_range(0, title_variations.size() - 1)]
		else:
			title_label.text = "Menu"
	
	save_button.button_pressed.connect(on_save_button_pressed)
	load_button.button_pressed.connect(on_load_button_pressed)
	option_button.button_pressed.connect(on_option_button_pressed)
	exit_button.button_pressed.connect(on_exit_button_pressed)
	return_button.button_pressed.connect(on_return_button_pressed)
	
	current_menu = main_menu


func _process(delta: float) -> void:
	animate_title(delta)


func animate_title(delta : float) -> void:
	if !title_label.visible:
		return
	
	var current_degrees : float = rad_to_deg(title_label.rotation)
	
	if current_degrees <= MIN_ROTATION || current_degrees >= MAX_ROTATION:
		rotation_speed *= -1
	
	title_label.rotation = deg_to_rad(current_degrees + rotation_speed * delta)


func on_save_button_pressed() -> void:
	change_menu(save_menu)
	save_menu.show_existing_saves()


func on_load_button_pressed() -> void:
	change_menu(load_menu)
	load_menu.show_existing_saves()


func on_option_button_pressed() -> void:
	pass


func on_exit_button_pressed() -> void:
	get_tree().quit()


func on_return_button_pressed() -> void:
	change_previous_menu()


func change_menu(new_menu : Control) -> void:
	previous_menus.append(current_menu)
	current_menu.visible = false
	current_menu = new_menu
	current_menu.visible = true
	return_button.visible = true


func change_previous_menu() -> void:
	if previous_menus.size() > 0:
		current_menu.visible = false
		current_menu = previous_menus[previous_menus.size() - 1]
		previous_menus.remove_at(previous_menus.size() - 1)
		current_menu.visible = true
		
		if previous_menus.size() == 0:
			return_button.visible = false
