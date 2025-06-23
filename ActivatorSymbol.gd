extends Node2D

@onready var activeness_sprite : Sprite2D = $Activeness

@export var specific_id : int
@export var activeness_color : Color
@export var fade_duration : float = 1

var active : bool
var activators : Array[Activator] = []
var current_actives : int = 0

var activator_count : int = 0


func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	setup()


func setup() -> void:
	activeness_sprite.modulate = activeness_color
	activeness_sprite.modulate.a = 0
	
	await get_tree().process_frame
	await get_tree().process_frame
	var total_count : int = 0
	var nodes : Array = get_tree().get_nodes_in_group("Activator")
	for node in nodes:
		if (node as Activator).total:
			total_count += 1
		for id in (node as Activator).specific_ids:
			if id == specific_id:
				activators.append(node)
	
	activator_count = activators.size() - total_count
	
	for activator in activators:
		activator.activated.connect(activate)
		activator.deactivated.connect(deactivate)
		activator.total_activated.connect(activate_total)
		activator.total_deactivated.connect(deactivate_total)


func _process(delta: float) -> void:
	transition(delta)


func transition(delta : float) -> void:
	if active && activeness_sprite.modulate.a < 1:
		activeness_sprite.modulate.a += fade_duration * delta
	elif !active && activeness_sprite.modulate.a > 0:
		activeness_sprite.modulate.a -= fade_duration * delta


func activate() -> void:
	current_actives += 1
	check_state()


func deactivate() -> void:
	current_actives -= 1
	check_state()


func activate_total() -> void:
	current_actives += activator_count
	check_state()


func deactivate_total() -> void:
	current_actives -= activator_count
	check_state()


func check_state() -> void:
	if current_actives >= activator_count:
		active = true
	else:
		active = false


func get_save_state() -> Dictionary:
	var dict : Dictionary = {
		"alpha" : activeness_sprite.modulate.a
	}
	
	return dict


func apply_save_state(state : Dictionary) -> void:
	var c : Color = activeness_sprite.modulate
	c.a = state.get("alpha")
	
	activeness_sprite.modulate = c
