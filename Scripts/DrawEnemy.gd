extends CharacterBody2D

@export var move_speed : float = 25

var player : Node2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")


func _physics_process(_delta: float) -> void:
	follow_player()
	move_and_slide()


func follow_player() -> void:
	if !player:
		return
	
	var direction = (player.position - position).normalized()
	velocity = direction * move_speed


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.death()
		player = null
		velocity = Vector2.ZERO
