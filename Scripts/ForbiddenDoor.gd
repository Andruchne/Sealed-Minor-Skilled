extends Node2D

func on_interact(player : Node2D) -> void:
	player.begin_minigame("Soulcheck")
