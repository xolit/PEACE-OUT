extends Node

@onready var player: CharacterBody3D = $".."

func _save_game_state() -> void:
	# 1. Update item collection states
	Game.game_states["isGameSaved"] = true
	
	# 2. Update player position and rotation vectors directly
	var telemetry = Game.game_states.get("player_position_and_rotation", {})
	telemetry["position"] = player.global_position
	telemetry["rotation"] = player.global_rotation
	Game.game_states["player_position_and_rotation"] = telemetry
	Game._save()
