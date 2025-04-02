extends Node2D

# Collection of different step particles
var step_particle_dictionary : Dictionary = {
	"Water" : "res://Scenes/ParticleEffects/StepEffect/water_step.tscn"
}

# Array of current particles
var particle_pos : Array

func _ready() -> void:
	for child in get_children():
		particle_pos.append(child)


func play_step(foot_index : int, type : String) -> void:
	if !foot_index_valid(foot_index) || !step_particle_dictionary.has(type):
		return
	var source = step_particle_dictionary[type]
	if source:
		var particle = load(source).instantiate()
		particle.global_position = particle_pos[foot_index].global_position
		particle.emitting = true
		get_tree().current_scene.add_child(particle)


func get_foot_pos(foot_index : int) -> Vector2:
	if !foot_index_valid(foot_index):
		return Vector2.ZERO
	return particle_pos[foot_index].global_position


func foot_index_valid(index : int) -> bool:
	return index > 0 || index < particle_pos.size()
