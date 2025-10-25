extends CustomButtonBase
class_name ToggleButton

@export var other_toggles : Array[ToggleButton]

signal activated

func _ready() -> void:
	for toggle in other_toggles:
		toggle.activated.connect(other_activated)


func pressed() -> void:
	texture_setting_disable(true)
	set_button_state(2)
	emit_signal("activated")


func other_activated() -> void:
	set_button_state(0)
	texture_setting_disable(false)
