extends RigidBody2D

func on_interact(player : Node2D) -> void:
	apply_central_force((player.position - position).normalized() * 500)
