@tool
extends CustomButtonBase
class_name UI_Button

@onready var label : Label = get_node_or_null("Label")

@export var label_text: String:
	set(value):
		label_text = value
		update_label_text()


func _ready() -> void:
	call_deferred("_update_label_safe")


func _update_label_safe() -> void:
	if is_instance_valid(label):
		label.text = label_text


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	super(delta)


func update_label_text() -> void:
	if Engine.is_editor_hint():
		var label_temp : Label = get_node_or_null("Label")
		if is_instance_valid(label_temp):
			label_temp.text = label_text
