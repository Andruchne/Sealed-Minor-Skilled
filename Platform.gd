extends Activator
class_name TreePlatform

@onready var activeness_sprite : Sprite2D = $Activeness

@export var activeness_color : Color
@export var fade_duration : float = 1

var entered_count : int = 0

# Indicates, to which access it belongs to
var access_index : int = 0


func _ready() -> void:
	await get_tree().process_frame
	activeness_sprite.modulate = activeness_color
	activeness_sprite.modulate.a = 0


func _process(delta: float) -> void:
	transition(delta)


func transition(delta : float) -> void:
	if active && activeness_sprite.modulate.a < 1:
		activeness_sprite.modulate.a += fade_duration * delta
		if activeness_sprite.modulate.a >= 1:
			emit_signal("activated")
			was_activated = true
	elif !active && activeness_sprite.modulate.a > 0:
		activeness_sprite.modulate.a -= fade_duration * delta
		if was_activated:
			was_activated = false
			emit_signal("deactivated")


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Box") || area.is_in_group("Player"):
		entered_count += 1
		check_state()


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("Box") || area.is_in_group("Player"):
		entered_count -= 1
		check_state()


func check_state() -> void:
	if entered_count > 0:
		active = true
	else:
		active = false


func get_save_state() -> Dictionary:
	var dict = super()
	dict["alpha"] = activeness_sprite.modulate.a
	
	return dict


func apply_save_state(state : Dictionary) -> void:
	super(state)
	activeness_sprite.modulate.a = state.get("alpha")
