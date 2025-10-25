extends Control

@export var english_toggle : ToggleButton 
@export var german_toggle : ToggleButton 


func _ready() -> void:
	if TranslationServer.get_locale() == "en":
		english_toggle.pressed()
	else:
		german_toggle.pressed()
	
	english_toggle.button_pressed.connect(activate_english)
	german_toggle.button_pressed.connect(activate_german)


func activate_english() -> void:
	GameManager.SET_LANGUAGE("en") 


func activate_german() -> void:
	GameManager.SET_LANGUAGE("de") 
